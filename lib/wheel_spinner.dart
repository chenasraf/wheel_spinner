/// The main library for the wheel spinner.
library wheel_spinner;

import 'package:flutter/material.dart';
import 'package:wheel_spinner/utils.dart';
import 'package:wheel_spinner/wheel_spinner_theme.dart';

export 'wheel_spinner_theme.dart';

typedef ValueBuilder = Widget Function(double value);
typedef ValueStringBuilder = String Function(double value);

enum WheelSpinnerChildPosition {
  /// The child is positioned at the top of the control
  top,

  /// The child is positioned at the bottom of the control
  bottom,
}

/// Shows a pitch-bend-like knob that can be dragged up or down, either unlimited or
/// restricted by [max] and [min].
class WheelSpinner extends StatefulWidget {
  /// Callback for when the user starts dragging the slider
  final Function(double details)? onSlideStart;

  /// Callback for when the user drags the slider
  final Function(double value)? onSlideUpdate;

  /// Callback for when the user lets go of the slider
  final Function(double value)? onSlideDone;

  /// The initial [value] for the slider
  final double value;

  /// Minimum value to allow sliding to.
  final double min;

  /// Minimum value to allow sliding to.
  final double max;

  /// Builder for children of the slider.
  final ValueBuilder? childBuilder;

  /// The drag speed factor
  final double _dragSpeedFactor = 1.0;

  /// The theme for this wheel spinner
  final WheelSpinnerThemeData? theme;

  /// The position of the child on the control. If [childProvider] is null, this has no effect.
  final WheelSpinnerChildPosition? childPosition;

  const WheelSpinner({
    Key? key,
    this.onSlideStart,
    this.onSlideUpdate,
    this.onSlideDone,
    this.min = double.negativeInfinity,
    this.max = double.infinity,
    this.value = 0.5,
    this.childBuilder,
    this.theme,
    this.childPosition,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WheelSpinnerState createState() => _WheelSpinnerState();
}

class _WheelSpinnerState extends State<WheelSpinner>
    with SingleTickerProviderStateMixin {
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

  /// Calculated theme based on the default theme and merged with theme from the widget or up the tree
  WheelSpinnerThemeData get _theme {
    final activeTheme = widget.theme ?? WheelSpinnerTheme.of(context);
    return defaultTheme.copyWith(
      border: activeTheme?.border,
      borderRadius: activeTheme?.borderRadius,
      color: activeTheme?.color,
      gradient: activeTheme?.gradient,
      boxDecoration: activeTheme?.boxDecoration,
      dividerCount: activeTheme?.dividerCount,
      dividerColor: activeTheme?.dividerColor,
    );
  }

  /// The default theme for the wheel spinner in the current context's theme brightness mode
  WheelSpinnerThemeData get defaultTheme =>
      WheelSpinnerTheme.of(context) ??
      (Theme.of(context).brightness == Brightness.light
          ? WheelSpinnerThemeData.light()
          : WheelSpinnerThemeData.dark());

  @override
  Widget build(BuildContext context) {
    final _child =
        (widget.childBuilder != null ? widget.childBuilder!(value) : null);
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedBuilder(
              animation: flingAnimation,
              builder: (context, _) {
                return GestureDetector(
                  onVerticalDragStart: _onDragStart,
                  onVerticalDragUpdate: _onDragUpdate,
                  onVerticalDragEnd: _onDragDone,
                  child: Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    decoration: _theme.boxDecoration ?? _boxDecorationBuilder(),
                    child: ClipRRect(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: _theme.boxDecoration?.borderRadius
                              ?.resolve(Directionality.of(context)) ??
                          _theme.borderRadius,
                      child: Stack(
                        children: [
                          if (_child != null &&
                              widget.childPosition ==
                                  WheelSpinnerChildPosition.top)
                            _child,
                          ...List<Widget>.generate(_theme.dividerCount + 1,
                              _generateLine(constraints)),
                          if (_child != null &&
                              widget.childPosition ==
                                  WheelSpinnerChildPosition.bottom)
                            _child,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Default box decoration
  BoxDecoration _boxDecorationBuilder() => BoxDecoration(
        gradient: _theme.gradient,
        color: _theme.color,
        border: _theme.border,
        borderRadius: _theme.borderRadius,
      );

  /// Calculates the position of a line based on the index
  double _linePos(double value, int i, double fling, double maxHeight) {
    final valueFraction = (value.ceil() - value) * _theme.dividerCount;
    final indexedTop = (maxHeight / _theme.dividerCount * i);
    final top = indexedTop + valueFraction;
    return top;
  }

  /// Drag start callback
  void _onDragStart(DragStartDetails details) {
    flingController.stop();
    flingAnimation = const AlwaysStoppedAnimation(0.0);
    setState(() {
      dragStartOffset = details.globalPosition;
      dragStartValue = value;
    });
    widget.onSlideStart?.call(value);
  }

  /// Drag update callback
  void _onDragUpdate(DragUpdateDetails details) {
    flingController.stop();
    final newValue = clamp(
        dragStartValue -
            (details.globalPosition - dragStartOffset!).dy /
                (20.0 / widget._dragSpeedFactor),
        widget.min,
        widget.max);
    setState(() => value = newValue);
    widget.onSlideUpdate?.call(value);
  }

  /// Drag end callback
  void _onDragDone(DragEndDetails details) {
    setState(() => dragStartOffset = null);
    final velocity = details.primaryVelocity!;
    if (velocity.abs() == 0) {
      widget.onSlideDone?.call(value);
      return;
    }
    final originalValue = value;
    currentFlingListener = _flingListener(originalValue);
    flingController.duration = Duration(milliseconds: velocity.abs().toInt());
    flingAnimation =
        Tween(begin: 0.0, end: velocity / 100).animate(CurvedAnimation(
      curve: Curves.decelerate,
      parent: flingController,
    ))
          ..addListener(currentFlingListener);
    flingController
      ..reset()
      ..forward();
  }

  /// Fling listener
  void Function() _flingListener(double originalValue) {
    return () {
      final newValue =
          clamp(originalValue - flingAnimation.value, widget.min, widget.max);
      if (newValue != value) {
        setState(() => value = newValue);
        if (flingAnimation.value == flingController.upperBound) {
          widget.onSlideDone?.call(value);
        } else {
          widget.onSlideUpdate?.call(value);
        }
      }
    };
  }

  /// Returns function that generates line based on index
  Widget Function(int index) _generateLine(BoxConstraints constraints) {
    return (i) {
      final top =
          _linePos(value, i, flingAnimation.value, constraints.maxHeight);
      return Positioned.fromRect(
        rect: Rect.fromLTWH(0.0, top, constraints.maxWidth, 0),
        child: Divider(color: _theme.dividerColor),
      );
    };
  }

  @override
  void dispose() {
    flingController.dispose();
    super.dispose();
  }
}
