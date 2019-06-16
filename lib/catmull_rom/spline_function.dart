import 'point2d.dart';
import 'package:curve_moderator/catmull_rom/catmull_rom_spline.dart';
import 'dart:collection';

class SplineFunction {
  static const int N_STEPS = 100;
  CatmullRomSpline mSpline;
  double mLastY;
  List<Point2D> mControlPoints = List<Point2D>();
  List<Point2D> mInterpolatedPoints;
  int mPerSegment;

  SplineFunction(HashMap<double, double> points, {bool linear: false}) {
    if (points.length < 2) {
      mControlPoints.clear();
      mControlPoints.add(Point2D(-1, -1));
      mControlPoints.add(Point2D(1, 1));
    }
    mControlPoints = pointsToPoint2DfromHashMap(points);
    if (linear) {
      mInterpolatedPoints = mControlPoints;
      return;
    }
    mLastY = mControlPoints[mControlPoints.length - 1].y;
    mPerSegment = (N_STEPS ~/ points.length);
    mSpline = CatmullRomSpline.create(mControlPoints, mPerSegment, 0.5,
        closed: false);
    makeFunction();
  }

  static SplineFunction fromPoints2D(List<Point2D> points) {
    HashMap<double, double> newPoints = HashMap();
    for (Point2D point in points) newPoints[point.x] = point.y;
    return SplineFunction(newPoints);
  }

  // linear approximation of the spline function for given value
  double value(double position) {
    if (position < 0) position = 0;
    if (position > 1) position = 1;

    if (position == 0) return 0;
    if (position == 1) return 1;

    // find the first point where x > position
    int index = 0;
    for (int i = 0; i < mInterpolatedPoints.length; i++) {
      if (position < mInterpolatedPoints[i].x) {
        index = i;
        break;
      }
    }

    // linear between this and previous point
    double k =
        (mInterpolatedPoints[index].y - mInterpolatedPoints[index - 1].y) /
            (mInterpolatedPoints[index].x - mInterpolatedPoints[index - 1].x);
    double n = mInterpolatedPoints[index].y - k * mInterpolatedPoints[index].x;
    double result = k * position + n;

    if (result < 0) result = 0;
    if (result > 1) result = 1;
    return result;
  }

  void makeFunction() {
    List<Point2D> interpolatedPoints = mSpline.getInterpolatedPoints();
    interpolatedPoints = removeNonMonotonic(interpolatedPoints);
    fitBounds(interpolatedPoints);
    mInterpolatedPoints = interpolatedPoints;
  }

  List<Point2D> removeNonMonotonic(List<Point2D> points) {
    List<double> xVals = List<double>();
    for (Point2D point in points) {
      xVals.add(point.x);
    }
    int offset = 0;
    for (int i = 0; i < (mControlPoints.length - 1); i++) {
      int intervalStart = (((i - offset) * mPerSegment) + offset);
      for (int j = intervalStart; j < (intervalStart + mPerSegment); j++) {
        if (points[j].x > points[j + 1].x) {
          for (int g = 0; g < (mPerSegment - 1); g++) {
            points.remove(intervalStart + 1);
          }
          offset += 1;
          break;
        }
      }
    }
    for (int i = 1; i < points.length; i++) {
      while ((i < points.length) && (points[i - 1].x >= points[i].x)) {
        points.removeAt(i);
      }
    }
    List<double> x = List<double>(points.length);
    int i = 0;
    for (Point2D point in points) {
      x[i++] = point.x;
    }
    return points;
  }

  void fitBounds(List<Point2D> points) {
    for (int i = 0; i < points.length; i++) {
      Point2D point = points[i];
      if (point.y < (-1)) {
        points[i] = Point2D(point.x, -1);
      } else {
        if (point.y > 1) {
          points[i] = Point2D(point.x, 1);
        }
      }
    }
  }

  List<Point2D> pointsToPoint2DfromHashMap(HashMap<double, double> points) {
    List<double> keys = points.keys.toList();
    keys.sort();
    List<Point2D> result = List<Point2D>();
    for (double point_x in keys) {
      result.add(Point2D(point_x, points[point_x]));
    }
    return result;
  }

  List<Point2D> pointsToPoint2D(List<double> x, List<double> y) {
    List<Point2D> result = List<Point2D>();
    for (int i = 0; i < x.length; i++) {
      result.add(Point2D(x[i], y[i]));
    }
    return result;
  }

  List<Point2D> getPoints() {
    return mInterpolatedPoints;
  }
}
