import 'package:flutter/material.dart';
import 'point2d.dart';
import 'dart:ui';
import 'dart:collection';
import 'package:curve_moderator/catmull_rom/spline_function.dart';

final defaultLinearControlPoints = [Point2D(0, 0), Point2D(1, 1)];

class CurvePainter extends CustomPainter {
  bool shouldUpdate = false;
  Paint _curvePaint = Paint();
  Paint _pointsPaint = Paint();
  List<Point2D> _points = defaultLinearControlPoints;

  CurvePainter({
    List<Point2D> points: const [],
    Color curveColor: Colors.red,
    Color pointsColor: Colors.transparent,
    double curveWidth: 3,
    double dotsSize: 5,
  }) {
    _curvePaint.color = curveColor;
    _curvePaint.strokeWidth = curveWidth;
    _pointsPaint.color = pointsColor;
    _pointsPaint.strokeWidth = dotsSize;
    updatePoints(points);
  }

  void updatePoints(List<Point2D> points) {
    _points = points;
    if (_points.length <= 2) {
      _points = defaultLinearControlPoints;
    }

    shouldUpdate = true;
  }

  List<Point2D> getPoints() {
    return _points;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // generate hashmap
    HashMap<double, double> controlPoints = HashMap<double, double>();
    for (Point2D point in _points) {
      controlPoints[point.x] = point.y;
    }

    // create spline
    SplineFunction mSpline = SplineFunction(controlPoints);
    List<Point2D> points = mSpline.getPoints();
    
    // get points as drawable offsets
    List<Offset> drawablePoints = pointsToOffsets(points, size);

    // draw curve
    canvas.drawPoints(PointMode.polygon, drawablePoints, _curvePaint);

    // draw control points
    canvas.drawPoints(PointMode.points, pointsToOffsets(_points, size), _pointsPaint);
  }

  List<Offset> pointsToOffsets(List<Point2D> points, Size size) {
    List<Offset> result = List();
    for (Point2D point in points) {
      // invert y to get the mathematical coordinate system
      result.add(Offset(point.x * size.width, size.height - point.y * size.height));
    }
    return result;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (shouldUpdate) {
      shouldUpdate = false;
      return true;
    }
    return shouldUpdate;
  }
}
