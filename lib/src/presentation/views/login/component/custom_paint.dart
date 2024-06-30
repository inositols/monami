import 'package:flutter/material.dart';

class BottomClip extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.white;
    var path = Path()
      ..moveTo(0.0, 0.0)
      ..lineTo(0.0, 200)
      ..cubicTo(size.width - 300, 450, size.width - 50, 200, size.width, 450)
      ..lineTo(size.width, 0.0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
