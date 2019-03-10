library wheel_spinner;

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

  /// Speed in which the user can drag the slider. Faster speed factor = easier to increment
  /// or discrement [value]
  final double dragSpeedFactor = 1.0;

  static ValueStringBuilder defaultMinMaxLabelBuilder =
      (v) => v.toStringAsFixed(2);

  const WheelSpinner({
    Key key,
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
    // this.dragSpeedFactor = 1.0,
  }) : super(key: key);

  @override
  _WheelSpinnerState createState() => _WheelSpinnerState(value: value);
}

class _WheelSpinnerState extends State<WheelSpinner> {
  double value;
  double dragValue;
  Offset dragOffset;

  _WheelSpinnerState({this.value});

  @override
  Widget build(BuildContext context) {
    const double shadowOffset = 0.2;
    ValueStringBuilder minMaxBuilder =
        widget.minMaxLabelBuilder ?? WheelSpinner.defaultMinMaxLabelBuilder;
    double labelFontSize = Theme.of(context).textTheme.body1.fontSize * 0.75;
    TextStyle labelStyle =
        TextStyle(fontSize: labelFontSize).merge(widget.labelStyle);

    String minText =
        widget.max < double.infinity ? minMaxBuilder(widget.max) : null;
    String maxText =
        widget.min > double.negativeInfinity ? minMaxBuilder(widget.min) : null;

    return Row(
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
        GestureDetector(
          onVerticalDragStart: onDragStart,
          onVerticalDragUpdate: onDragUpdate,
          onVerticalDragEnd: onDragDone,
          child: SizedBox.fromSize(
            size: Size(widget.width.toDouble(), widget.height.toDouble()),
            child: Container(
              child: Stack(
                children: List<Widget>.generate(
                      20,
                      (i) {
                        var top = calcTop(value, i);
                        return Positioned.fromRect(
                          rect: Rect.fromLTWH(
                            0.0,
                            top,
                            widget.width.toDouble(),
                            0,
                          ),
                          child: Divider(
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ).toList() +
                    (widget.childBuilder != null
                        ? [widget.childBuilder(value)]
                        : []),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, shadowOffset, 1.0 - shadowOffset, 1.0],
                  colors: [
                    Colors.grey[350],
                    Colors.grey[50],
                    Colors.grey[50],
                    Colors.grey[350]
                  ],
                ),
                border: Border.all(
                  width: 1,
                  style: BorderStyle.solid,
                  color: Colors.grey[600],
                ),
                borderRadius: BorderRadius.circular(3.5),
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
    );
  }

  double calcTop(double value, int i) {
    double valueFraction = (value.ceil() - value) * 10;
    double indexedTop = (widget.height / 10 * i);
    double widgetMiddle = widget.height / 2;
    double top = indexedTop - widgetMiddle + valueFraction;
    return top;
  }

  void onDragDone(details) {
    setState(() {
      dragOffset = null;
    });
    if (widget.onSlideDone != null) {
      widget.onSlideDone(value);
    }
  }

  void onDragUpdate(details) {
    var newValue = clamp(
        dragValue -
            (details.globalPosition - dragOffset).dy /
                (20.0 / widget.dragSpeedFactor),
        widget.min,
        widget.max);
    setState(() {
      value = newValue;
    });
    if (widget.onSlideUpdate != null) {
      widget.onSlideUpdate(value);
    }
  }

  void onDragStart(details) {
    setState(() {
      dragOffset = details.globalPosition;
      dragValue = value;
    });
  }
}
