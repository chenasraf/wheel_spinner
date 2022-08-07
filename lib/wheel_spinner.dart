library wheel_spinner;

import 'package:flutter/material.dart';
import 'package:wheel_spinner/utils.dart';

typedef ValueBuilder = Widget Function(double value);
typedef ValueStringBuilder = String Function(double value);

/// Shows a "dial" spinner that can be dragged up or down, either unlimited or
/// restricted by [max] and [min].
class WheelSpinner extends StatefulWidget {
  /// Callback for when the user drags the slider
  final Function(double value)? onSlideUpdate;

  /// Callback for when the user lets go of the slider
  final Function(double value)? onSlideDone;

  /// The widget [width]
  final double width;

  /// The widget [height]
  final double height;

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

  /// Allows to override style of labels
  final TextStyle? labelStyle;

  /// Override box decoration for the control
  final BoxDecoration? boxDecoration;

  /// Override box border for the control's [boxDecoration].
  /// If [boxDecoration] is specified, it overrides this property.
  final Border? border;

  /// Override border radius for the control's [boxDecoration].
  /// If [boxDecoration] is specified, it overrides this property.
  final BorderRadius? borderRadius;

  /// Override background color for the control's [boxDecoration].
  /// If [boxDecoration] is specified, it overrides this property.
  final Color? color;

  /// Override background gradient for the control's [boxDecoration].
  /// If [boxDecoration] is specified, it overrides this property.
  final Gradient? gradient;

  /// Amount of divisions to show on the knob
  final int dividerCount;

  /// Color of the lines dividing the control.
  final Color? dividerColor;

  /// The drag speed factor
  final double _dragSpeedFactor = 1.0;

  /// The default min/max label builder.
  static ValueStringBuilder defaultMinMaxLabelBuilder = (v) => v.toStringAsFixed(2);

  const WheelSpinner(
      {Key? key,
      this.onSlideUpdate,
      this.onSlideDone,
      this.width = 60,
      this.height = 100,
      this.min = double.negativeInfinity,
      this.max = double.infinity,
      this.value = 0.5,
      this.childBuilder,
      this.minMaxLabelBuilder,
      this.labelStyle,
      this.dividerCount = 10,
      this.dividerColor,
      this.boxDecoration,
      this.border,
      this.borderRadius,
      this.color,
      this.gradient})
      : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final minMaxBuilder = widget.minMaxLabelBuilder ?? WheelSpinner.defaultMinMaxLabelBuilder;
    final labelFontSize = Theme.of(context).textTheme.bodyText2!.fontSize! * 0.75;
    final labelStyle = TextStyle(fontSize: labelFontSize).merge(widget.labelStyle);

    final minText = widget.max < double.infinity ? minMaxBuilder(widget.max) : null;
    final maxText = widget.min > double.negativeInfinity ? minMaxBuilder(widget.min) : null;

    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  minText != null ? Text(minText, style: labelStyle) : Container(),
                  maxText != null ? Text(maxText, style: labelStyle) : Container(),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: flingAnimation,
            builder: (context, child) => GestureDetector(
              onVerticalDragStart: onDragStart,
              onVerticalDragUpdate: onDragUpdate,
              onVerticalDragEnd: onDragDone,
              child: SizedBox.fromSize(
                size: Size(widget.width.toDouble(), widget.height.toDouble()),
                child: Container(
                  decoration: widget.boxDecoration ?? _boxDecorationBuilder(),
                  child: Stack(
                    children: List<Widget>.generate(
                          widget.dividerCount + 1,
                          (i) {
                            final top = lineTopPos(value, i, flingAnimation.value);
                            return Positioned.fromRect(
                              rect: Rect.fromLTWH(
                                0.0,
                                top,
                                widget.width.toDouble(),
                                0,
                              ),
                              child: Divider(
                                color: widget.dividerColor ?? Colors.grey[600],
                              ),
                            );
                          },
                        ).toList() +
                        (widget.childBuilder != null ? [widget.childBuilder!(value)] : []),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('+', style: labelStyle),
                  Text('-', style: labelStyle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecorationBuilder() {
    const shadowOffset = 0.2;
    return BoxDecoration(
      gradient: (widget.gradient ?? widget.color) == null
          ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, shadowOffset, 1.0 - shadowOffset, 1.0],
              colors: [Colors.grey[350]!, Colors.grey[50]!, Colors.grey[50]!, Colors.grey[350]!],
            )
          : null,
      color: widget.color,
      border: widget.border ??
          Border.all(
            width: 1,
            style: BorderStyle.solid,
            color: Colors.grey[600]!,
          ),
      borderRadius: widget.borderRadius ?? BorderRadius.circular(3.5),
    );
  }

  double lineTopPos(double value, int i, double fling) {
    final valueFraction = (value.ceil() - value) * widget.dividerCount;
    final indexedTop = (widget.height / widget.dividerCount * i);
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
