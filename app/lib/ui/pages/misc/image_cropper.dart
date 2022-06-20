import 'dart:io';
import 'dart:typed_data';

import 'package:app/global.dart';
import 'package:app/utils/file_utils.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ImageCropperScreen extends ConsumerStatefulWidget {
  final File imageFile;
  final double? ratio;

  const ImageCropperScreen({
    required this.imageFile,
    this.ratio,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends ConsumerState<ImageCropperScreen> {
  final _controller = CropController();
  late Uint8List imageBytes;

  @override
  void initState() {
    super.initState();
    imageBytes = widget.imageFile.readAsBytesSync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(globalLocalizations.crop_image_title),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                _controller.crop();
              },
              icon: const Icon(Icons.done_rounded),
            )
          ],
        ),
        body: Crop(
          image: imageBytes,
          controller: _controller,
          onCropped: (image) async {
            // do something with image data
            File file = await FileUtil.saveTempFile(image, "jpg");
            Navigator.of(context).pop(file);
            // showDialog(
            //     context: context,
            //     builder: (context) {
            //       return AlertDialog(
            //         content: Image.memory(
            //           image,
            //         ),
            //       );
            //     });
          },
          aspectRatio: widget.ratio,
          initialSize: null,
          // initialArea: Rect.fromLTWH(0, 0, 0, 0),
          // initialAreaBuilder: (rect) => Rect.fromLTRB(
          //     rect.left + 24, rect.top + 32, rect.right - 24, rect.bottom - 32
          // ),
          // withCircleUi: true,
          // baseColor: Colors.blue.shade900,
          // maskColor: Colors.white.withAlpha(100),
          // radius: 20,
          onMoved: (newRect) {
            // do something with current cropping area.
          },
          onStatusChanged: (status) {
            // do something with current CropStatus
          },

          // cornerDotBuilder: (size, edgeAlignment) => const DotControl(color: Colors.blue),
          interactive: true,
          fixArea: true,
        ));
  }
}
