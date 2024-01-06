import 'package:flutter/material.dart';

class BottomClip extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.white;
    var path = Path();
    path.moveTo(0.0, 0.0);
    path.lineTo(0.0, 200);
    path.cubicTo(size.width - 300, 450, size.width - 50, 200, size.width, 450);
    path.lineTo(size.width, 0.0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
