import 'catmull_rom_spline.dart';
import 'dart:collection';

class SplineFunction {
  static final String TAG = "SplineFunction";
  static const int N_STEPS = 100;
  CatmullRomSpline mSpline;
  double mLastY;
  List<Point2D> mControlPoints = List<Point2D>();
  List<Point2D> mInterpolatedPoints;
  int mPerSegment;

  SplineFunction(HashMap<double, double> points, bool linear) {
    if (points.length < 2) {
      mControlPoints.clear();
      mControlPoints.add(Point2D(-1, -1));
      mControlPoints.add(Point2D(1, 1));
    }
    mControlPoints = pointsToPoint2DfromHashMap(points);
    if (linear) {
//      makeLinearFunction(mControlPoints);
      mInterpolatedPoints = mControlPoints;
      return;
    }
    mLastY = mControlPoints[mControlPoints.length - 1].y;
    mPerSegment = (N_STEPS ~/ points.length);
    mSpline = CatmullRomSpline.create(mControlPoints, mPerSegment, 0.5,
        closed: false);
    makeFunction();
  }

  /*SplineFunction splineFunctionFromList(List<double> x, List<double> y) {
    if (x.length < 2) {
      mControlPoints.clear();
      mControlPoints.add(Point2D(-1, -1));
      mControlPoints.add(Point2D(1, 1));
    } else {
      mControlPoints = pointsToPoint2D(x, y);
    }
    mLastY = mControlPoints[mControlPoints.length - 1].y;
    mPerSegment = (N_STEPS ~/ mControlPoints.length);
    mSpline = CatmullRomSpline.create(mControlPoints, mPerSegment, 0.5, closed: false);
    makeFunction();
  }*/ //TODO: does not return since it was a constructor before conversion

  void makeFunction() {
    List<Point2D> interpolated_points = mSpline.getInterpolatedPoints();
    interpolated_points = removeNonMonotonic(interpolated_points);
//    fitBounds(interpolated_points);
    mInterpolatedPoints = interpolated_points;
//    makeLinearFunction(interpolated_points);
    print('asdf');
  }

  /*void makeLinearFunction(List<Point2D> points) {
    List<double> x = List<double>(points.length);
    List<double> y = List<double>(points.length);
    int i = 0;
    for (Point2D point in points) {
      x[i] = point.x;
      y[i++] = point.y;
    }
    mFunction = mInterpolator.interpolate(x, y);
  }*/

  List<Point2D> removeNonMonotonic(List<Point2D> points) {
    List<double> x_vals = List<double>();
    for (Point2D point in points) {
      x_vals.add(point.x);
    }
    int offset = 0;
    for (int i = 0; i < (mControlPoints.length - 1); i++) {
      int interval_start = (((i - offset) * mPerSegment) + offset);
      for (int j = interval_start; j < (interval_start + mPerSegment); j++) {
        if (points[j].x > points[j + 1].x) {
          for (int g = 0; g < (mPerSegment - 1); g++) {
            points.remove(interval_start + 1);
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

  /*double value(double x) {
    if (x <= (-1)) {
      x = (-0.9999999);
    }
    if (x >= 1) {
      x = 0.9999999;
    }
    return mFunction.value(x);
  }*/

  List<Point2D> getPoints() {
    return mInterpolatedPoints;
  }

  double lastval() {
    return mLastY;
  }
}
