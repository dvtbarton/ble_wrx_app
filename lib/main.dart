import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(ColorwheelApp());

class ColorwheelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Color> colorWheelColors = fillColorWheel(colors: new List<Color>());
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: ColorWheelTouch(colorWheel: colorWheelColors),
        ),
      ),
    );
  }
}

class ColorWheelTouch extends StatefulWidget {
  const ColorWheelTouch({
    Key key,
    @required this.colorWheel,
  }) : super(key: key);

  final List<Color> colorWheel;

  @override
  _ColorWheelTouchState createState() => _ColorWheelTouchState();
}

class _ColorWheelTouchState extends State<ColorWheelTouch> {
  int colorValue = 0;

  void setColorValue(int newColorValue) {
    setState(() {
      colorValue = newColorValue;
    });
    print('colorValue set to: 0x' + colorValue.toRadixString(16));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 2,
          child: ColorWheelGestureDetector(
            widget: widget,
            setColorValue: setColorValue,
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            foregroundDecoration: BoxDecoration(
              color: Color(colorValue),
            ),
          ),
        ),
      ],
    );
  }
}

class ColorWheelGestureDetector extends StatelessWidget {
  ColorWheelGestureDetector(
      {@required this.widget, @required this.setColorValue});

  final ColorWheelTouch widget;
  final Function setColorValue;

  Offset getCenter(BuildContext context) {
    var center = context.findRenderObject() as RenderBox;
    return center.paintBounds.center;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails tapDeets) {
        Offset center = getCenter(context);
        var centered = tapDeets.localPosition - center;
        var theta = atan2(centered.dy, centered.dx);
        var elementMap = widget.colorWheel.length / (2 * pi);
        int element = (theta * elementMap).round();
        if (element < 0) element += (widget.colorWheel.length);
        setColorValue(widget.colorWheel.elementAt(element).value);
      },
      child: Container(
        decoration: ShapeDecoration(
          gradient: SweepGradient(
            colors: widget.colorWheel,
          ),
          shape: CircleBorder(
            side: BorderSide(),
          ),
        ),
      ),
    );
  }
}

List<Color> fillColorWheel({List<Color> colors}) {
  // Starts with red on the left side of the circle (0°)
  // and sweeps clockwise from red to blue, blue to green, green to red
  //..............alpha  R  G  B
  // red to purple 0xFF FF 00 ↑↑
  for (var i = 1; i <= 0xff; i++) {
    colors.add(Color(0xFFFF0000 + i));
  }

  //...............alpha  R  G  B
  // purple to blue 0xFF ↓↓ 00 FF
  for (var i = 1; i < 0xff; i++) {
    colors.add(Color(0xFFFF00FF - (i << 0x10)));
  }

  //.............alpha  R  G  B
  // blue to cyan 0xFF 00 ↑↑ FF
  for (var i = 1; i < 0xff; i++) {
    colors.add(Color(0xFF0000FF + (i << 0x8)));
  }

  //..............alpha  R  G  B
  // cyan to green 0xFF 00 FF ↓↓
  for (var i = 1; i <= 0xff; i++) {
    colors.add(Color(0xFF00FFFF - i));
  }

  //................alpha  R  G  B
  // green to yellow 0xFF ↑↑ FF 00
  for (var i = 1; i < 0xff; i++) {
    colors.add(Color(0xFF00FF00 + (i << 0x10)));
  }

  //..............alpha  R  G  B
  // yellow to red 0xFF FF ↓↓ 00
  for (var i = 1; i < 0xff; i++) {
    colors.add(Color(0xFFFFFF00 - (i << 0x8)));
  }

  return colors;
}
