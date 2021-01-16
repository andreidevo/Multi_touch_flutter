import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';
import 'dart:math';


class Multi3 extends StatefulWidget{

  @override
  _Multi3 createState() => _Multi3();
}


bool vibrateChe = true; // можно ли вибрировать


Color globalColor = Colors.black; // для дебага использовалось


double x = 0;
double y = 0;

double width = 0;
double height = 0;


Map<String, Object> objectsArr = {}; //массив для нажатий c сервера
Map<String, Object> addictArr = {}; //массив для нажатий юзера




class _Multi3 extends State<Multi3> with WidgetsBindingObserver{

  var rng = new Random();
  int id1 = 0;



  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance.addObserver(this);
    id1 = rng.nextInt(10000000); // айдишник юзера - надо заменить на айди firebase потом
    vibrateChe = true; // можно ли вибрировать
    init();
    monitor(); //мониторим изменения из базы в firebase

  }

  int lenAddict = 0;
  void monitor(){

    // как только на сервере изменение - берем данные с него и превращаем в addictArr,
    // который потом рисуется на экране из-за setState{}
    databaseReference
        .onValue.listen((event) {
      var snapshot = event.snapshot;

      Map<dynamic, dynamic> values = snapshot.value;
      lenAddict = addictArr.length;

      addictArr = {};

      if (values != null){

          values.forEach((key, value) {
          if (!key.toString().contains(id1.toString()))
              addictArr[key] = Object(value['x'].toDouble(), value['y'].toDouble(), key);

          //lenAddict - если уже вибрируте, то не надо еще раз.
          //lenAddict = 0 значит нет вибрации, значит включить.

          if (lenAddict == 0 && addictArr.length > 0) {
            lenAddict++;

            if (vibrateChe)
                Vibration.vibrate(duration: 10000000);
          }

        });
      }
      else{
        Vibration.cancel();
        lenAddict = 0;
      }
      setState(() {

      });
    });

  }


  bool canVibrate = false;
  Future <Null> init() async {

    //это проверки на совместимости вибрации, может будет полезно, не убираю.
    print(await Vibration.hasAmplitudeControl());
    print(await Vibration.hasCustomVibrationsSupport());

  }


  final databaseReference = FirebaseDatabase.instance.reference();



  void showSnackbar(String message) {

    try{
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
    }
    catch(Ex){}

  }

  // этот класс мониторит состояния активности

  // собственно проблема, которую я не смог решить - как при выключении экрана удалять нажатия из локальной базы и с firebase (иначе нажатия остаются там)
  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {

    //если приложение на паузе - стираем все локальные нажатия на сервере (иначе плохо выходит)

    if(state == AppLifecycleState.paused){
      print("PAUSED");

      objectsArr.forEach((key, value) {
        databaseReference.child(key).remove();
      });

      objectsArr = {};

      setState(() { });
    }

    if (state == AppLifecycleState.resumed)
      {
        vibrateChe = true;
        print("RESUME");
      }
  }



  @override
  void dispose() {
    super.dispose();
    vibrateChe = false;

    print("DISPOSE");

    Vibration.cancel();
    WidgetsBinding.instance.removeObserver(this);


    //удаление всех нажатий из файрбейза
    objectsArr.forEach((key, value) {
      databaseReference.child(key).remove();
    });

    objectsArr = {};
    addictArr = {};
    setState(() { });
  }






  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double scale = (height / 255); //255 потому что интенсивность [1-255]

    return Listener(
      //когда какой-то палец нажали
      //берем координаты и записываем уникальный id в локальную базу objectsArr
      //и заодно отправляем в базу firebase.
      onPointerDown: (e) {

        setState(() {
          x = e.position.dx.round().toDouble();
          y = (e.position.dy).round().toDouble();
          // e.pointer.toString() + "-"+ id1.toString() - это уникальный айдишник
          // e.pointer - это айди ивента, а id1 это просто при входе в прилоежние рандомно число
          // можно потом заменить id1 на ID firebase, который получили при регистрации.

          objectsArr[e.pointer.toString() + "-"+ id1.toString()] =
              Object(x, y, e.pointer.toString() + "-"+ id1.toString());
        });


        // тут высчитывает интенсивонсть снизу вверх, но пока никак не используется (но думаю пригодится)
        int intensive = 255 - (y / scale).toInt();
        if (intensive < 2) intensive = 2;
        if (intensive > 255) intensive = 255;
        print(intensive);


        // собственно создание точки в базе firebase
        databaseReference.child(e.pointer.toString() + "-"+ id1.toString()).set({
          'x': x,
          'y': y
        });

        // эта штука сделана, если вибрацию захотим отлюкчить в фоне, но щас вроде всегда true.
        if (vibrateChe)
          Vibration.vibrate(duration: 100000);

      },

      // при движении мальца всё как обычно, изменяются координаты
      onPointerMove: (e) {
        setState(() {
          x = e.position.dx.round().toDouble();
          y = (e.position.dy).round().toDouble();

          objectsArr.update(e.pointer.toString() + "-"+ id1.toString(),
                  (value) => Object(x, y, e.pointer.toString() + "-"+ id1.toString()));

          databaseReference.child(e.pointer.toString() + "-"+ id1.toString()).set({
            'x': x,
            'y': y
          });
        });
      },

      //тут прекращаются вибрация и удаляются точки
      onPointerUp: (e) {

        Vibration.cancel();

        setState(() {
          x = e.position.dx.round().toDouble();
          y = (e.position.dy).round().toDouble();

          objectsArr.remove(e.pointer.toString() + "-"+ id1.toString());

          databaseReference.child(e.pointer.toString() + "-"+ id1.toString()).remove();
        }
        );
      },

      // хз не используется, но может быть полезным.
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


  // цвета для локальных нажатий и нажатий с сервера (другого чела)
  var painter = Paint()
    ..color = Colors.red
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;


  var painterOther = Paint()
    ..color = Colors.blue
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;



  @override
  void paint(Canvas canvas, Size size) {

    // рисуем локальные нажатия
    objectsArr.forEach((key, value) {
      canvas.drawCircle(value.getOffset(), value.radius, painter);
    });

    // рисуем нажатия с сервера
    addictArr.forEach((key, value) {
      canvas.drawCircle(value.getOffset(), value.radius, painterOther);
    });


  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}

class Object {

  //это всё можно удалить, кроме x y и id
  double width = 20;
  double height = 20;
  double radius = 50;
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
