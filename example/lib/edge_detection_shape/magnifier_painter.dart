import 'package:flutter/material.dart';

class MagnifierPainter extends CustomPainter {
  const MagnifierPainter({
    @required this.color,
    this.strokeWidth = 5
  });

  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    _drawCircle(canvas, size);
    _drawCrosshair(canvas, size);
  }

  void _drawCircle(Canvas canvas, Size size) {
    Paint paintObject = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;

    canvas.drawCircle(
      size.center(
        Offset(0, 0)
      ),
      size.longestSide / 2, paintObject
    );
  }

  void _drawCrosshair(Canvas canvas, Size size) {
    Paint crossPaint = Paint()
      ..strokeWidth = strokeWidth / 2
      ..color = color;

    double crossSize = size.longestSide * 0.04;

    canvas.drawLine(
      size.center(Offset(-crossSize, -crossSize)),
      size.center(Offset(crossSize, crossSize)),
      crossPaint
    );

    canvas.drawLine(
      size.center(Offset(crossSize, -crossSize)),
      size.center(Offset(-crossSize, crossSize)),
      crossPaint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}