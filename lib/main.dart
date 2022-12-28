import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

void main() => runApp(ColorwheelApp());

class ColorwheelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Color>? colorWheelColors = [];
    colorWheelColors = fillColorWheel(colors: colorWheelColors);

    return MaterialApp(
        theme: ThemeData.dark()
            .copyWith(scaffoldBackgroundColor: Color(0xFF1A1A1A)),
        home: ColorWheelTouch(colorWheel: colorWheelColors));
  }
}

class ColorWheelTouch extends StatefulWidget {
  const ColorWheelTouch({
    Key? key,
    /*required*/ required this.colorWheel,
  }) : super(key: key);

  final List<Color>? colorWheel;

  @override
  _ColorWheelTouchState createState() => _ColorWheelTouchState();
}

class _ColorWheelTouchState extends State<ColorWheelTouch> {
  int colorWheelValue = 0xFFFF0000;
  int appBarColor = 0xFFFF0000;
  int colorLED = 0xFF0000; // to be sent over Bluetooth
  int r = 0;
  int g = 0;
  int b = 0;
  double dimValue = 1.0;
  double whiteValue = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(appBarColor),
      ),
      body: SafeArea(
        child: Column(
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
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 30,
                trackShape: GradientRectSliderTrackShape(
                  startColor: Color(0xFF000000), // black
                  endColor: Color(colorWheelValue),
                ),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 30),
              ),
              child: Slider(
                value: dimValue,
                min: 0,
                max: 1.0,
                onChanged: (newValue) {
                  setState(() {
                    setLedDim(newValue);
                    setAppBarColor((0xFF << 0x18) + colorLED);
                  });
                },
              ),
            ),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 30,
                trackShape: GradientRectSliderTrackShape(
                  startColor: Color(0xFFFFFFFF),
                  endColor: Color(colorWheelValue),
                ),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 30),
              ),
              child: Slider(
                value: whiteValue,
                min: 0,
                max: 1.0,
                onChanged: (newValue) {
                  setState(() {
                    setLedWhite(newValue);
                    setAppBarColor((0xFF << 0x18) + colorLED);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setColorValue(int newColorValue) {
    setState(() {
      colorWheelValue = newColorValue;
      setLedWhite(whiteValue);
      setAppBarColor((0xFF << 0x18) + colorLED);
      setLedDim(dimValue);
      setAppBarColor((0xFF << 0x18) + colorLED);
    });
    print('colorValue set to: 0x' + colorWheelValue.toRadixString(16));
    print('appBarColor set to: 0x' + appBarColor.toRadixString(16));
  }

  void setLedWhite(double newWhiteValue) {
    whiteValue = newWhiteValue;

    r = (colorWheelValue >> 0x10) & 0xFF;
    g = (colorWheelValue >> 0x08) & 0xFF;
    b = colorWheelValue & 0xFF;

    r += ((0xFF - r).toDouble() * (1 - newWhiteValue)).round();
    g += ((0xFF - g).toDouble() * (1 - newWhiteValue)).round();
    b += ((0xFF - b).toDouble() * (1 - newWhiteValue)).round();

    print('r = 0x' +
        r.toRadixString(16) +
        '\n' +
        'g = 0x' +
        g.toRadixString(16) +
        '\n' +
        'b = 0x' +
        b.toRadixString(16));

    colorLED = (r << 0x10) + (g << 0x08) + (b);
    print('colorLEDwhite = 0x' + colorLED.toRadixString(16));
  }

  void setLedDim(double newDimValue) {
    dimValue = newDimValue;

    // extract the individual rgb values
    r = (colorWheelValue >> 0x10) & 0xFF;
    g = (colorWheelValue >> 0x08) & 0xFF;
    b = colorWheelValue & 0xFF;

    // apply the dimness
    r = (r.toDouble() * newDimValue).round();
    g = (g.toDouble() * newDimValue).round();
    b = (b.toDouble() * newDimValue).round();
    print('r = 0x' +
        r.toRadixString(16) +
        '\n' +
        'g = 0x' +
        g.toRadixString(16) +
        '\n' +
        'b = 0x' +
        b.toRadixString(16));

    colorLED = (r << 0x10) + (g << 0x08) + (b);
    print('colorLEDdim = 0x' + colorLED.toRadixString(16));
  }

  void setAppBarColor(int newColor) {
    appBarColor = newColor;
  }
}

class ColorWheelGestureDetector extends StatelessWidget {
  ColorWheelGestureDetector(
      {required this.widget, required this.setColorValue});

  final ColorWheelTouch widget;
  final Function setColorValue;

  // get center of wheel, since it will be offset in the column
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
        var elementMap = widget.colorWheel!.length / (2 * pi);
        int element = (theta * elementMap).round();
        if (element < 0) element += (widget.colorWheel!.length);
        setColorValue(widget.colorWheel!.elementAt(element).value);
      },
      child: Container(
        decoration: ShapeDecoration(
          gradient: SweepGradient(
            colors: widget.colorWheel!,
          ),
          shape: CircleBorder(
            side: BorderSide(),
          ),
        ),
      ),
    );
  }
}

