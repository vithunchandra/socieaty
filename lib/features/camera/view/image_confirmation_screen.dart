import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageConfirmationScreen extends StatelessWidget {
  final XFile imageFile;
  const ImageConfirmationScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    final file = File(imageFile.path);
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
