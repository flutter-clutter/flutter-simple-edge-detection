import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:simple_edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';

class EdgeDetectionPreview extends StatefulWidget {
  EdgeDetectionPreview({
    this.imagePath,
    this.edgeDetectionResult
  });

  final String imagePath;
  final EdgeDetectionResult edgeDetectionResult;

  @override
  _EdgeDetectionPreviewState createState() => _EdgeDetectionPreviewState();
}

class _EdgeDetectionPreviewState extends State<EdgeDetectionPreview> {
  GlobalKey imageWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext mainContext) {
    return Center(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: Text('Loading ...')
          ),
          Image.file(
            File(widget.imagePath),
            fit: BoxFit.contain,
            key: imageWidgetKey
          ),
          FutureBuilder<ui.Image>(
            future: loadUiImage(widget.imagePath),
            builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
              return _getEdgePaint(snapshot, context);
            }
          ),
        ],
      ),
    );
  }

  Widget _getEdgePaint(AsyncSnapshot<ui.Image> imageSnapshot, BuildContext context) {
    if (imageSnapshot.connectionState == ConnectionState.waiting)
      return Container();

    if (imageSnapshot.hasError)
      return Text('Error: ${imageSnapshot.error}');

    if (widget.edgeDetectionResult == null)
      return Container();

    final keyContext = imageWidgetKey.currentContext;

    if (keyContext == null) {
      return Container();
    }

    final box = keyContext.findRenderObject() as RenderBox;

    return CustomPaint(
        size: Size(box.size.width, box.size.height),
        painter: EdgePainter(
          topLeft: widget.edgeDetectionResult.topLeft,
          topRight: widget.edgeDetectionResult.topRight,
          bottomLeft: widget.edgeDetectionResult.bottomLeft,
          bottomRight: widget.edgeDetectionResult.bottomRight,
          image: imageSnapshot.data,
          color: Theme.of(context).accentColor
        )
    );
  }

  Future<ui.Image> loadUiImage(String imageAssetPath) async {
    final Uint8List data = await File(imageAssetPath).readAsBytes();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image image) {
      return completer.complete(image);
    });
    return completer.future;
  }
}

class EdgePainter extends CustomPainter {
  EdgePainter({
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
    this.image,
    this.color
  });

  Offset topLeft;
  Offset topRight;
  Offset bottomLeft;
  Offset bottomRight;

  ui.Image image;
  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    double top = 0.0;
    double left = 0.0;

    double widthFactor = size.width / image.width;
    double heightFactor = size.height / image.height;
    double sizeFactor = min(widthFactor, heightFactor);

    double renderedImageHeight = image.height * sizeFactor;
    top = ((size.height - renderedImageHeight) / 2);

    double renderedImageWidth = image.width * sizeFactor;
    left = ((size.width - renderedImageWidth) / 2);


    final points = [
      Offset(left + topLeft.dx * renderedImageWidth, top + topLeft.dy * renderedImageHeight),
      Offset(left + topRight.dx * renderedImageWidth, top + topRight.dy * renderedImageHeight),
      Offset(left + bottomRight.dx * renderedImageWidth, top + (bottomRight.dy * renderedImageHeight)),
      Offset(left + bottomLeft.dx * renderedImageWidth, top + bottomLeft.dy * renderedImageHeight),
      Offset(left + topLeft.dx * renderedImageWidth, top + topLeft.dy * renderedImageHeight),
    ];

    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(ui.PointMode.polygon, points, paint);

    for (Offset point in points) {
      canvas.drawCircle(point, 10, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}