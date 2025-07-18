import 'package:flutter/material.dart';

class AbstractBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = const Color(0xFF264653); // dark green
    final paint2 = Paint()..color = const Color(0xFFFFC300); // yellow
    final paint3 = Paint()..color = const Color(0xFFE76F51); // orange

    canvas.drawArc(
        Rect.fromCircle(center: Offset(0, size.height), radius: 60),
        0,
        3.14,
        true,
        paint1);

    canvas.drawCircle(Offset(size.width, 0), 40, paint2);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.6), 30, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
