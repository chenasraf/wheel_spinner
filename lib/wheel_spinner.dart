library wheel_spinner;

import 'package:flutter/material.dart';
import 'package:wheel_spinner/utils.dart';

/// Shows a "dial" spinner that can be dragged up or down, either unlimited or
/// restricted by [max] and [min].
class WheelSpinner extends StatefulWidget {
  /// Callback for when the user drags the slider
  final Function(double value) onSlideUpdate;
  /// Callback for when the user lets go of the slider
  final Function(double value) onSlideDone;
  /// The widget width
  final double width;
  /// The widget height
  final double height;
  /// The initial value for the slider
  final double value;
  /// Minimum value to allow sliding to. Also appears on the bottom left of the slider
  final double min;
  /// Minimum value to allow sliding to. Also appears on the top left of the slider
  final double max;
  /// Allows adding a widget above the slider
  final Widget Function(double value) labelBuilder;

  const WheelSpinner({
    Key key,
    this.onSlideUpdate,
    this.onSlideDone,
    this.width = 60,
    this.height = 100,
    this.min = double.negativeInfinity,
    this.max = double.infinity,
    this.value = 0.5,
    this.labelBuilder,
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

    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  widget.max.round().toString(),
                  textScaleFactor: 0.75,
                ),
                Text(
                  widget.min.round().toString(),
                  textScaleFactor: 0.75,
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onVerticalDragStart: (details) {
            setState(() {
              dragOffset = details.globalPosition;
              dragValue = value;
            });
          },
          onVerticalDragUpdate: (details) {
            var newValue = clamp(
                dragValue - (details.globalPosition - dragOffset).dy / 20.0,
                widget.min,
                widget.max);
            setState(() {
              value = newValue;
            });
            if (widget.onSlideUpdate != null) {
              widget.onSlideUpdate(value);
            }
          },
          onVerticalDragEnd: (details) {
            setState(() {
              dragOffset = null;
            });
            if (widget.onSlideDone != null) {
              widget.onSlideDone(value);
            }
          },
          child: SizedBox.fromSize(
            size: Size(widget.width.toDouble(), widget.height.toDouble()),
            child: Container(
              child: Stack(
                children: List<Widget>.generate(
                      20,
                      (i) {
                        double valueFraction = (value.ceil() - value) * 10;
                        double top =
                            (widget.height / 10 * i) - widget.height / 2;
                        top += valueFraction;
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
                    (widget.labelBuilder != null
                        ? [widget.labelBuilder(value)]
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
                Text(
                  '+',
                  textScaleFactor: 0.75,
                ),
                Text(
                  '-',
                  textScaleFactor: 0.75,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
