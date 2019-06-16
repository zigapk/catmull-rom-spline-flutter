import 'package:flutter/material.dart';
import 'package:curve_moderator/catmull_rom/curve_editor.dart';
import 'catmull_rom/point2d.dart';
import 'catmull_rom/spline_function.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // create CurveEditor
  CurveEditor curveEditor = CurveEditor(points: [Point2D(0, 0), Point2D(1, 1)]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: curveEditor,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.details),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                // get points from curveEditor
                List<Point2D> points = curveEditor.points;

                // create curve
                SplineFunction spline = SplineFunction.fromPoints2D(points);

                // get y values
                String yValues = '';
                for (int i = 0; i < 20; i++) {
                  yValues += '${spline.value(i*0.05).toString()}, ';
                }

                return AlertDialog(
                  title: Text('Spline y values'),
                  content: Text(yValues),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Close'),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                );
              }
          );
        },
      ),
    );
  }
}
