import 'package:flutter/material.dart';

void main() => runApp(ColorwheelApp());

class ColorwheelApp extends StatelessWidget {
  final List<Color> colorWheel = [Color(0xFFFF0000)];

  @override
  Widget build(BuildContext context) {
    fillColorWheel(colorWheel);
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Container(
            decoration: ShapeDecoration(
              gradient: SweepGradient(
                colors: colorWheel,
              ),
              shape: CircleBorder(
                side: BorderSide(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void fillColorWheel(List<Color> colors) {
  // red to purple 0xFF FF 00 ↑↑
  for (var i = 1; i <= 0xff; i++) {
    colors.add(Color(0xFFFF0000 + i));
  }

  // purple to blue 0xFF ↓↓ 00 FF
  for (var i = 1; i < 0xff; i++) {
    colors.add(Color(0xFFFF00FF - (i << 0x10)));
  }

  // blue to cyan 0xFF 00 ↑↑ FF
  for (var i = 1; i < 0xff; i++) {
    colors.add(Color(0xFF0000FF + (i << 0x8)));
  }

  // cyan to green 0xFF 00 FF ↓↓
  for (var i = 1; i <= 0xff; i++) {
    colors.add(Color(0xFF00FFFF - i));
  }

  // green to yellow 0xFF ↑↑ FF 00
  for (var i = 1; i < 0xff; i++) {
    colors.add(Color(0xFF00FF00 + (i << 0x10)));
  }

  // yellow to red 0xFF FF ↓↓ 00
  for (var i = 1; i < 0xff; i++) {
    colors.add(Color(0xFFFFFF00 - (i << 0x8)));
  }
}
