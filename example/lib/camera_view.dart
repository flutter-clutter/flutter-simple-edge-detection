import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraView extends StatelessWidget {
  CameraView({
    this.controller
  });

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return _getCameraPreview();
  }
  
  Widget _getCameraPreview() {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller)
      )
    );
  }
}