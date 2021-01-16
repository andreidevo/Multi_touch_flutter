import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';


class Multi3 extends StatefulWidget{

  @override
  _Multi3 createState() => _Multi3();
}


Color globalColor = Colors.black; // for debug


double x = 0;
double y = 0;

double width = 0;
double height = 0;


Map<String, Object> objectsArr = {}; //массив для нажатий c сервера


class _Multi3 extends State<Multi3> with WidgetsBindingObserver{

  var rng = new Random();
  int id1 = 0; // ID user

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this); //some events of the flutter app: like resume / stop
    id1 = rng.nextInt(10000000);

  }


  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if(state == AppLifecycleState.paused){
      print("PAUSED");
      objectsArr = {};
      setState(() { });
      
    }
    if (state == AppLifecycleState.resumed)
      {
        print("RESUME");
      
      }
  }



  @override
  void dispose() {
    super.dispose();
    
    addictArr = {};
    setState(() { });
  }


  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        setState(() {
          x = e.position.dx.round().toDouble();
          y = (e.position.dy).round().toDouble();
          // e.pointer.toString() + "-"+ id1.toString() - it's like unic ID of finger

          objectsArr[e.pointer.toString() + "-"+ id1.toString()] =
              Object(x, y, e.pointer.toString() + "-"+ id1.toString());
        });
      },

      onPointerMove: (e) {
        setState(() {
          x = e.position.dx.round().toDouble();
          y = (e.position.dy).round().toDouble();

          objectsArr.update(e.pointer.toString() + "-"+ id1.toString(),
                  (value) => Object(x, y, e.pointer.toString() + "-"+ id1.toString()));
          
        });
      },

      onPointerUp: (e) {
        setState(() {
          x = e.position.dx.round().toDouble();
          y = (e.position.dy).round().toDouble();

          objectsArr.remove(e.pointer.toString() + "-"+ id1.toString());
        }
        );
      },

      // Idk, but maybe it's using in cancel (like movile off)
      onPointerCancel: (e) {
        setState(() {
          x = e.position.dx.round().toDouble();
          y = (e.position.dy).round().toDouble();
        });

      },
      child: Container(
        color: globalColor,
        child: CustomPaint(
          painter: ShapePainter(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {


  // Color for painting
  var painter = Paint()
    ..color = Colors.red
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;


  @override
  void paint(Canvas canvas, Size size) {

    // paint all circles
    objectsArr.forEach((key, value) {
      canvas.drawCircle(value.getOffset(), value.radius, painter);
    });
    
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // must have repaint
  }

}

class Object {

  double x = 0;
  double y = 0;
  String id = "0";


  Object(this.x, this.y, this.id);
  void setXY(double x, double y){
    this.x = x;
    this.y = y;
  }

  Offset getOffset(){
    return Offset(this.x, this.y);
  }

}
