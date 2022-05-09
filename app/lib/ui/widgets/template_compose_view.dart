import 'dart:ui' as ui;

import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:blur/blur.dart';
import 'package:common/models/template.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TemplateView extends ConsumerStatefulWidget {
  static const int MASK_COLOR = 0x59000000;
  final PostImageSetting setting;
  final Template? template;
  final double scale;
  final double? radius;
  final bool showUploaderInfoButton;
  final void Function(bool)? onFavoriteChange;
  final void Function()? onPressBody;

  final bool showFrame;

  const TemplateView(
    this.setting, {
    this.showUploaderInfoButton = true,
    this.template,
    this.onFavoriteChange,
    this.onPressBody,
    this.scale = 1,
    this.radius = 20,
    this.showFrame = false,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TemplateViewState();
}

class _TemplateViewState extends ConsumerState<TemplateView> {
  StateProvider<bool> visibleProvider = StateProvider(
    (ref) => false,
  );

  @override
  Widget build(BuildContext context) {
    var visible = ref.watch(visibleProvider.state).state;
    List<Widget> widgets = [
      buildMainImage(),
    ];
    if (widget.setting.mask) {
      widgets.add(buildMaskView());
    }
    if (widget.setting.text != null) {
      widgets.add(buildTextView());
    }
    if (widget.onPressBody != null) {
      widgets.add(Material(
        color: Colors.transparent,
        child: Ink(
          child: InkWell(
            borderRadius: widget.radius != null ? BorderRadius.circular(widget.radius!) : null,
            onTap: () {
              if (widget.onPressBody != null) {
                widget.onPressBody!();
              }
            },
            child: Container(),
          ),
        ),
      ));
    }
    if (widget.template != null && widget.showUploaderInfoButton) {
      widgets.add(buildUploaderWidget(visible, widget.template!.authorName));
    }
    if (widget.template != null && widget.onFavoriteChange != null) {
      widgets.add(buildFavoriteButton());
    }
    if (widget.template != null && widget.showUploaderInfoButton) {
      widgets.add(buildUploaderInfoButton());
    }
    return ClipRect(
      child: Stack(
        children: widgets,
      ),
    );
  }

  Positioned buildUploaderInfoButton() {
    return Positioned(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapCancel: () {
          ref.read(visibleProvider.state).state = false;
        },
        onTapDown: (details) {
          ref.read(visibleProvider.state).state = true;
        },
        onTapUp: (details) {
          ref.read(visibleProvider.state).state = false;
        },
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: HoohIcon('assets/images/image_info.svg', height: 17, width: 17),
          ),
        ),
      ),
      bottom: 0,
      right: 0,
    );
  }

  Widget buildMaskView() {
    return Positioned.fill(
        child: Container(
      color: Color(TemplateView.MASK_COLOR),
    ));
  }

  Widget buildTextView() {
    return Positioned.fill(
      child: CustomPaint(
        willChange: false,
        painter: PostTextPainter(widget.setting.text!, widget.setting.textColor,
            frameX: widget.setting.frameX,
            frameY: widget.setting.frameY,
            frameW: widget.setting.frameW,
            frameH: widget.setting.frameH,
            fontSize: widget.setting.fontSize,
            bold: widget.setting.bold,
            drawShadow: widget.setting.shadow,
            drawStroke: widget.setting.stroke,
            lineHeight: widget.setting.lineHeight,
            showFrame: widget.showFrame,
            scale: widget.scale),
      ),
    );
  }

  Widget buildFavoriteButton() {
    return Positioned(
      child: SizedBox(
        width: 44,
        height: 44,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: (Center(
            child: HoohIcon(widget.template!.favorited ? 'assets/images/collection_selected.svg' : 'assets/images/collection_unselected.svg',
                height: 27, width: 27),
          )),
          onTap: () {
            if (widget.onFavoriteChange != null) {
              widget.onFavoriteChange!(!widget.template!.favorited);
            }
          },
        ),
      ),
      top: 0,
      right: 0,
    );
  }

  Widget buildMainImage() {
    // debugPrint("widget.setting=${widget.setting}");
    Widget child;
    if (widget.setting.imageUrl != null) {
      child = HoohImage(
        imageUrl: widget.setting.imageUrl!,
        cornerRadius: widget.radius ?? 0,
      );
    } else {
      var image = Image.file(
        widget.setting.imageFile!,
      );
      if (widget.radius != 0) {
        child = ClipRRect(
          child: image,
          borderRadius: BorderRadius.circular(widget.radius!),
        );
      } else {
        child = image;
      }
    }
    return widget.setting.blur ? child.blurred(blur: 4) : child;
  }

  Widget buildUploaderWidget(bool visible, String uploaderName) {
    return Visibility(
      visible: visible,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black.withAlpha(40),
        ),
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Text(
                '图片由 @${uploaderName} 作者上传',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            )),
      ),
    );
  }
}

