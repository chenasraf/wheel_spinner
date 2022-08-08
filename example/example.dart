import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wheel_spinner/wheel_spinner.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late double value;

  @override
  void initState() {
    value = Random().nextDouble() * 100;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 100,
        height: 60,
        child: WheelSpinnerTheme(
          data: WheelSpinnerThemeData.light().copyWith(
            borderRadius: BorderRadius.circular(10),
            dividerColor: Colors.black,
          ),
          child: WheelSpinner(
            value: value,
            min: 0.0,
            max: 100.0,
            onSlideUpdate: (val) => setState(() => value = val),
          ),
        ),
      ),
    );
  }
}
