import 'dart:ui' as ui;

import 'package:app/ui/widgets/template_text_setting_view_model.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TemplateTextSettingView extends ConsumerStatefulWidget {
  static const double MIN_MARGIN_PERCENT = 4;
  static const double MIN_SIZE_PERCENT = 20;

  final StateNotifierProvider<TemplateTextSettingViewModel, TemplateTextSettingModelState> provider;

  TemplateTextSettingView(this.provider);

  @override
  _TemplateTextSettingViewState createState() => _TemplateTextSettingViewState();
}

class _TemplateTextSettingViewState extends ConsumerState<TemplateTextSettingView> {
  bool willChange = false;
  bool panning = false;
  bool scaling = false;
  late Offset panStartLocation;
  late Offset originalFrameLocation;
  late Offset originalFrameSize;

  @override
  void initState() {
    super.initState();
    // FileUtil.loadUiImageFromAsset("assets/images/icon_template_text_frame_scale.png").then((image) {
    //   TemplateTextSettingViewModel model = ref.read(widget.provider.notifier);
    //   model.setButtonImage(image);
    // });
  }

  @override
  Widget build(BuildContext context) {
    TemplateTextSettingModelState modelState = ref.watch(widget.provider);
    TemplateTextSettingViewModel model = ref.read(widget.provider.notifier);
    return Container(
      decoration: BoxDecoration(border: Border.all(color: designColors.dark_03.auto(ref))),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;
          ui.Rect buttonRect = ui.Rect.fromCenter(
              center: Offset(translate(modelState.frameX + modelState.frameW, width), translate(modelState.frameY + modelState.frameH, height)),
              width: 24,
              height: 24);
          ui.Rect frameRect = ui.Rect.fromLTWH(
            translate(modelState.frameX, width),
            translate(modelState.frameY, height),
            translate(modelState.frameW, width),
            translate(modelState.frameH, height),
          );
          return GestureDetector(
            onPanStart: (details) {
              panStartLocation = details.localPosition;
              originalFrameLocation = Offset(translate(modelState.frameX, width), translate(modelState.frameY, height));
              originalFrameSize = Offset(translate(modelState.frameW, width), translate(modelState.frameH, height));
              scaling = false;
              panning = false;
              if (buttonRect.contains(details.localPosition)) {
                scaling = true;
              } else if (frameRect.contains(details.localPosition)) {
                panning = true;
              } else {}
            },
            onPanUpdate: (details) {
              if (modelState.frameLocked) {
                return;
              }
              var loc = details.localPosition;
              if (scaling) {
                var newWidth = (originalFrameSize.dx + loc.dx - panStartLocation.dx) / width * 100;
                var newHeight = (originalFrameSize.dy + loc.dy - panStartLocation.dy) / height * 100;
                if (newWidth < TemplateTextSettingView.MIN_SIZE_PERCENT) {
                  newWidth = TemplateTextSettingView.MIN_SIZE_PERCENT;
                } else if (modelState.frameX + newWidth > 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT) {
                  newWidth = 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT - modelState.frameX;
                }
                if (newHeight < TemplateTextSettingView.MIN_SIZE_PERCENT) {
                  newHeight = TemplateTextSettingView.MIN_SIZE_PERCENT;
                } else if (modelState.frameY + newHeight > 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT) {
                  newHeight = 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT - modelState.frameY;
                }
                model.updateFrameLocation(
                  modelState.frameX,
                  modelState.frameY,
                  newWidth,
                  newHeight,
                );
              } else if (panning) {
                var newX = (originalFrameLocation.dx + loc.dx - panStartLocation.dx) / width * 100;
                var newY = (originalFrameLocation.dy + loc.dy - panStartLocation.dy) / height * 100;
                if (newX < TemplateTextSettingView.MIN_MARGIN_PERCENT) {
                  newX = TemplateTextSettingView.MIN_MARGIN_PERCENT;
                } else if (modelState.frameW + newX > 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT) {
                  newX = 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT - modelState.frameW;
                }
                if (newY < TemplateTextSettingView.MIN_MARGIN_PERCENT) {
                  newY = TemplateTextSettingView.MIN_MARGIN_PERCENT;
                } else if (modelState.frameH + newY > 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT) {
                  newY = 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT - modelState.frameH;
                }
                model.updateFrameLocation(
                  newX,
                  newY,
                  modelState.frameW,
                  modelState.frameH,
                );
              }
            },
            child: CustomPaint(
              willChange: willChange,
              painter: _CanvasPainter(ref,
                  frameX: modelState.frameX,
                  frameY: modelState.frameY,
                  frameW: modelState.frameW,
                  frameH: modelState.frameH,
                  textColor: modelState.textColor,
                  frameLocked: modelState.frameLocked),
            ),
          );
        },
      ),
    );
  }

  double translate(double value, double size) {
    return value / 100 * size;
  }
}

class _CanvasPainter extends CustomPainter {
  final Color frameColor = Color(0xFFDBDBDB);
  final double textPadding = 8;

  final ui.Image buttonImage = scaleButtonImage;
  final double frameX;
  final double frameY;
  final double frameW;
  final double frameH;
  final Color textColor;
  final bool frameLocked;

  final Paint p = Paint();
  Offset? pointer;

  _CanvasPainter(
    WidgetRef ref, {
    required this.frameX,
    required this.frameY,
    required this.frameW,
    required this.frameH,
    required this.textColor,
    this.frameLocked = false,
  }) {
    p.strokeCap = StrokeCap.square;
    p.strokeWidth = 1;
    p.style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawFrame(canvas, size);
    drawButton(canvas, size);
    drawText(canvas, size);
  }

  void drawFrame(Canvas canvas, Size size) {
    p.color = frameColor;
    canvas.drawRect(
        Rect.fromLTWH(translate(frameX, size.width), translate(frameY, size.height), translate(frameW, size.width), translate(frameH, size.height)), p);
  }

  void drawButton(Canvas canvas, Size size) {
    if (buttonImage == null || frameLocked) {
      return;
    }
    ui.Rect src = Rect.fromLTWH(0, 0, buttonImage.width.toDouble(), buttonImage.height.toDouble());
    ui.Rect dst = Rect.fromCenter(center: Offset(translate(frameX + frameW, size.width), translate(frameY + frameH, size.height)), width: 24, height: 24);
    canvas.drawImageRect(buttonImage, src, dst, p);
  }

  void drawText(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: textColor,
      fontSize: 16,
    );
    final textSpan = TextSpan(
      text: 'here is the text box',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: translate(frameW, size.width) - textPadding * 2,
    );
    final offset = Offset(translate(frameX, size.width) + textPadding, translate(frameY, size.height) + textPadding);
    textPainter.paint(canvas, offset);
  }

  double translate(double value, double size) {
    return value / 100 * size;
  }

  @override
  bool shouldRepaint(_CanvasPainter oldDelegate) {
    return this != oldDelegate;
  }
}
