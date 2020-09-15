import 'package:flutter/material.dart';

import 'animated_touch_bubble_part.dart';

class TouchBubble extends StatefulWidget {
  TouchBubble({
    @required this.size,
    @required this.onDrag,
    @required this.onDragFinished,
  });

  final double size;
  final Function onDrag;
  final Function onDragFinished;

  @override
  _TouchBubbleState createState() => _TouchBubbleState();
}

class _TouchBubbleState extends State<TouchBubble> {
  bool dragging = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _startDragging,
      onPanUpdate: _drag,
      onPanCancel: _cancelDragging,
      onPanEnd: (_) => _cancelDragging(),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.size / 2)
        ),
        child: AnimatedTouchBubblePart(
          dragging: dragging,
          size: widget.size,
        )
      )
    );
  }

  void _startDragging(DragStartDetails data) {
    setState(() {
      dragging = true;
    });
    widget.onDrag(data.localPosition - Offset(widget.size / 2, widget.size / 2));
  }

  void _cancelDragging() {
    setState(() {
      dragging = false;
    });
    widget.onDragFinished();
  }

  void _drag(DragUpdateDetails data) {
    if (!dragging) {
      return;
    }

    widget.onDrag(data.delta);
  }
}