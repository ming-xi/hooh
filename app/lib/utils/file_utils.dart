import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileUtil {
  static Future<File?> pickFile(BuildContext context) async {
    String? path = await FilesystemPicker.open(
        title: 'Save to folder',
        context: context,
        rootDirectory: await getApplicationDocumentsDirectory(),
        fsType: FilesystemType.file,
        allowedExtensions: ['.jpg', '.jpeg', '.png'],
        requestPermission: () async {
          PermissionStatus status = await Permission.storage.request();
          if (status.isGranted) {
            return true;
          } else {
            if (status.isDenied) {
              // We didn't ask for permission yet or the permission has been denied before but not permanently.
            }
            return false;
          }
        },
        folderIconColor: Colors.blue);
    return path == null ? null : File(path);
  }

  static Future<File?> pickImage() async {
    final XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1920);
    // File? croppedFile = await ImageCropper().cropImage(
    //     sourcePath: pickedFile!.path,
    //     aspectRatioPresets: [
    //       CropAspectRatioPreset.square,
    //       CropAspectRatioPreset.ratio3x2,
    //       CropAspectRatioPreset.original,
    //       CropAspectRatioPreset.ratio4x3,
    //       CropAspectRatioPreset.ratio16x9
    //     ],
    //     androidUiSettings: const AndroidUiSettings(
    //         toolbarTitle: 'Cropper',
    //         toolbarColor: Colors.deepOrange,
    //         toolbarWidgetColor: Colors.white,
    //         initAspectRatio: CropAspectRatioPreset.original,
    //         lockAspectRatio: false),
    //     iosUiSettings: const IOSUiSettings());
    return pickedFile == null ? null : File(pickedFile.path);
  }
}
