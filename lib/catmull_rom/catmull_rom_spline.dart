import 'dart:math' as Math;
import 'point2d.dart';

class CatmullRomSpline {
  CatmullRomSpline.create(
      List<Point2D> points, int stepsPerSegment, double alpha,
      {bool closed = false}) {
    this.stepsPerSegment = stepsPerSegment;
    this.alpha = alpha;
    int numInterpolatedPoints = (((points.length - 1) * stepsPerSegment) + 1);
    if (closed) {
      numInterpolatedPoints += stepsPerSegment;
      this.controlPoints = createPoints(points.length + 3);
      this.controlPoints[1] = controlPoints[controlPoints.length - 2];
    } else {
      this.controlPoints = createPoints(points.length + 2);
    }
    this.interpolatedPoints = createPoints(numInterpolatedPoints);
    this.closed = closed;
    updateControlPoints(points);
  }

  double alpha;
  List<Point2D> controlPoints;
  int stepsPerSegment;
  List<Point2D> interpolatedPoints;
  bool updateRequired = true;
  bool closed;

  static List<Point2D> createPoints(int n) {
    List<Point2D> points = List<Point2D>();
    for (int i = 0; i < n; i++) {
      double value = i / n + 0.00001;
      points.add(Point2D(value, value));
    }
    return points;
  }

  void setInterpolation(double alpha) {
    this.alpha = alpha;
    updateRequired = true;
  }

  void updateControlPoint(int index, Point2D point) {
    int numPoints = (controlPoints.length - (closed ? 3 : 2));
    if (index < 0) {
      throw Exception(("Index $index") + " must be positive");
    }
    if (index >= (controlPoints.length - 1)) {
      throw Exception(((("Index was $index") + ", but number of control ") +
              "points was ") +
          numPoints.toString());
    }
    controlPoints[index + 1].copyLocation(point);
    updateRequired = true;
  }

  void updateControlPoints(List<Point2D> points) {
    int numPoints = (controlPoints.length - (closed ? 3 : 2));
    if (points.length != numPoints) {
      throw Exception(
          (("Expected " + numPoints.toString()) + " points, but got ") +
              points.length.toString());
    }
    for (int j = 0; j < points.length; j++) {
      Point2D p = points[j];
      controlPoints[j + 1].setLocation(p.x, p.y);
    }
    updateRequired = true;
  }

  List<Point2D> getInterpolatedPoints() {
    validatePoints();
    return interpolatedPoints;
  }

  void validatePoints() {
    if (updateRequired) {
      updateAdditionalControlPoints();
      updateInterpolatedPoints();
      updateRequired = false;
    }
  }

  void updateInterpolatedPoints() {
    int numPoints = (controlPoints.length - 2);
    for (int i = 0; i < (numPoints - 1); i++) {
      int stepsInCurrentSegment = stepsPerSegment;
      int lastStepInSegment = stepsInCurrentSegment;
      if (i == (numPoints - 2)) {
        stepsInCurrentSegment++;
        lastStepInSegment = (stepsInCurrentSegment - 1);
      }
      _updateInterpolatedPoints(i, stepsInCurrentSegment, lastStepInSegment);
    }
  }

  void updateAdditionalControlPoints() {
    if (closed) {
      Point2D py = controlPoints[controlPoints.length - 3];
      controlPoints[0].copyLocation(py);
      Point2D p1 = controlPoints[2];
      controlPoints[controlPoints.length - 1].copyLocation(p1);
    } else {
      Point2D p0 = controlPoints[1];
      Point2D p1 = controlPoints[2];
      Point2D cp0 = controlPoints[0];
      cp0 = sub(p1, p0);
      cp0 = sub(p0, cp0);
      Point2D py = controlPoints[controlPoints.length - 3];
      Point2D pz = controlPoints[controlPoints.length - 2];
      Point2D cpz = controlPoints[controlPoints.length - 1];
      cpz = sub(pz, py);
      cpz = add(pz, cpz);

      controlPoints[controlPoints.length - 3] = py;
      controlPoints[controlPoints.length - 2] = pz;
      controlPoints[controlPoints.length - 1] = cpz;
    }
  }

