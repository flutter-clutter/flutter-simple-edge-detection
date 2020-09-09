import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_edge_detection/edge_detection.dart';

void main() {
  const MethodChannel channel = MethodChannel('simple_edge_detection');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('detectEdges', () async {
    expect(
      await EdgeDetection.detectEdges('non-existing-path'),
      EdgeDetectionResult(
        topLeft: Offset(0,0),
        topRight: Offset(1,0),
        bottomLeft: Offset(0,1),
        bottomRight: Offset(1,1)
      )
    );
  });
}
