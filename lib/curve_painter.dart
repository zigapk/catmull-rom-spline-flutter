import "package:vector_math/vector_math.dart" as vectormath;
import 'package:flutter/material.dart';
import 'catmull_rom_spline.dart';
import 'dart:ui';
import 'dart:collection';
import 'spline_function.dart';

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var redPaint = Paint();
    redPaint.color = Colors.red;
    redPaint.strokeWidth = 12;
    var greenPaint = Paint();
    greenPaint.color = Colors.green;
    greenPaint.strokeWidth = 5;

    var p0 = Point2D(0, 0);
    var p1 = Point2D(0.25, 0.5);
    var p2 = Point2D(0.5, 0.3);
    var p3 = Point2D(1, 1);

    HashMap<double, double> controllPoints = HashMap<double, double>();
    controllPoints[p0.x] = p0.y;
    controllPoints[p1.x] = p1.y;
    controllPoints[p2.x] = p2.y;
    controllPoints[p3.x] = p3.y;

    SplineFunction mSpline = SplineFunction(controllPoints, false);
    List<Point2D> points = mSpline.getPoints();

    List<Offset> drawablePoints = List();

    for (int i = 0; i < points.length; i++) {
      drawablePoints.add(Offset(size.width*points[i].x, size.height*points[i].y));
    }

    canvas.drawPoints(PointMode.points, drawablePoints, redPaint);

    canvas.drawPoints(
        PointMode.points,
        [
          Offset(p0.x.toDouble() * size.width, p0.y.toDouble() * size.height),
          Offset(p1.x.toDouble() * size.width, p1.y.toDouble() * size.height),
          Offset(p2.x.toDouble() * size.width, p2.y.toDouble() * size.height),
          Offset(p3.x.toDouble() * size.width, p3.y.toDouble() * size.height)
        ],
        greenPaint);

//    print(points);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