  Point2D sub(Point2D p0, Point2D p1) {
    return Point2D(p0.x - p1.x, p0.y - p1.y);
  }

  Point2D add(Point2D p0, Point2D p1) {
    return Point2D(p0.x + p1.x, p0.y + p1.y);
  }

  void _updateInterpolatedPoints(
      int index, int stepsInCurrentSegment, int lastStepInSegment) {
    Point2D p0 = controlPoints[index + 0];
    Point2D p1 = controlPoints[index + 1];
    Point2D p2 = controlPoints[index + 2];
    Point2D p3 = controlPoints[index + 3];
    double t0 = 0;
    double t1 = 1;
    double t2 = 2;
    double t3 = 3;
    if (alpha != 0) {
      double exponent = (alpha * 0.5);
      double dx01 = (p1.x - p0.x);
      double dy01 = (p1.y - p0.y);
      double d01 = ((dx01 * dx01) + (dy01 * dy01));
      t1 = (t0 + Math.pow(d01, exponent));

      double dx12 = (p2.x - p1.x);
      double dy12 = (p2.y - p1.y);
      double d12 = ((dx12 * dx12) + (dy12 * dy12));
      t2 = (t1 + Math.pow(d12, exponent));

      double dx23 = (p3.x - p2.x);
      double dy23 = (p3.y - p2.y);
      double d23 = ((dx23 * dx23) + (dy23 * dy23));
      t3 = (t2 + Math.pow(d23, exponent));

    }
    double invStep = (1.0 / lastStepInSegment).toDouble();
    for (int i = 0; i < stepsInCurrentSegment; i++) {
      double t = (i * invStep);
      int interpolatedPointIndex = ((index * stepsPerSegment) + i);
      Point2D interpolatedPoint = interpolate(p0, p1, p2, p3, t0, t1, t2, t3,
          t1 + (t * (t2 - t1)));
      interpolatedPoints[interpolatedPointIndex].setLocation(interpolatedPoint.x, interpolatedPoint.y);
    }
    
  }

  Point2D interpolate(Point2D p0, Point2D p1, Point2D p2, Point2D p3, double t0,
      double t1, double t2, double t3, double t) {
    double x0 = p0.x;
    double y0 = p0.y;
    double x1 = p1.x;
    double y1 = p1.y;
    double x2 = p2.x;
    double y2 = p2.y;
    double x3 = p3.x;
    double y3 = p3.y;
    double invDt01 = (1 / (t1 - t0)).toDouble();
    double invDt12 = (1 / (t2 - t1)).toDouble();
    double invDt23 = (1 / (t3 - t2)).toDouble();
    double f01a = ((t1 - t) * invDt01);
    double f01b = ((t - t0) * invDt01);
    double f12a = ((t2 - t) * invDt12);
    double f12b = ((t - t1) * invDt12);
    double f23a = ((t3 - t) * invDt23);
    double f23b = ((t - t2) * invDt23);
    double x01 = ((f01a * x0) + (f01b * x1));
    double y01 = ((f01a * y0) + (f01b * y1));
    double x12 = ((f12a * x1) + (f12b * x2));
    double y12 = ((f12a * y1) + (f12b * y2));
    double x23 = ((f23a * x2) + (f23b * x3));
    double y23 = ((f23a * y2) + (f23b * y3));
    double invDt02 = (1 / (t2 - t0)).toDouble();
    double invDt13 = (1 / (t3 - t1)).toDouble();
    double f012a = ((t2 - t) * invDt02);
    double f012b = ((t - t0) * invDt02);
    double f123a = ((t3 - t) * invDt13);
    double f123b = ((t - t1) * invDt13);
    double x012 = ((f012a * x01) + (f012b * x12));
    double y012 = ((f012a * y01) + (f012b * y12));
    double x123 = ((f123a * x12) + (f123b * x23));
    double y123 = ((f123a * y12) + (f123b * y23));
    double resultX = ((f12a * x012) + (f12b * x123));
    double resultY = ((f12a * y012) + (f12b * y123));
    return Point2D(resultX, resultY);
  }
}
