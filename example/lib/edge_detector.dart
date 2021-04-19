// import 'dart:async';
// import 'dart:isolate';
//
// import 'package:simple_edge_detection/edge_detection.dart';
//
// class EdgeDetector {
//   static Future<void> startEdgeDetectionIsolate(EdgeDetectionInput edgeDetectionInput) async {
//     EdgeDetectionResult result = await EdgeDetection.detectEdges(edgeDetectionInput.inputPath);
//     edgeDetectionInput.sendPort.send(result);
//   }
//
//   static Future<void> processImageIsolate(ProcessImageInput processImageInput) async {
//     EdgeDetection.processImage(processImageInput.inputPath, processImageInput.edgeDetectionResult);
//     processImageInput.sendPort.send(true);
//   }
//
//   Future<EdgeDetectionResult> detectEdges(String filePath) async {
//     final port = ReceivePort();
//
//     _spawnIsolate<EdgeDetectionInput>(
//         startEdgeDetectionIsolate,
//         EdgeDetectionInput(
//           inputPath: filePath,
//           sendPort: port.sendPort
//         ),
//         port
//     );
//
//     return await _subscribeToPort<EdgeDetectionResult>(port);
//   }
//
//   Future<bool> processImage(String filePath, EdgeDetectionResult edgeDetectionResult) async {
//     final port = ReceivePort();
//
//     _spawnIsolate<ProcessImageInput>(
//       processImageIsolate,
//       ProcessImageInput(
//         inputPath: filePath,
//         edgeDetectionResult: edgeDetectionResult,
//         sendPort: port.sendPort
//       ),
//       port
//     );
//
//     return await _subscribeToPort<bool>(port);
//   }
//
//   void _spawnIsolate<T>(Function function, dynamic input, ReceivePort port) {
//     Isolate.spawn<T>(
//       function,
//       input,
//       onError: port.sendPort,
//       onExit: port.sendPort
//     );
//   }
//
//   Future<T> _subscribeToPort<T>(ReceivePort port) async {
//     StreamSubscription sub;
//
//     var completer = new Completer<T>();
//
//     sub = port.listen((result) async {
//       await sub?.cancel();
//       completer.complete(await result);
//     });
//
//     return completer.future;
//   }
// }
//
// class EdgeDetectionInput {
//   EdgeDetectionInput({
//     this.inputPath,
//     this.sendPort
//   });
//
//   String inputPath;
//   SendPort sendPort;
// }
//
// class ProcessImageInput {
//   ProcessImageInput({
//     this.inputPath,
//     this.edgeDetectionResult,
//     this.sendPort
//   });
//
//   String inputPath;
//   EdgeDetectionResult edgeDetectionResult;
//   SendPort sendPort;
// }