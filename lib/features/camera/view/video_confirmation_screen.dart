import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VideoConfirmationScreen extends StatelessWidget {
  final XFile videoFile;
  const VideoConfirmationScreen({super.key, required this.videoFile});

  @override
  Widget build(BuildContext context) {
    final file = File(videoFile.path);
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Image.file(file),
          )
        ],
      ),
    );
  }
}
