/// The main library for the wheel spinner.
library wheel_spinner;

import 'package:flutter/material.dart';
import 'package:wheel_spinner/utils.dart';
import 'package:wheel_spinner/wheel_spinner_theme.dart';

export 'wheel_spinner_theme.dart';

typedef ValueBuilder = Widget Function(double value);
typedef ValueStringBuilder = String Function(double value);

/// Shows a "dial" spinner that can be dragged up or down, either unlimited or
/// restricted by [max] and [min].
class WheelSpinner extends StatefulWidget {
  /// Callback for when the user drags the slider
  final Function(double value)? onSlideUpdate;

  /// Callback for when the user lets go of the slider
  final Function(double value)? onSlideDone;

  /// The initial [value] for the slider
  final double value;

  /// Minimum value to allow sliding to. Also appears on the bottom left of the slider
  final double min;

  /// Minimum value to allow sliding to. Also appears on the top left of the slider
  final double max;

  /// Builder for children of the slider.
  final ValueBuilder? childBuilder;

  /// Allows overriding the format of the left top and bottom labels for the [min]/[max] values
  final ValueStringBuilder? minMaxLabelBuilder;

  /// The drag speed factor
  final double _dragSpeedFactor = 1.0;

  /// The theme for this wheel spinner
  final WheelSpinnerThemeData? theme;

  /// The default min/max label builder.
  static ValueStringBuilder defaultMinMaxLabelBuilder = (v) => v.toStringAsFixed(2);

  const WheelSpinner({
    Key? key,
    this.onSlideUpdate,
    this.onSlideDone,
    this.min = double.negativeInfinity,
    this.max = double.infinity,
    this.value = 0.5,
    this.childBuilder,
    this.minMaxLabelBuilder,
    this.theme,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WheelSpinnerState createState() => _WheelSpinnerState();
}

class _WheelSpinnerState extends State<WheelSpinner> with SingleTickerProviderStateMixin {
  late double value;
  late double dragStartValue;
  Offset? dragStartOffset;
  late AnimationController flingController;
  late Animation<double> flingAnimation;
  late void Function() currentFlingListener;

  _WheelSpinnerState();

  @override
  void initState() {
    flingAnimation = const AlwaysStoppedAnimation(0.0);
    flingController = AnimationController(vsync: this);
    value = widget.value;
    super.initState();
  }

  WheelSpinnerThemeData get theme => defaultTheme.copyWith(
        border: widget.theme?.border,
        borderRadius: widget.theme?.borderRadius,
        color: widget.theme?.color,
        gradient: widget.theme?.gradient,
        boxDecoration: widget.theme?.boxDecoration,
        dividerCount: widget.theme?.dividerCount,
        dividerColor: widget.theme?.dividerColor,
      );

  WheelSpinnerThemeData get defaultTheme =>
      WheelSpinnerTheme.of(context) ??
      (Theme.of(context).brightness == Brightness.light
          ? WheelSpinnerThemeData.light()
          : WheelSpinnerThemeData.dark());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      debugPrint('borderRadius: ${theme.borderRadius}');
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedBuilder(
              animation: flingAnimation,
              builder: (context, child) => GestureDetector(
                onVerticalDragStart: onDragStart,
                onVerticalDragUpdate: onDragUpdate,
                onVerticalDragEnd: onDragDone,
                child: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  decoration: theme.boxDecoration ?? _boxDecorationBuilder(),
                  child: Stack(
                    children: List<Widget>.generate(
                          theme.dividerCount + 1,
                          (i) {
                            final top = lineTopPos(
                              value,
                              i,
                              flingAnimation.value,
                              constraints.maxHeight,
                            );
                            return Positioned.fromRect(
                              rect: Rect.fromLTWH(
                                0.0,
                                top,
                                constraints.maxWidth,
                                0,
                              ),
                              child: Divider(
                                color: theme.dividerColor,
                              ),
                            );
                          },
                        ).toList() +
                        (widget.childBuilder != null ? [widget.childBuilder!(value)] : []),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  BoxDecoration _boxDecorationBuilder() {
    return BoxDecoration(
      gradient: theme.gradient,
      color: theme.color,
      border: theme.border,
      borderRadius: theme.borderRadius,
    );
  }

  double lineTopPos(double value, int i, double fling, double maxHeight) {
    final valueFraction = (value.ceil() - value) * theme.dividerCount;
    final indexedTop = (maxHeight / theme.dividerCount * i);
    final top = indexedTop + valueFraction;
    return top;
  }

  void onDragStart(details) {
    flingController.stop();
    flingAnimation = const AlwaysStoppedAnimation(0.0);
    setState(() {
      dragStartOffset = details.globalPosition;
      dragStartValue = value;
    });
  }

  void onDragUpdate(details) {
    flingController.stop();
    final newValue = clamp(
        dragStartValue -
            (details.globalPosition - dragStartOffset).dy / (20.0 / widget._dragSpeedFactor),
        widget.min,
        widget.max);
    setState(() {
      value = newValue;
    });
    widget.onSlideUpdate?.call(value);
  }

  void onDragDone(DragEndDetails details) {
    setState(() {
      dragStartOffset = null;
    });
    final velocity = details.primaryVelocity!;
    if (velocity.abs() == 0) {
      widget.onSlideDone?.call(value);
      return;
    }
    final originalValue = value;
    currentFlingListener = flingListener(originalValue);
    flingController.duration = Duration(milliseconds: velocity.abs().toInt());
    flingAnimation = Tween(begin: 0.0, end: velocity / 100).animate(CurvedAnimation(
      curve: Curves.decelerate,
      parent: flingController,
    ))
      ..addListener(currentFlingListener);
    flingController
      ..reset()
      ..forward();
  }

  flingListener(double originalValue) {
    return () {
      final newValue = clamp(originalValue - flingAnimation.value, widget.min, widget.max);
      if (newValue != value) {
        setState(() {
          value = newValue;
        });
        if (flingAnimation.value == flingController.upperBound) {
          widget.onSlideDone?.call(value);
        } else {
          widget.onSlideUpdate?.call(value);
        }
      }
    };
  }

  @override
  void dispose() {
    flingController.dispose();
    super.dispose();
  }
}
