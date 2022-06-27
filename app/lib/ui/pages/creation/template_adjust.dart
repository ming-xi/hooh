import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app/global.dart';
import 'package:app/utils/design_colors.dart';
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
      appBar: AppBar(
        title: Text(globalLocalizations.template_adjustment_title),
        actions: [
          IconButton(
              onPressed: () async {
                var file = await captureImage();
                widget.onFileAdjusted(file);
              },
              icon: Icon(Icons.arrow_forward))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: designColors.dark_01.light.withOpacity(0.75),
            ),
            flex: 1,
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
                          onDoubleTap: () {
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
                              if (scale * factor < 0.333) {
                                factor = 0.333 / scale;
                              } else if (scale * factor > 1) {
                                factor = 1 / scale;
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
            flex: 2,
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
    // debugPrint("devicePixelRatio=$devicePixelRatio");
    int imageSize = 720;
    double screenWidth = MediaQuery.of(context).size.width * devicePixelRatio;
    double screenHeight = MediaQuery.of(context).size.height * devicePixelRatio;
    RenderRepaintBoundary boundary = genKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: devicePixelRatio);
    img.Image src = img.Image.fromBytes(image.width, image.height, (await image.toByteData())!.buffer.asUint8List());
    // debugPrint("screenWidth=$screenWidth screenHeight=$screenHeight src.width=${src.width} src.height=${src.height}");
    // double offsetX = x * devicePixelRatio;
    // double offsetY = y * devicePixelRatio;
    // debugPrint("offsetX=$offsetX offsetY=$offsetY ");
    img.Image result = img.Image.rgb(imageSize, imageSize);
    img.fill(result, Colors.white.value);
    // double dstX = offsetX * imageSize / screenWidth;
    // double dstY = offsetY * imageSize / screenWidth;
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
    // debugPrint(""
    //     "srcX=${0}\n"
    //     "srcY=${0}\n"
    //     "srcW=${src.width}\n"
    //     "srcH=${src.height}\n"
    //     "dstX=$dstX\n"
    //     "dstY=$dstY\n"
    //     "dstW=$dstW\n"
    //     "dstH=$dstH\n");
    final directory = (await getApplicationDocumentsDirectory()).path;
    var bytes = img.encodeJpg(result, quality: 80);
    var filename = md5.convert(bytes).toString();
    // debugPrint("bytes=$filename");
    File imgFile = File('$directory/$filename.jpg');
    imgFile.writeAsBytesSync(bytes, flush: true);
    return imgFile;
  }

  bool isImageDarkColor(Uint8List fileBytes) {
    img.Image? image = img.decodePng(fileBytes);
    Uint32List pixels = image!.data;
    // check 1000 pixels
    int count = 1000;
    int gap = pixels.length ~/ count;
    int lightCount = 0;
    int darkCount = 0;
    for (int i = 0; i < pixels.length; i += gap) {
      int pixel = pixels[i];
      Color color = Color(pixel);
      int a = color.alpha;
      int b = color.red;
      int g = color.green;
      int r = color.blue;
      color = Color.fromARGB(a, r, g, b);
      if ((r * 0.299 + g * 0.587 + b * 0.114) > 186) {
        lightCount++;
      } else {
        darkCount++;
      }
    }
    debugPrint("darkCount=$darkCount lightCount=$lightCount");
    return darkCount >= lightCount;
  }
}
