import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

Future<File> selectImage() async {
  File image;
  final picker = ImagePicker();
  final selected_image = await picker.getImage(source: ImageSource.gallery);
  var cropped_image = await ImageCropper().cropImage(
      sourcePath: selected_image.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1));
  //image = await compressImage(cropped_image.path, 20);

  image = File(cropped_image.path);
  print("methods.selectImage selected image ${image.path}");
  return image;
}

Future<String> uploadImageToFirebase(BuildContext context, File file) async {
  String filename = file.path.toString();
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  TaskSnapshot snapshot = await FirebaseStorage.instance.ref("profile_images").child("$timestamp").putFile(file);
  String image_url = await snapshot.ref.getDownloadURL();
  print("methods.uploadImageToFirebase image url: $image_url");
  return image_url;
}