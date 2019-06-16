import 'package:flutter/material.dart';
import 'package:curve_moderator/catmull_rom/curve_painter.dart';
import 'point2d.dart';

final defaultPointWidget = ClipRRect(
  borderRadius: BorderRadius.circular(10.0),
  child: Container(
    width: 20.0,
    height: 20.0,
    color: Colors.blue,
  ),
);

final maxPoints = 12;

class CurveEditor extends StatefulWidget {
  List<Point2D> points;
  Color curveColor;
  double curveWidth;
  Widget pointWidget;
  double pointWidgetSize;

  CurveEditor({
    Key key,
    @required this.points,
    this.curveColor = Colors.red,
    this.curveWidth = 3,
    this.pointWidget,
    this.pointWidgetSize = 20,
  }) {
    if (pointWidget == null) {
      pointWidget = defaultPointWidget;
    }
  }

  @override
  State<StatefulWidget> createState() {
    return _CurveEditorState(points);
  }
}

class _CurveEditorState extends State<CurveEditor> {
  List<Point2D> points;
  CurvePainter painter;

  _CurveEditorState(List<Point2D> points) {
    this.points = points;
    this.painter = CurvePainter(points: this.points);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    points = widget.points;

    return CustomPaint(
        painter: painter,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          // add points
          List<Widget> stackedWidgets = List();
          for (int i = 0; i < points.length; i++) {
            if (!(points[i].x == 0 && points[i].y == 0) &&
                !(points[i].y == 1 && points[i].x == 1)) {
              stackedWidgets.add(Positioned(
                  left: points[i].x * constraints.maxWidth -
                      widget.pointWidgetSize / 2,
                  top: constraints.maxHeight -
                      points[i].y * constraints.maxHeight -
                      widget.pointWidgetSize / 2,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        double newX = (points[i].x * constraints.maxWidth +
                                details.delta.dx) /
                            constraints.maxWidth;
                        double newY = (points[i].y * constraints.maxHeight -
                                details.delta.dy) /
                            constraints.maxHeight;

                        if (0 <= newX && newX <= 1 && 0 <= newY && newY <= 1) {
                          points[i].setLocation(
                              (points[i].x * constraints.maxWidth +
                                      details.delta.dx) /
                                  constraints.maxWidth,
                              (points[i].y * constraints.maxHeight -
                                      details.delta.dy) /
                                  constraints.maxHeight);
                        }
                      });
                    },
                    onTap: () {
                      print('tap');
                    },
                    child: Container(
                        width: widget.pointWidgetSize,
                        height: widget.pointWidgetSize,
                        child: widget.pointWidget),
                  )));
            }
          }

          // add gesture detector for adding new points
          stackedWidgets.add(Positioned.fill(child: GestureDetector(
            onTapUp: (TapUpDetails details) {
              RenderBox getBox = context.findRenderObject();
              Offset localOffset = getBox.globalToLocal(details.globalPosition);

              // only add if no point is within 4*r=2*pointWidgetSize
              bool canAdd = true;
              bool pointTapped = false;

              for (Point2D point in points) {
                double x =
                    point.x * constraints.maxWidth - widget.pointWidgetSize / 2;
                double y = point.y * constraints.maxHeight -
                    widget.pointWidgetSize / 2;

                if ((localOffset.dx - x).abs() < widget.pointWidgetSize * 2 &&
                    (constraints.maxHeight - localOffset.dy - y).abs() <
                        widget.pointWidgetSize * 2) {
                  canAdd = false;

                  // show remove dialog
                  if (!(point.x == 0 && point.y == 0) &&
                      !(point.x == 1 && point.y == 1)) {
                    pointTapped = true;
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text("Remove point?"),
                            actions: <Widget>[
                              new FlatButton(
                                child: new Text("Close"),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              new FlatButton(
                                child: new Text("Remove"),
                                onPressed: () {
                                  setState(() {
                                    points.remove(point);
                                    painter.updatePoints(points);
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  }

                  break;
                }
              }

              if (canAdd && points.length <= maxPoints) {
                setState(() {
                  points.add(Point2D(
                      localOffset.dx / constraints.maxWidth,
                      (constraints.maxHeight - localOffset.dy) /
                          constraints.maxHeight));
                  painter.updatePoints(points);
                });
              } else if (points.length >= maxPoints && !pointTapped) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content:
                      Text('Max number of points (${maxPoints - 2}) reached.'),
                  duration: Duration(seconds: 1),
                ));
              }
            },
          )));

          return Stack(
            children: stackedWidgets,
          );
        }));
  }
}
