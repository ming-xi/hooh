import 'dart:io';
import 'dart:typed_data';

import 'package:app/utils/date_util.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileUtil {
  static Uint8List? combineImages(List<Uint8List>? fileBytes) {
    if (fileBytes == null) {
      return null;
    }
    img.Image first = img.decodePng(fileBytes[0])!;
    for (int i = 1; i < fileBytes.length; i++) {
      img.Image image = img.decodePng(fileBytes[i])!;
      img.copyInto(first, image);
    }
    return Uint8List.fromList(img.encodePng(first));
  }

  static Future<File> writeTempFile(Uint8List bytes, String ext) async {
    String dateString = DateUtil.getUtcDateString(DateUtil.getCurrentUtcDate(), format: "yyyyMMddHHmmss");
    Directory directory = await getTemporaryDirectory();
    File file = File("${directory.path}/$dateString.$ext");
    file.writeAsBytesSync(bytes);
    return file;
  }

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