class TextView extends StatelessWidget {
  const TextView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class PostTextPainter extends CustomPainter {
  final ui.Image buttonImage = scaleButtonImage;
  final double textPadding = 8;
  final double scale;

  late final Color textColor;
  late final String text;
  late final bool drawShadow;
  late final bool drawStroke;
  late final bool bold;
  late final bool showFrame;
  late double lineHeight;
  late final double fontSize;
  late final double frameX; //0~100
  late final double frameY; //0~100
  late final double frameW; //0~100
  late final double frameH; //0~100
  late final double strokeWidth = 2;
  final Paint p = Paint();

  PostTextPainter(
    this.text,
    this.textColor, {
    required this.frameX,
    required this.frameY,
    required this.frameW,
    required this.frameH,
    required this.fontSize,
    this.drawShadow = false,
    this.drawStroke = false,
    this.bold = false,
    this.showFrame = true,
    this.lineHeight = 0,
    this.scale = 1,
  }) {
    p.strokeCap = StrokeCap.square;
    p.strokeWidth = 1;
    p.style = PaintingStyle.stroke;
    // WidgetsBinding? binding = WidgetsBinding.instance;
    // double devicePixelRatio = binding!.window.devicePixelRatio;
    // // 4px
    // strokeWidth=4/devicePixelRatio;
  }

  @override
  bool? hitTest(ui.Offset position) {
    // return super.hitTest(position);
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // debugPrint("size=$size");
    canvas.save();
    canvas.scale(scale, scale);
    Size newSize = Size(size.width / scale, size.height / scale);
    drawFrame(canvas, newSize);
    drawButton(canvas, newSize);
    drawText(canvas, newSize);
    canvas.restore();
  }

  void drawFrame(Canvas canvas, Size size) {
    if (!showFrame) {
      return;
    }
    p.color = textColor;
    canvas.drawRect(
        Rect.fromLTWH(translate(frameX, size.width), translate(frameY, size.height), translate(frameW, size.width), translate(frameH, size.height)), p);
  }

  void drawButton(Canvas canvas, Size size) {
    if (!showFrame) {
      return;
    }
    ui.Rect src = Rect.fromLTWH(0, 0, buttonImage.width.toDouble(), buttonImage.height.toDouble());
    ui.Rect dst = Rect.fromCenter(center: Offset(translate(frameX + frameW, size.width), translate(frameY + frameH, size.height)), width: 24, height: 24);
    canvas.drawImageRect(buttonImage, src, dst, p);
  }

  void drawText(Canvas canvas, Size size) {
    // draw text stroke
    if (drawStroke) {
      p.color = shouldUseLightStroke(textColor) ? Colors.white : Colors.black;
      p.style = PaintingStyle.stroke;
      p.strokeWidth = strokeWidth;
      drawTextInternal(canvas, size, p);
    }
    // draw text body
    p.color = textColor;
    p.style = PaintingStyle.fill;
    drawTextInternal(canvas, size, p);
  }

  bool shouldUseLightStroke(Color color) {
    return (color.red + color.green + color.blue) / 3 <= 0x45;
  }

  void drawTextInternal(Canvas canvas, Size size, Paint paint) {
    final textStyle = TextStyle(
      fontSize: fontSize,
      height: lineHeight,
      fontWeight: !bold ? null : FontWeight.bold,
      shadows: !drawShadow
          ? null
          : [
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 4.0,
                color: Color(TemplateView.MASK_COLOR),
              ),
            ],
      foreground: paint,
    );
    final textSpan = TextSpan(
      text: text,
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
  bool shouldRepaint(PostTextPainter oldDelegate) {
    return this != oldDelegate;
  }
}
