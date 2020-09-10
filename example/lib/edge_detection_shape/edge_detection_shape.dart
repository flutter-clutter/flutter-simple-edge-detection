import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:simple_edge_detection/edge_detection.dart';

import 'edge_painter.dart';
import 'touch_bubble.dart';

class EdgeDetectionShape extends StatefulWidget {
  EdgeDetectionShape({
    @required this.renderedImageSize,
    @required this.originalImageSize,
    @required this.edgeDetectionResult
  });

  final Size renderedImageSize;
  final Size originalImageSize;
  final EdgeDetectionResult edgeDetectionResult;

  @override
  _EdgeDetectionShapeState createState() => _EdgeDetectionShapeState();
}

class _EdgeDetectionShapeState extends State<EdgeDetectionShape> {
  double edgeDraggerSize;

  EdgeDetectionResult edgeDetectionResult;
  List<Offset> points;

  double renderedImageWidth;
  double renderedImageHeight;
  double top;
  double left;

  @override
  void didChangeDependencies() {
    double shortestSide = min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    edgeDraggerSize = shortestSide / 8;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    edgeDetectionResult = widget.edgeDetectionResult;
    _calculateDimensionValues();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _getTouchBubbles(),
        CustomPaint(
          painter: EdgePainter(
            points: points,
            color: Theme.of(context).accentColor.withOpacity(0.5)
          ),
        )
      ],
    );
  }
  
  void _calculateDimensionValues() {
    top = 0.0;
    left = 0.0;

    double widthFactor = widget.renderedImageSize.width / widget.originalImageSize.width;
    double heightFactor = widget.renderedImageSize.height / widget.originalImageSize.height;
    double sizeFactor = min(widthFactor, heightFactor);

    renderedImageHeight = widget.originalImageSize.height * sizeFactor;
    top = ((widget.renderedImageSize.height - renderedImageHeight) / 2);

    renderedImageWidth = widget.originalImageSize.width * sizeFactor;
    left = ((widget.renderedImageSize.width - renderedImageWidth) / 2);
  }

  Offset _getNewPositionAfterDrag(Offset position, double renderedImageWidth, double renderedImageHeight) {
    return Offset(
      position.dx / renderedImageWidth,
      position.dy / renderedImageHeight
    );
  }

  Widget _getTouchBubbles() {
    points = [
      Offset(left + edgeDetectionResult.topLeft.dx * renderedImageWidth, top + edgeDetectionResult.topLeft.dy * renderedImageHeight),
      Offset(left + edgeDetectionResult.topRight.dx * renderedImageWidth, top + edgeDetectionResult.topRight.dy * renderedImageHeight),
      Offset(left + edgeDetectionResult.bottomRight.dx * renderedImageWidth, top + (edgeDetectionResult.bottomRight.dy * renderedImageHeight)),
      Offset(left + edgeDetectionResult.bottomLeft.dx * renderedImageWidth, top + edgeDetectionResult.bottomLeft.dy * renderedImageHeight),
      Offset(left + edgeDetectionResult.topLeft.dx * renderedImageWidth, top + edgeDetectionResult.topLeft.dy * renderedImageHeight),
    ];

    final Function onDragFinished = () {
        setState(() {});
    };

    return Container(
      width: widget.renderedImageSize.width,
      height: widget.renderedImageSize.height,
      child: Stack(
        children: [
          Positioned(
            child: TouchBubble(
              size: edgeDraggerSize,
              onDrag: (position) {
                setState(() {
                  edgeDetectionResult.topLeft += _getNewPositionAfterDrag(
                    position, renderedImageWidth, renderedImageHeight
                  );
                });
              },
              onDragFinished: onDragFinished
            ),
            left: points[0].dx - (edgeDraggerSize / 2),
            top: points[0].dy - (edgeDraggerSize / 2)
          ),
          Positioned(
            child: TouchBubble(
              size: edgeDraggerSize,
              onDrag: (position) {
                setState(() {
                  edgeDetectionResult.topRight += _getNewPositionAfterDrag(
                      position, renderedImageWidth, renderedImageHeight
                  );
                });
              },
              onDragFinished: onDragFinished
            ),
            left: points[1].dx - (edgeDraggerSize / 2),
            top: points[1].dy - (edgeDraggerSize / 2)
          ),
          Positioned(
            child: TouchBubble(
              size: edgeDraggerSize,
              onDrag: (position) {
                setState(() {
                  edgeDetectionResult.bottomRight += _getNewPositionAfterDrag(
                      position, renderedImageWidth, renderedImageHeight
                  );
                });
              },
              onDragFinished: onDragFinished
            ),
            left: points[2].dx - (edgeDraggerSize / 2),
            top: points[2].dy - (edgeDraggerSize / 2)
          ),
          Positioned(
            child: TouchBubble(
              size: edgeDraggerSize,
              onDrag: (position) {
                setState(() {
                  edgeDetectionResult.bottomLeft += _getNewPositionAfterDrag(
                      position, renderedImageWidth, renderedImageHeight
                  );
                });
              },
              onDragFinished: onDragFinished
            ),
            left: points[3].dx - (edgeDraggerSize / 2),
            top: points[3].dy - (edgeDraggerSize / 2)
          ),
        ],
      ),
    );
  }
}