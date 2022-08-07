import 'dart:math';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/container.dart';
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
    final width = 100.0;

    return WheelSpinner(
      value: value,
      width: width,
      min: 0.0,
      max: 100.0,
      onSlideUpdate: (val) => setState(() => value = val),
    );
  }
}
