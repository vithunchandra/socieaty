import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_pallete.dart';
import 'image_picker_utils.dart';

void showContentPickerModal(context, Function(File) setImage) {
  showModalBottomSheet(
    backgroundColor: AppPallete.primaryColor.shade100,
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text('Gallery'),
              onTap: () async {
                final file = await pickImageFromGallery();
                if (file != null) {
                  setImage(file);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Image'),
              onTap: () async {
                final file = await pickImageFromCamera();
                if (file != null) {
                  setImage(file);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Video'),
              onTap: () async {
                final file = await pickVideoFromCamera();
                if (file != null) {
                  setImage(file);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

void showImagePickerModal(context, Function(File) setImage) {
  showModalBottomSheet(
    backgroundColor: AppPallete.primaryColor.shade100,
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text('Gallery'),
              onTap: () async {
                final file = await pickImageFromGallery();
                if (file != null) {
                  setImage(file);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Image'),
              onTap: () async {
                final file = await pickImageFromCamera();
                if (file != null) {
                  setImage(file);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
