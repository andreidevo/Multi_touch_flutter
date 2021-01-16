# Multi_touch_flutter


Hey!!!! IT IS Multi-touch flutter painter! 

Just copy-paste this screen and conteniue develiping your idea!

(get Star to this repo :)



Main part: (Other parts get in Dart file)
```
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
```

# Rait this repo :3 ThankSssssss
