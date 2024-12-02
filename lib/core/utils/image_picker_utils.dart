import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future pickImageFromGallery(Function(File) setImage) async {
  final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

  if (returnedImage != null) {
    setImage(File(returnedImage.path));
  }
}

Future pickImageFromCamera(Function(File) setImage) async {
  final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);

  if (returnedImage != null) {
    setImage(File(returnedImage.path));
  }
}
