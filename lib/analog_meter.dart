import 'dart:math';
import 'package:flutter/material.dart';

class AnalogMeter extends StatelessWidget {
  final double value;

  final double min;

  final double max;

  const AnalogMeter({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: CustomPaint(painter: _MeterPainter(value, min, max)),
    );
  }
}

class _MeterPainter extends CustomPainter {
  final double value;

  final double min;

  final double max;

  _MeterPainter(this.value, this.min, this.max);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radius = size.width * 0.38;

    canvas.drawCircle(
      center,
      radius + 35,
      Paint()
        ..color = const Color(0xff111827)
        ..style = PaintingStyle.fill,
    );

    final rect = Rect.fromCircle(center: center, radius: radius);

    const startAngle = pi * 0.75;

    const sweepAngle = pi * 1.5;

    double zone(double db) {
      return sweepAngle * (db / 120);
    }

    final green = Paint()
      ..color = Colors.green
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke;

    final yellow = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke;

    final orange = Paint()
      ..color = Colors.orange
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke;

    final red = Paint()
      ..color = Colors.red
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke;

    // 0 - 70 dBA

    canvas.drawArc(rect, startAngle, zone(70), false, green);

    // 70 - 75 dBA

    canvas.drawArc(rect, startAngle + zone(70), zone(5), false, yellow);

    // 75 - 90 dBA

    canvas.drawArc(rect, startAngle + zone(75), zone(15), false, orange);

    // 90 - 120 dBA

    canvas.drawArc(rect, startAngle + zone(90), zone(30), false, red);

    // POINTER

    final percent = ((value - min) / (max - min)).clamp(0.0, 1.0);

    final angle = startAngle + sweepAngle * percent;

    final needle = Offset(
      center.dx + cos(angle) * (radius - 20),

      center.dy + sin(angle) * (radius - 20),
    );

    canvas.drawLine(
      center,
      needle,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 4,
    );

    canvas.drawCircle(center, 8, Paint()..color = Colors.white);

    // VALUE TEXT

    final textPainter = TextPainter(
      text: TextSpan(
        text: "${value.toStringAsFixed(1)} dBA",

        style: const TextStyle(
          color: Colors.white,

          fontSize: 32,

          fontWeight: FontWeight.bold,
        ),
      ),

      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - 20),
    );

    // SCALE NUMBERS

    final labels = <double>[0, 30, 60, 75, 90, 120];

    for (final db in labels) {
      final labelAngle = startAngle + zone(db);

      final position = Offset(
        center.dx + cos(labelAngle) * (radius + 25),

        center.dy + sin(labelAngle) * (radius + 25),
      );

      final labelPainter = TextPainter(
        text: TextSpan(
          text: db.toStringAsFixed(0),

          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),

        textDirection: TextDirection.ltr,
      );

      labelPainter.layout();

      labelPainter.paint(
        canvas,
        Offset(
          position.dx - labelPainter.width / 2,

          position.dy - labelPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MeterPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
