import 'package:flutter/material.dart';

import 'scan.dart';

void main() {
  runApp(EdgeDetectionApp());
}

class EdgeDetectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scan(),
    );
  }
}