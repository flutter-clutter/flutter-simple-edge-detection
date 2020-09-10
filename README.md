# simple_edge_detection

A Flutter plugin enabling the user to detect edges of a given image. It returns the relative coordinates of the detection rectangle.

## Demo

<p align="center">
  <img src="https://www.flutterclutter.dev/wp-content/uploads/2020/09/flutter-edge-detection-drag-animation.gif" height=600>
</p>

## Try out

If you just want to test it, go ahead and clone this repository.
Before you can run the example, you need to download the OpenCV library. Download the iOS pack and Android on https://opencv.org/releases/.
Afterwards, copy the respective files into the directory of this plugin where `project_root` is the root folder of this plugin: 

```
# OpenCV for Android
cp -R sdk/native/jni/include project_root
cp sdk/native/libs/* project_root/android/src/main/jniLibs/*

# OpenCV for iOS
cp -R opencv2.framework project_root/ios
```


## Getting Started

### Add plugin as dependency
In order to use the package, please verify you have added the latest version to you pubspec.yml:
```
dependencies:
  flutter:
    sdk: flutter
  simple_edge_detection: local_path_to_this_repository
```

### Import the package in your code
```
import 'package:simple_edge_detection/edge_detection.dart';
```

### Call the detection using a file path to an image

```dart

final picker = ImagePicker();
final pickedFile = await picker.getImage(source: ImageSource.gallery);
final filePath = pickedFile.path;

EdgeDetectionResult result = await EdgeDetector().detectEdges(filePath);

```

## Technical information

This package uses the OpenCV C++ library version 4.4.0 to perform the detection task. It utilizes Dart-FFI to execute the native code. 

## Tutorial / Infos / Article

Find the respective tutorial about how everything was created and how it's to be used on https://www.flutterclutter.dev/flutter/tutorials/implementing-edge-detection-in-flutter/2020/1509/