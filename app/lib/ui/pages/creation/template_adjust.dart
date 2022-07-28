import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:app/global.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class AdjustTemplatePositionScreen extends ConsumerStatefulWidget {
  final File file;
  final Function(File file) onFileAdjusted;

  const AdjustTemplatePositionScreen(
    this.file, {
    required this.onFileAdjusted,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AdjustTemplatePositionScreenState();
}

class _AdjustTemplatePositionScreenState extends ConsumerState<AdjustTemplatePositionScreen> {
  double x = 0;
  double y = 0;
  double scale = 1;
  double tempScale = 1;
  bool? whiteBackground;
  final GlobalKey genKey = GlobalKey();
  late ui.Image? image = null;

  @override
  void initState() {
    super.initState();
    widget.file.readAsBytes().then((bytes) {
      setState(() {
        whiteBackground = isImageDarkColor(bytes);
      });
      ui.decodeImageFromList(bytes, (decoded) {
        setState(() {
          image = decoded;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HoohAppBar(
        title: Text(globalLocalizations.template_adjustment_title),
        actions: [
          IconButton(
              onPressed: () async {
                File file = await captureImage();
                widget.onFileAdjusted(file);
              },
              icon: HoohIcon(
                "assets/images/icon_arrow_next.svg",
                width: 24,
                height: 24,
                color: designColors.dark_01.auto(ref),
              ))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: designColors.dark_01.light.withOpacity(0.75),
            ),
          ),
          RepaintBoundary(
            key: genKey,
            child: ClipRect(
              child: Container(
                color: whiteBackground ?? true ? Colors.white : Colors.black,
                child: Builder(
                  builder: (context) {
                    double screenWidth = MediaQuery.of(context).size.width;
                    return SizedBox(
                        width: screenWidth,
                        height: screenWidth,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            if (whiteBackground == null) {
                              return;
                            } else {
                              setState(() {
                                whiteBackground = !whiteBackground!;
                              });
                            }
                          },
                          onScaleStart: (details) {},
                          onScaleEnd: (details) {
                            setState(() {
                              scale *= tempScale;
                              tempScale = 1;
                            });
                          },
                          onScaleUpdate: (details) {
                            var factor = (details.horizontalScale + details.verticalScale) / 2;
                            setState(() {
                              x = x + details.focalPointDelta.dx;
                              y = y + details.focalPointDelta.dy;
                              if (scale * factor < 0.3) {
                                factor = 0.3 / scale;
                              } else if (scale * factor > 2) {
                                factor = 2 / scale;
                              }
                              tempScale = factor;
                            });
                          },
                          child: Stack(children: [
                            Positioned(
                              left: x,
                              top: y,
                              child: Transform.scale(
                                scale: scale * tempScale,
                                child: buildImage(),
                              ),
                            )
                          ]),
                        ));
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 56),
              color: designColors.dark_01.light.withOpacity(0.75),
              child: Center(
                child: Text(
                  globalLocalizations.template_adjustment_description,
                  style: TextStyle(
                    color: designColors.dark_03.auto(ref),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImage() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (image == null) {
      return Container();
    }
    if (image!.width >= image!.height) {
      return Image.file(
        widget.file,
        fit: BoxFit.contain,
        width: min(screenWidth, screenHeight),
      );
    } else {
      return Image.file(
        widget.file,
        fit: BoxFit.contain,
        height: min(screenWidth, screenHeight),
      );
    }
  }

  Future<File> captureImage() async {
    WidgetsBinding? binding = WidgetsBinding.instance;
    double devicePixelRatio = binding.window.devicePixelRatio;
    int imageSize = 720;
    double screenWidth = MediaQuery.of(context).size.width * devicePixelRatio;
    double screenHeight = MediaQuery.of(context).size.height * devicePixelRatio;
    RenderRepaintBoundary boundary = genKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: devicePixelRatio);
    img.Image src = img.Image.fromBytes(image.width, image.height, (await image.toByteData())!.buffer.asUint8List());
    img.Image result = img.Image.rgb(imageSize, imageSize);
    img.fill(result, Colors.white.value);
    double dstX = 0;
    double dstY = 0;
    double dstW = src.width * imageSize / screenWidth;
    double dstH = src.height * imageSize / screenWidth;
    result = img.drawImage(
      result,
      src,
      srcX: 0,
      srcY: 0,
      srcW: src.width,
      srcH: src.height,
      dstX: dstX.toInt(),
      dstY: dstY.toInt(),
      dstW: dstW.toInt(),
      dstH: dstH.toInt(),
    );
    String directory = (await getApplicationDocumentsDirectory()).path;
    List<int> bytes = img.encodeJpg(result, quality: 80);
    String filename = md5.convert(bytes).toString();
    File imgFile = File('$directory/$filename.jpg');
    imgFile.writeAsBytesSync(bytes, flush: true);
    return imgFile;
  }
}
