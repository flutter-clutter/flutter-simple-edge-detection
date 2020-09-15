import 'dart:ui';
import 'package:flutter/material.dart';

class Magnifier extends StatefulWidget {
  const Magnifier({
    @required this.child,
    @required this.position,
    this.visible = true,
    this.scale = 2.0,
    this.alignment = Alignment.topLeft,
    this.size = const Size(160, 160),
    Key key
  }) : super(key: key);

  final Widget child;
  final Offset position;
  final bool visible;
  final double scale;
  final Alignment alignment;
  final Size size;

  @override
  _MagnifierState createState() => _MagnifierState();
}

class _MagnifierState extends State<Magnifier> {
  Size _magnifierSize;
  double _scale;
  Matrix4 _matrix;

  @override
  void initState() {
    _magnifierSize = widget.size;
    _scale = widget.scale;
    _calculateMatrix();

    super.initState();
  }

  @override
  void didUpdateWidget(Magnifier oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.visible) {
      return;
    }

    if (oldWidget.size != widget.size) {
      _magnifierSize = widget.size;
    }

    if (oldWidget.scale != widget.scale) {
      _scale = widget.scale;
      _matrix = Matrix4.identity()..scale(_scale);
    }

    _calculateMatrix();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.visible)
          _getMagnifier(context)
      ],
    );
  }

  void _calculateMatrix() {
    if (widget.position == null) {
      return;
    }

    setState(() {
      double newX =  widget.position.dx - (_magnifierSize.width / 2 / _scale);
      double newY =  widget.position.dy - (_magnifierSize.height / 2 / _scale);

      final Matrix4 updatedMatrix = Matrix4.identity()
        ..scale(_scale, _scale)
        ..translate(-newX, -newY);

      _matrix = updatedMatrix;
    });
  }

  Widget _getMagnifier(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.matrix(_matrix.storage),
          child: CustomPaint(
            painter: MagnifierPainter(
              color: Theme.of(context).accentColor
            ),
            size: _magnifierSize,
          ),
        ),
      ),
    );
  }
}

class MagnifierPainter extends CustomPainter {
  const MagnifierPainter({
    @required this.color,
    this.strokeWidth = 5
  });

  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
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

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}