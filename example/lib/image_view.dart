import 'dart:io';
import 'package:flutter/material.dart';

class ImageView extends StatefulWidget {
  ImageView({
    this.imagePath
  });

  final String imagePath;

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  GlobalKey imageWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext mainContext) {
    return Center(child: Image.file(
      File(widget.imagePath),
      fit: BoxFit.contain
    ));
  }
}