class Point2D {
  double x;
  double y;

  Point2D(double x, double y) {
    this.x = x;
    this.y = y;
  }

  void setLocation(double x, double y) {
    this.x = x;
    this.y = y;
  }

  void copyLocation(Point2D point) {
    this.x = point.x;
    this.y = point.y;
  }
}
