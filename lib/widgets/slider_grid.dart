import 'package:flutter/material.dart';

class CircleThumbShape extends SliderComponentShape {
  final double thumbRadius;

  const CircleThumbShape({
    this.thumbRadius = 6.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    // We need to draw the thumb here
    final Canvas canvas = context.canvas;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, thumbRadius, fillPaint);
    canvas.drawCircle(center, thumbRadius, borderPaint);
  }
}

Widget getSliderWidgetWithLabel(
    String columnName, double value, void Function(double) onchanged,
    {double min = 0, double max = 100}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        columnName,
        style: const TextStyle(color: Colors.black54, fontSize: 12),
      ),
      const SizedBox(height: 10),
      SliderTheme(
        data: SliderThemeData(
          overlayShape: SliderComponentShape.noOverlay,
          trackHeight: 6,
          activeTrackColor: Colors.lightBlueAccent,
          inactiveTrackColor: const Color(0xFFEEEEEE),
          thumbColor: Colors.white,
          thumbShape: const CircleThumbShape(),
          // trackShape:
        ),
        child: Slider(
          value: value,
          label: value.toString(),
          min: min,
          max: max,
          onChanged: onchanged,
        ),
      ),
    ],
  );
}
