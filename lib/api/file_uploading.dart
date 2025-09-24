import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FileUploading extends StatefulWidget {
  const FileUploading({super.key});

  @override
  State<FileUploading> createState() => _FileUploadingState();
}

class _FileUploadingState extends State<FileUploading> {
  File? file; // hold file obj like image...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Uploading')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (file != null) ...[
              // if file is not null then show image and upload button
              Image.file(file!),
              ElevatedButton(
                onPressed: () async {
                  final dio = Dio(); // create dio instance
                  // we need to create form data to send file to server
                  // multipart file is used to send file to server.
                  final form = FormData.fromMap({
                    "file": await MultipartFile.fromFile(file!.path),
                  });
                  final response = await dio.post(
                    'https://jsonplaceholder.typicode.com/posts',
                    data: form, // send data to server
                    // here, we can track the progress of file uploading using onSendProgress
                    onSendProgress: (count, total) {
                      print("${(count / total) * 100} %");
                    },
                  );
                  print("Successfully upload : $response");
                },
                child: const Text('Upload File'),
              ),
            ] else ...[
              const Text('No file selected'),
            ],
            ElevatedButton(
              // image is picked  from camera
              onPressed: () async {
                final picker = ImagePicker();
                final result = await picker.pickImage(
                  source: ImageSource.camera, // img store in Xfile object
                );
                if (result != null) {
                  setState(() {
                    file = File(
                      result.path,
                    ); // convert XFile to File to access path
                  });
                }
              },
              child: const Text('Choose File'),
            ),
          ],
        ),
      ),
    );
  }
}
