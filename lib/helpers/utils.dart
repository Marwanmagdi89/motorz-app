import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<bool> _uploadProfileImage(File imageFile, String url, String accessToken) async {
  FormData formData = FormData.fromMap({
    "user_img": await MultipartFile.fromFile(imageFile.path),
  });

  try {
    Response response = await Dio().post(
      url,
      data: formData,
      options: Options(
        headers: {"Authorization": "Bearer $accessToken"},
      ),
    );
    print("Upload Response: $response");
    return (response.statusCode == 200);
  } catch (e) {
    print("Upload Error: $e");
  }
  return false;
}

Future<bool> pickProfileImage(BuildContext context, String url, String accessToken) async {
  // bool? isCamera = await showDialog(
  //   context: context,
  //   builder: (context) => AlertDialog(
  //     content: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.of(context).pop(true);
  //           },
  //           child: const Text("Camera"),
  //         ),
  //         const SizedBox(
  //           height: 20,
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.of(context).pop(false);
  //           },
  //           child: const Text("gallery "),
  //         ),
  //       ],
  //     ),
  //   ),
  // );
  //
  // if (isCamera == null) return;

  final picker = ImagePicker();

  final pickedFile = await picker.pickImage(
    source: ImageSource.gallery,
  );

  if (pickedFile != null) {
    return await _uploadProfileImage(File(pickedFile.path), url, accessToken);
  }
  return false;
}
