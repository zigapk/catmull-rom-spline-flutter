import 'package:flutter/material.dart';
import 'curve_painter.dart';

class CurveModerator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CurveModeratorState();
  }
}

class _CurveModeratorState extends State<CurveModerator> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CurvePainter(),
      child: Center(
        child: Text("Blade Runner"),
      ),
    );
  }
}
