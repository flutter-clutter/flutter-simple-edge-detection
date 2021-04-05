import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';


class Coordinate extends Struct {
  @Double()
  double x;

  @Double()
  double y;

  factory Coordinate.allocate(double x, double y) =>
      malloc<Coordinate>().ref
        ..x = x
        ..y = y;
}

class NativeDetectionResult extends Struct {
  Pointer<Coordinate> topLeft;
  Pointer<Coordinate> topRight;
  Pointer<Coordinate> bottomLeft;
  Pointer<Coordinate> bottomRight;

  factory NativeDetectionResult.allocate(
      Pointer<Coordinate> topLeft,
      Pointer<Coordinate> topRight,
      Pointer<Coordinate> bottomLeft,
      Pointer<Coordinate> bottomRight) =>
      malloc<NativeDetectionResult>().ref
        ..topLeft = topLeft
        ..topRight = topRight
        ..bottomLeft = bottomLeft
        ..bottomRight = bottomRight;
}

class EdgeDetectionResult {
  EdgeDetectionResult({
    @required this.topLeft,
    @required this.topRight,
    @required this.bottomLeft,
    @required this.bottomRight,
  });

  Offset topLeft;
  Offset topRight;
  Offset bottomLeft;
  Offset bottomRight;
}

typedef DetectEdgesFunction = Pointer<NativeDetectionResult> Function(
  Pointer<Utf8> imagePath
);

typedef process_image_function = Int8 Function(
  Pointer<Utf8> imagePath,
  Double topLeftX,
  Double topLeftY,
  Double topRightX,
  Double topRightY,
  Double bottomLeftX,
  Double bottomLeftY,
  Double bottomRightX,
  Double bottomRightY,
  Double rotation
);

typedef ProcessImageFunction = int Function(
  Pointer<Utf8> imagePath,
  double topLeftX,
  double topLeftY,
  double topRightX,
  double topRightY,
  double bottomLeftX,
  double bottomLeftY,
  double bottomRightX,
  double bottomRightY,
  double rotation
);

// https://github.com/dart-lang/samples/blob/master/ffi/structs/structs.dart

class EdgeDetection {
  static Future<EdgeDetectionResult> detectEdges(String path) async {
    DynamicLibrary nativeEdgeDetection = _getDynamicLibrary();

    final detectEdges = nativeEdgeDetection
        .lookup<NativeFunction<DetectEdgesFunction>>("detect_edges")
        .asFunction<DetectEdgesFunction>();

    NativeDetectionResult detectionResult = detectEdges(path.toNativeUtf8()).ref;

    return EdgeDetectionResult(
        topLeft: Offset(
            detectionResult.topLeft.ref.x, detectionResult.topLeft.ref.y
        ),
        topRight: Offset(
            detectionResult.topRight.ref.x, detectionResult.topRight.ref.y
        ),
        bottomLeft: Offset(
            detectionResult.bottomLeft.ref.x, detectionResult.bottomLeft.ref.y
        ),
        bottomRight: Offset(
            detectionResult.bottomRight.ref.x, detectionResult.bottomRight.ref.y
        )
    );
  }

  static Future<bool> processImage(String path, EdgeDetectionResult result,double rotation) async {
    DynamicLibrary nativeEdgeDetection = _getDynamicLibrary();

    final processImage = nativeEdgeDetection
        .lookup<NativeFunction<process_image_function>>("process_image")
        .asFunction<ProcessImageFunction>();


    return processImage(
        path.toNativeUtf8(),
        result.topLeft.dx,
        result.topLeft.dy,
        result.topRight.dx,
        result.topRight.dy,
        result.bottomLeft.dx,
        result.bottomLeft.dy,
        result.bottomRight.dx,
        result.bottomRight.dy,
        rotation
    ) == 1;
  }

  static DynamicLibrary _getDynamicLibrary() {
    final DynamicLibrary nativeEdgeDetection = Platform.isAndroid
        ? DynamicLibrary.open("libnative_edge_detection.so")
        : DynamicLibrary.process();
    return nativeEdgeDetection;
  }
}

class EdgeDetector {
  static Future<void> startEdgeDetectionIsolate(
      EdgeDetectionInput edgeDetectionInput) async {
    EdgeDetectionResult result =
    await EdgeDetection.detectEdges(edgeDetectionInput.inputPath);
    edgeDetectionInput.sendPort.send(result);
  }

  static Future<void> processImageIsolate(
      ProcessImageInput processImageInput) async {
    EdgeDetection.processImage(processImageInput.inputPath,
        processImageInput.edgeDetectionResult, processImageInput.rotation);
    processImageInput.sendPort.send(true);
  }

  Future<EdgeDetectionResult> detectEdges(String filePath) async {
    final port = ReceivePort();

    _spawnIsolate<EdgeDetectionInput>(startEdgeDetectionIsolate,
        EdgeDetectionInput(inputPath: filePath, sendPort: port.sendPort), port);

    return await _subscribeToPort<EdgeDetectionResult>(port);
  }

  Future<bool> processImage(String filePath,
      EdgeDetectionResult edgeDetectionResult, double rot) async {
    final port = ReceivePort();

    _spawnIsolate<ProcessImageInput>(
        processImageIsolate,
        ProcessImageInput(
            inputPath: filePath,
            edgeDetectionResult: edgeDetectionResult,
            rotation: rot,
            sendPort: port.sendPort),
        port);

    return await _subscribeToPort<bool>(port);
  }

  void _spawnIsolate<T>(Function function, dynamic input, ReceivePort port) {
    Isolate.spawn<T>(function, input,
        onError: port.sendPort, onExit: port.sendPort);
  }

  Future<T> _subscribeToPort<T>(ReceivePort port) async {
    StreamSubscription sub;

    var completer = new Completer<T>();

    sub = port.listen((result) async {
      await sub?.cancel();
      completer.complete(await result);
    });

    return completer.future;
  }
}

class EdgeDetectionInput {
  EdgeDetectionInput({this.inputPath, this.sendPort});

  String inputPath;
  SendPort sendPort;
}

class ProcessImageInput {
  ProcessImageInput(
      {this.inputPath, this.edgeDetectionResult, this.rotation, this.sendPort});

  String inputPath;
  EdgeDetectionResult edgeDetectionResult;
  SendPort sendPort;
  double rotation;
}