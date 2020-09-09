import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:simple_edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'camera_view.dart';
import 'edge_detection_preview.dart';
import 'edge_detector.dart';

class Scan extends StatefulWidget {
  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  CameraController controller;
  List<CameraDescription> cameras;
  String imagePath;
  EdgeDetectionResult edgeDetectionResult;

  @override
  void initState() {
    super.initState();
    checkForCameras().then((value) {
      _initializeController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _getMainWidget(),
          _getBottomBar(),
        ],
      ),
    );
  }

  Widget _getMainWidget() {
    if (imagePath == null && edgeDetectionResult == null) {
      return CameraView(
        controller: controller
      );
    }

    return EdgeDetectionPreview(
      imagePath: imagePath,
      edgeDetectionResult: edgeDetectionResult,
    );
  }

  Future<void> checkForCameras() async {
    cameras = await availableCameras();
  }

  void _initializeController() {
    checkForCameras();
    if (cameras.length == 0) {
      log('No cameras detected');
      return;
    }

    controller = CameraController(
        cameras[0],
        ResolutionPreset.veryHigh,
        enableAudio: false
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget _getButtonRow() {
    if (imagePath != null) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          //foregroundColor: Colors.white,
          child: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              edgeDetectionResult = null;
              imagePath = null;
            });
          },
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          foregroundColor: Colors.white,
          child: Icon(Icons.camera_alt),
          onPressed: onTakePictureButtonPressed,
        ),
        SizedBox(width: 16),
        FloatingActionButton(
          foregroundColor: Colors.white,
          child: Icon(Icons.image),
          onPressed: _onGalleryButtonPressed,
        ),
      ]
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      log('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getTemporaryDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      log(e.toString());
      return null;
    }
    return filePath;
  }

  Future _detectEdges(String filePath) async {
    if (!mounted || filePath == null) {
      return;
    }

    setState(() {
      imagePath = filePath;
    });

    EdgeDetectionResult result = await EdgeDetector().detectEdges(filePath);

    setState(() {
      edgeDetectionResult = result;
    });
  }

  void onTakePictureButtonPressed() async {
    String filePath = await takePicture();

    log('Picture saved to $filePath');

    await _detectEdges(filePath);
  }

  void _onGalleryButtonPressed() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    final filePath = pickedFile.path;

    log('Picture saved to $filePath');

    _detectEdges(filePath);
  }

  Padding _getBottomBar() {
    return Padding(
      padding: EdgeInsets.only(bottom: 32),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: _getButtonRow()
      )
    );
  }
}