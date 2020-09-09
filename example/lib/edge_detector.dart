import 'dart:async';
import 'dart:isolate';

import 'package:simple_edge_detection/edge_detection.dart';

class EdgeDetector {
  static Future<void> startEdgeDetectionIsolate(EdgeDetectionInput edgeDetectionInput) async {
    EdgeDetectionResult result = await EdgeDetection.detectEdges(edgeDetectionInput.inputPath);
    edgeDetectionInput.sendPort.send(result);
  }

  Future<EdgeDetectionResult> detectEdges(String filePath) async {
    // Creating a port for communication with isolate and arguments for entry point
    final port = ReceivePort();
    //final args = ProcessImageArguments(image.path, tempPath);

    // Spawning an isolate
    Isolate.spawn<EdgeDetectionInput>(
      startEdgeDetectionIsolate,
      EdgeDetectionInput(
        inputPath: filePath,
        sendPort: port.sendPort
      ),
      onError: port.sendPort,
      onExit: port.sendPort
    );

    // Making a variable to store a subscription in
    StreamSubscription sub;

    // Listening for messages on port

    var completer = new Completer<EdgeDetectionResult>();

    sub = port.listen((result) async {
      // Cancel a subscription after message received called
      await sub?.cancel();
      completer.complete(await result);
    });

    return completer.future;
  }
}

class EdgeDetectionInput {
  EdgeDetectionInput({
    this.inputPath,
    this.sendPort
  });

  String inputPath;
  SendPort sendPort;
}