List<Color>? fillColorWheel({List<Color>? colors}) {
  // Starts with red on the left side of the circle (0°)
  // and sweeps clockwise from red to blue, blue to green, green to red
  //..............alpha  R  G  B
  // red to purple 0xFF FF 00 ↑↑
  for (var i = 1; i <= 0xff; i++) {
    colors!.add(Color(0xFFFF0000 + i));
  }

  //...............alpha  R  G  B
  // purple to blue 0xFF ↓↓ 00 FF
  for (var i = 1; i < 0xff; i++) {
    colors!.add(Color(0xFFFF00FF - (i << 0x10)));
  }

  //.............alpha  R  G  B
  // blue to cyan 0xFF 00 ↑↑ FF
  for (var i = 1; i < 0xff; i++) {
    colors!.add(Color(0xFF0000FF + (i << 0x8)));
  }

  //..............alpha  R  G  B
  // cyan to green 0xFF 00 FF ↓↓
  for (var i = 1; i <= 0xff; i++) {
    colors!.add(Color(0xFF00FFFF - i));
  }

  //................alpha  R  G  B
  // green to yellow 0xFF ↑↑ FF 00
  for (var i = 1; i < 0xff; i++) {
    colors!.add(Color(0xFF00FF00 + (i << 0x10)));
  }

  //..............alpha  R  G  B
  // yellow to red 0xFF FF ↓↓ 00
  for (var i = 1; i < 0xff; i++) {
    colors!.add(Color(0xFFFFFF00 - (i << 0x8)));
  }

  return colors;
}

/// Based on https://www.youtube.com/watch?v=Wl4F5V6BoJw
class GradientRectSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  /// Create a slider track that draws two rectangles with rounded outer edges.
  const GradientRectSliderTrackShape(
      {required this.startColor, required this.endColor});
  final Color startColor;
  final Color endColor;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    assert(context != null);
    assert(offset != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(enableAnimation != null);
    assert(textDirection != null);
    assert(thumbCenter != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting  can be a no-op.
    if (sliderTheme.trackHeight! <= 0) {
      return;
    }

    LinearGradient gradient = LinearGradient(colors: <Color>[
      startColor,
      endColor,
    ]);

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()
      ..shader = gradient.createShader(trackRect)
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..shader = gradient.createShader(trackRect)
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    late Paint leftTrackPaint;
    late Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    final Radius trackRadius = Radius.circular(trackRect.height / 2);
    final Radius activeTrackRadius = Radius.circular(trackRect.height / 2 + 1);

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left,
        (textDirection == TextDirection.ltr)
            ? trackRect.top - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        thumbCenter.dx,
        (textDirection == TextDirection.ltr)
            ? trackRect.bottom + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        topLeft: (textDirection == TextDirection.ltr)
            ? activeTrackRadius
            : trackRadius,
        bottomLeft: (textDirection == TextDirection.ltr)
            ? activeTrackRadius
            : trackRadius,
      ),
      leftTrackPaint,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        thumbCenter.dx,
        (textDirection == TextDirection.rtl)
            ? trackRect.top - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        trackRect.right,
        (textDirection == TextDirection.rtl)
            ? trackRect.bottom + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        topRight: (textDirection == TextDirection.rtl)
            ? activeTrackRadius
            : trackRadius,
        bottomRight: (textDirection == TextDirection.rtl)
            ? activeTrackRadius
            : trackRadius,
      ),
      rightTrackPaint,
    );
  }
}
