import 'dart:io';

import 'package:flutter/material.dart';

class ImageCardWidget extends StatelessWidget {
  final File file;
  final Size size;
  const ImageCardWidget({super.key, required this.file, required this.size});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: ClipRRect(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(12.0),
          child: FittedBox(
            fit: BoxFit.fill,
            child: Image.file(file),
          ),
        ),
      ),
    );
  }
}
