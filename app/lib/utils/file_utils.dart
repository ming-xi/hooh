import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app/global.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:images_picker/images_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileUtil {
  static Future<void> saveNetworkImageToGallery(BuildContext context, String url) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return LoadingDialog(LoadingDialogController());
        });
    // Future.delayed(Duration(seconds: 3),(){
    //   Navigator.of(context, rootNavigator: true).pop();
    //
    // });
    _downloadImage(url).then((success) {
      Navigator.of(context, rootNavigator: true).pop();
      if (success) {
        Toast.showSnackBar(context, globalLocalizations.post_detail_download_success);
      } else {
        Toast.showSnackBar(context, globalLocalizations.post_detail_download_failed);
      }
    });
  }

  static Future<bool> _downloadImage(String url) async {
    String ext = url.substring(url.lastIndexOf(".") + 1);
    if (ext.contains("?")) {
      ext = ext.substring(0, ext.indexOf("?"));
    }
    String filename = "${DateUtil.getCurrentUtcDate().millisecondsSinceEpoch}.$ext";
    DownloadInfo? downloadInfo = await network.downloadBytes(url, filename);
    if (downloadInfo == null || downloadInfo.bytes == null) {
      return false;
    }
    File file = File("${(await getApplicationDocumentsDirectory()).path}/$filename");
    file.writeAsBytesSync(downloadInfo.bytes!.toList());
    return saveImageToGallery(file);
  }

  static Future<bool> saveImageToGallery(File file) async {
    return ImagesPicker.saveImageToAlbum(file, albumName: "");
  }

  static Future<File> saveTempFile(Uint8List bytes, String ext) async {
    File file = File("${(await getTemporaryDirectory()).path}/${getRandomFileName(ext)}");
    file.writeAsBytesSync(bytes);
    return file;
  }

  static String getRandomFileName(String ext) {
    return "${DateUtil.getCurrentUtcDate().millisecondsSinceEpoch}.$ext";
  }

  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<ui.Image> loadUiImageFromAsset(String imageAssetPath) async {
    final ByteData data = await rootBundle.load(imageAssetPath);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

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

// static Future<File?> pickImage() async {
//   final XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1920);
//   return pickedFile == null ? null : File(pickedFile.path);
// }
}
