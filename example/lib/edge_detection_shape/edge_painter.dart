import 'dart:ui';

import 'package:flutter/material.dart';

class EdgePainter extends CustomPainter {
  EdgePainter({
    @required this.points,
    @required this.color
  });

  final List<Offset> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(PointMode.polygon, points, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}