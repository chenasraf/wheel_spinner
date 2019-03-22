library wheel_spinner;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wheel_spinner/utils.dart';

typedef Widget ValueBuilder(double value);
typedef String ValueStringBuilder(double value);

/// Shows a "dial" spinner that can be dragged up or down, either unlimited or
/// restricted by [max] and [min].
class WheelSpinner extends StatefulWidget {
  /// Callback for when the user drags the slider
  final Function(double value) onSlideUpdate;

  /// Callback for when the user lets go of the slider
  final Function(double value) onSlideDone;

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
  final ValueBuilder childBuilder;

  /// Allows overriding the format of the left top and bottom labels for the [min]/[max] values
  final ValueStringBuilder minMaxLabelBuilder;

  /// Allows to override style of labels
  final TextStyle labelStyle;

  /// Override box decoration for the control
  final BoxDecoration boxDecoration;

  /// Override box border for the control's [boxDecoration].
  /// If [boxDecoration] is specified, it overrides this property.
  final Border border;

  /// Override border radius for the control's [boxDecoration].
  /// If [boxDecoration] is specified, it overrides this property.
  final BorderRadius borderRadius;

  /// Override background color for the control's [boxDecoration].
  /// If [boxDecoration] is specified, it overrides this property.
  final Color color;

  /// Override background gradient for the control's [boxDecoration].
  /// If [boxDecoration] is specified, it overrides this property.
  final Gradient gradient;

  /// Amount of divisions to show on the knob
  final int dividerCount;

  /// Color of the lines dividing the control.
  final Color dividerColor;

  ///
  final double _dragSpeedFactor = 1.0;

  static ValueStringBuilder defaultMinMaxLabelBuilder =
      (v) => v.toStringAsFixed(2);

  const WheelSpinner(
      {Key key,
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
  _WheelSpinnerState createState() => _WheelSpinnerState();
}

class _WheelSpinnerState extends State<WheelSpinner>
    with TickerProviderStateMixin {
  double value;
  double dragStartValue;
  Offset dragStartOffset;
  AnimationController flingController;
  Animation<double> flingAnimation;
  void Function() currentFlingListener;

  _WheelSpinnerState({this.value});

  @override
  void initState() {
    flingAnimation = AlwaysStoppedAnimation(0.0);
    flingController = AnimationController(vsync: this);
    value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ValueStringBuilder minMaxBuilder =
        widget.minMaxLabelBuilder ?? WheelSpinner.defaultMinMaxLabelBuilder;
    double labelFontSize = Theme.of(context).textTheme.body1.fontSize * 0.75;
    TextStyle labelStyle =
        TextStyle(fontSize: labelFontSize).merge(widget.labelStyle);

    String minText =
        widget.max < double.infinity ? minMaxBuilder(widget.max) : null;
    String maxText =
        widget.min > double.negativeInfinity ? minMaxBuilder(widget.min) : null;

    return Container(
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
                  minText != null
                      ? Text(minText, style: labelStyle)
                      : Container(),
                  maxText != null
                      ? Text(maxText, style: labelStyle)
                      : Container(),
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
                    size:
                        Size(widget.width.toDouble(), widget.height.toDouble()),
                    child: Container(
                      child: Stack(
                        children: List<Widget>.generate(
                              widget.dividerCount + 1,
                              (i) {
                                var top =
                                    lineTopPos(value, i, flingAnimation.value);
                                return Positioned.fromRect(
                                  rect: Rect.fromLTWH(
                                    0.0,
                                    top,
                                    widget.width.toDouble(),
                                    0,
                                  ),
                                  child: Divider(
                                    color:
                                        widget.dividerColor ?? Colors.grey[600],
                                  ),
                                );
                              },
                            ).toList() +
                            (widget.childBuilder != null
                                ? [widget.childBuilder(value)]
                                : []),
                      ),
                      decoration: widget.boxDecoration ??
                          _defaultBoxDecorationBuilder(),
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

  BoxDecoration _defaultBoxDecorationBuilder() {
    double shadowOffset = 0.2;
    var decoration = BoxDecoration(
      gradient: widget.gradient ?? widget.color == null
          ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, shadowOffset, 1.0 - shadowOffset, 1.0],
              colors: [
                Colors.grey[350],
                Colors.grey[50],
                Colors.grey[50],
                Colors.grey[350]
              ],
            )
          : null,
      color: widget.color,
      border: widget.border ??
          Border.all(
            width: 1,
            style: BorderStyle.solid,
            color: Colors.grey[600],
          ),
      borderRadius: widget.borderRadius ?? BorderRadius.circular(3.5),
    );
    return decoration;
  }

  double lineTopPos(double value, int i, double fling) {
    double valueFraction = (value.ceil() - value) * widget.dividerCount;
    double indexedTop = (widget.height / widget.dividerCount * i);
    double top = indexedTop + valueFraction;
    return top;
  }

  void onDragStart(details) {
    flingController.stop();
    flingAnimation = AlwaysStoppedAnimation(0.0);
    setState(() {
      dragStartOffset = details.globalPosition;
      dragStartValue = value;
    });
  }

  void onDragUpdate(details) {
    flingController.stop();
    var newValue = clamp(
        dragStartValue -
            (details.globalPosition - dragStartOffset).dy /
                (20.0 / widget._dragSpeedFactor),
        widget.min,
        widget.max);
    setState(() {
      value = newValue;
    });
    if (widget.onSlideUpdate != null) {
      widget.onSlideUpdate(value);
    }
  }

  void onDragDone(DragEndDetails details) {
    setState(() {
      dragStartOffset = null;
    });
    double velocity = details.primaryVelocity;
    if (velocity.abs() == 0) {
      if (widget.onSlideDone != null) {
        widget.onSlideDone(value);
      }
      return;
    }
    double originalValue = value;
    currentFlingListener = flingListener(originalValue);
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

  flingListener(double originalValue) {
    return () {
      double newValue =
          clamp(originalValue - flingAnimation.value, widget.min, widget.max);
      if (newValue != value) {
        setState(() {
          value = newValue;
        });
        if (flingAnimation.value == flingController.upperBound) {
          if (widget.onSlideDone != null) {
            widget.onSlideDone(value);
          }
        } else {
          if (widget.onSlideUpdate != null) {
            widget.onSlideUpdate(value);
          }
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
