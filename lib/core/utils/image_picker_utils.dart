import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future<File?> pickImageFromGallery() async {
  final returnedFile = await ImagePicker().pickMedia();

  if (returnedFile != null) {
    return File(returnedFile.path);
  }
  return null;
}

Future<File?> pickImageFromCamera() async {
  final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);

  if (returnedImage != null) {
    return File(returnedImage.path);
  }
  return null;
}

Future<File?> pickVideoFromCamera() async {
  final returnedVideo = await ImagePicker().pickVideo(source: ImageSource.camera);

  if (returnedVideo != null) {
    return File(returnedVideo.path);
  }
  return null;
}
