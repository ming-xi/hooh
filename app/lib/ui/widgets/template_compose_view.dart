import 'dart:ui' as ui;

import 'package:app/global.dart';
import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/utils/app_link.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:blur/blur.dart';
import 'package:common/models/template.dart';
import 'package:common/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sprintf/sprintf.dart';

class TemplateView extends ConsumerStatefulWidget {
  static const MASK_COLOR = 0x59000000;

  static const SCENE_CUSTOM = 0;
  static const SCENE_GALLERY_HOME = 1;
  static const SCENE_GALLERY_SEARCH = 2;
  static const SCENE_EDIT_POST_SINGLE_IMAGE_RECOMMENDATION = 3;
  static const SCENE_EDIT_POST_MULTIPLE_IMAGE_GRID = 4;
  static const SCENE_EDIT_POST_CANVAS = 5;
  static const SCENE_PUBLISH_POST_PREVIEW = 6;

  //边缘按钮类型
  static const EDGE_BUTTON_TYPE_FAVORITE = 1;
  static const EDGE_BUTTON_TYPE_INFO = 2;
  static const EDGE_BUTTON_TYPE_DELETE = 3;
  static const EDGE_BUTTON_TYPE_EDIT = 4;

  final PostImageSetting setting;
  final Template? template;
  final double scale;
  final double? radius;
  final void Function()? onPressBody;
  final TemplateViewSetting viewSetting;
  final Function(double)? onFontSizeChanged;

  TemplateView(
    this.setting, {
    required this.viewSetting,
    this.template,
    this.onPressBody,
    this.scale = 1,
    this.radius = 20,
    this.onFontSizeChanged,
    Key? key,
  }) : super(key: key) {}

  static TemplateViewSetting generateViewSetting(int scene) {
    bool showFrame = false;
    Map<int, EdgeButtonSetting> buttons = {};
    switch (scene) {
      case SCENE_GALLERY_HOME:
      case SCENE_GALLERY_SEARCH:
      case SCENE_EDIT_POST_SINGLE_IMAGE_RECOMMENDATION:
        {
          buttons[EDGE_BUTTON_TYPE_FAVORITE] = EdgeButtonSetting(
            location: EdgeButtonLocation.topRight,
          );
          buttons[EDGE_BUTTON_TYPE_INFO] = EdgeButtonSetting(
            location: EdgeButtonLocation.bottomRight,
          );
          break;
        }
      case SCENE_EDIT_POST_MULTIPLE_IMAGE_GRID:
        {
          buttons[EDGE_BUTTON_TYPE_DELETE] = EdgeButtonSetting(
            location: EdgeButtonLocation.topRight,
          );
          break;
        }
      case SCENE_EDIT_POST_CANVAS:
        {
          showFrame = true;
          break;
        }
      case SCENE_PUBLISH_POST_PREVIEW:
        {
          showFrame = false;
          break;
        }
    }
    return TemplateViewSetting(buttons: buttons, showFrame: showFrame);
  }

  @override
  ConsumerState createState() => _TemplateViewState();
}

class _TemplateViewState extends ConsumerState<TemplateView> {
  StateProvider<bool> visibleProvider = StateProvider(
    (ref) => false,
  );

  @override
  Widget build(BuildContext context) {
    var visible = ref.watch(visibleProvider);
    List<Widget> widgets = [
      Positioned.fill(child: Container(child: buildMainImage())),
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
    // if (widget.template != null && widget.viewSetting.buttons[TemplateView.EDGE_BUTTON_TYPE_INFO] != null) {
    //   widgets.add(buildUploaderWidget(visible, widget.template!.authorName));
    // }
    if (widget.template != null && widget.viewSetting.buttons[TemplateView.EDGE_BUTTON_TYPE_FAVORITE] != null) {
      widgets.add(getPositioned(widget.viewSetting.buttons[TemplateView.EDGE_BUTTON_TYPE_FAVORITE]!, buildFavoriteButton()));
    }
    if (widget.template != null && widget.viewSetting.buttons[TemplateView.EDGE_BUTTON_TYPE_INFO] != null) {
      widgets.add(getPositioned(widget.viewSetting.buttons[TemplateView.EDGE_BUTTON_TYPE_INFO]!, buildUploaderInfoButton(widget.template!)));
    }
    return ClipRect(
      child: Stack(
        children: widgets,
      ),
    );
  }

  Positioned getPositioned(EdgeButtonSetting setting, Widget widget) {
    double? top;
    double? bottom;
    double? left;
    double? right;
    switch (setting.location) {
      case EdgeButtonLocation.topLeft:
        top = 0;
        left = 0;
        break;
      case EdgeButtonLocation.topRight:
        top = 0;
        right = 0;
        break;
      case EdgeButtonLocation.bottomLeft:
        bottom = 0;
        left = 0;
        break;
      case EdgeButtonLocation.bottomRight:
        bottom = 0;
        right = 0;
        break;
    }
    return Positioned(
      child: widget,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
    );
  }

  Widget buildUploaderInfoButton(Template template) {
    var button = const SizedBox(
      width: 44,
      height: 44,
      child: Center(
        child: HoohIcon('assets/images/image_info.svg', height: 17, width: 17),
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: button,
      onTap: () {
        var link = getTemplateAppLink(template.id);
        debugPrint("link=$link");
        openAppLink(context, link, ref: ref);
      },
    );
    // return GestureDetector(
    //   behavior: HitTestBehavior.translucent,
    //   onTapCancel: () {
    //     ref.read(visibleProvider.state).state = false;
    //   },
    //   onTapDown: (details) {
    //     ref.read(visibleProvider.state).state = true;
    //   },
    //   onTapUp: (details) {
    //     ref.read(visibleProvider.state).state = false;
    //   },
    //   child: button,
    // );
  }

  Widget buildMaskView() {
    return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius ?? 0),
          color: const Color(TemplateView.MASK_COLOR)),
    ));
  }

  Widget buildTextView() {
    return Positioned.fill(
      child: CustomPaint(
        willChange: false,
        // painter: PostTextPainter2(),
        painter: PostTextPainter(widget.setting.text!, widget.setting.textColor,
            frameX: widget.setting.frameX,
            frameY: widget.setting.frameY,
            frameW: widget.setting.frameW,
            frameH: widget.setting.frameH,
            fontFamily: widget.setting.fontFamily,
            fontSize: widget.setting.fontSize,
            alignment: widget.setting.alignment,
            bold: widget.setting.bold,
            drawShadow: widget.setting.shadow,
            drawStroke: widget.setting.stroke,
            lineHeight: widget.setting.lineHeight,
            showFrame: widget.viewSetting.showFrame,
            scale: widget.scale,
            userChanged: widget.setting.userChanged,
            onFontSizeChanged: widget.onFontSizeChanged),
      ),
    );
  }

  Widget buildFavoriteButton() {
    return SizedBox(
      width: 44,
      height: 44,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: (Center(
          child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(shape: BoxShape.circle, color: designColors.light_06.auto(ref).withOpacity(0.3)),
              child: Center(
                  child: HoohIcon('assets/images/icon_template_bookmark_on.png',
                      color: widget.template!.favorited ? null : designColors.light_01.auto(ref), width: 16))),
        )),
        onTap: () {
          if (widget.viewSetting.buttons[TemplateView.EDGE_BUTTON_TYPE_FAVORITE]?.onPress != null) {
            widget.viewSetting.buttons[TemplateView.EDGE_BUTTON_TYPE_FAVORITE]?.onPress!(!widget.template!.favorited);
          }
        },
      ),
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
    return widget.setting.blur ? child.blurred(blur: 4, borderRadius: BorderRadius.circular(widget.radius ?? 0)) : child;
  }

  Widget buildUploaderWidget(bool visible, String uploaderName) {
    return Visibility(
      visible: visible,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius ?? 0),
          color: Colors.black.withAlpha(40),
        ),
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Text(
                sprintf(globalLocalizations.recommended_templates_uploaded_by, [uploaderName]),
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

class PostTextPainter extends CustomPainter {
  final ui.Image buttonImage = scaleButtonImage;
  final double textPadding = 8;
  final double scale;

  final Color textColor;
  final String text;
  final bool drawShadow;
  final bool drawStroke;
  final bool bold;
  final bool showFrame;
  double lineHeight;
  double? fontSize;
  final String fontFamily;
  final TextAlignment alignment;
  final double frameX; //0~100
  final double frameY; //0~100
  final double frameW; //0~100
  final double frameH; //0~100
  late final double strokeWidth = 2;
  final Paint p = Paint();
  final TextPainter tp = TextPainter(
    textDirection: TextDirection.ltr,
  );
  final Function(double)? onFontSizeChanged;
  bool userChanged;

  PostTextPainter(
    this.text,
    this.textColor, {
    required this.frameX,
    required this.frameY,
    required this.frameW,
    required this.frameH,
    required this.fontFamily,
    required this.onFontSizeChanged,
    this.alignment = TextAlignment.left,
    this.drawShadow = false,
    this.drawStroke = false,
    this.userChanged = false,
    this.bold = false,
    this.fontSize,
    this.showFrame = true,
    this.lineHeight = 0,
    this.scale = 1,
  }) {
    p.strokeCap = StrokeCap.square;
    p.strokeWidth = 1;
    // p.style = PaintingStyle.stroke;
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
    p.style = PaintingStyle.stroke;
    p.color = textColor.withOpacity(0.5);
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
      drawTextInternal(canvas, size);
    }
    // draw text body
    p.color = textColor;
    p.style = PaintingStyle.fill;
    drawTextInternal(canvas, size);
  }

  bool shouldUseLightStroke(Color color) {
    return (color.red + color.green + color.blue) / 3 <= 0x45;
  }

  void drawTextInternal(Canvas canvas, Size size) {
    TextStyle textStyle = TextStyle(
      fontSize: fontSize,
      fontFamily: fontFamily,
      height: lineHeight,
      fontWeight: !bold ? null : FontWeight.bold,
      shadows: !drawShadow
          ? null
          : [
              const Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 4.0,
                color: Color(TemplateView.MASK_COLOR),
              ),
            ],
      foreground: p,
    );

    Map<TextAlignment, ui.TextAlign> alignMap = {
      TextAlignment.left: TextAlign.left,
      TextAlignment.center: TextAlign.center,
      TextAlignment.right: TextAlign.right,
    };
    // tp.text = TextSpan(
    //   text: text,
    //   style: textStyle,
    // );
    tp.textAlign = alignMap[alignment]!;
    if (!userChanged) {
      // if (fontSize == null) {
      debugPrint("_calculateProperFontSize");
      var lastSize = fontSize;
      fontSize = _calculateProperFontSize(textStyle, size);
      if (lastSize != fontSize && onFontSizeChanged != null) {
        onFontSizeChanged!(fontSize!);
      }
      // }
    }
    debugPrint("userChanged=$userChanged fontSize=$fontSize");
    tp.text = TextSpan(
      text: text,
      style: textStyle.copyWith(fontSize: fontSize),
    );
    tp.markNeedsLayout();
    tp.layout(
      // minWidth:0,
      minWidth: translate(frameW, size.width) - textPadding * 2,
      maxWidth: translate(frameW, size.width) - textPadding * 2,
    );
    ui.Offset offset;
    if (!userChanged) {
      offset = Offset(
          translate(frameX, size.width) + textPadding,
          translate(frameY, size.height) +
              (translate(frameH, size.height) - tp.height) / 2);
    } else {
      offset = Offset(translate(frameX, size.width) + textPadding,
          translate(frameY, size.height) + textPadding);
    }
    tp.paint(canvas, offset);
  }

  double _calculateProperFontSize(TextStyle textStyle, Size size) {
    if (text.isEmpty) {
      return 24;
    }
    var currentUtcDate = DateUtil.getCurrentUtcDate();
    double properFontSize = 8;
    double tempFontSize = 8;
    int lift = 40;
    var frameHeight = translate(frameH, size.height);
    // debugPrint("frameY=$frameY size.height=${size.height}");
    bool outOfBox = false;
    int calculateCount = 0;
    while (!outOfBox) {
      final span = TextSpan(
        text: text,
        style: textStyle.copyWith(fontSize: tempFontSize),
      );
      tp.text = span;
      tp.layout(
        minWidth: 0,
        maxWidth: translate(frameW, size.width) - textPadding * 2,
      );
      // debugPrint("text=${text.substring(0, min(4, text.length))} size=$tempFontSize lift=$lift [${tp.size.height}/$frameHeight]");
      if (tp.size.height > frameHeight) {
        if (lift == 1) {
          outOfBox = true;
        } else {
          tempFontSize -= lift;
          lift ~/= 2;
          tempFontSize += lift;
        }
      } else {
        properFontSize = tempFontSize;
        tempFontSize += lift;
      }
      calculateCount++;
    }
    debugPrint("$calculateCount counts in ${DateUtil.getCurrentUtcDate().difference(currentUtcDate).inMilliseconds}ms");
    return properFontSize;
  }

  double translate(double value, double size) {
    return value / 100 * size;
  }

  @override
  bool shouldRepaint(PostTextPainter oldDelegate) {
    return this != oldDelegate;
  }
}

class PostTextPainter2 extends CustomPainter {
  final Paint p = Paint();
  Color textColor = Colors.blue;
  double fontSize = 100;
  String fontFamily = 'Linotte';
  final TextPainter tp = TextPainter(
    textDirection: TextDirection.ltr,
  );

  PostTextPainter2() {
    p.strokeCap = StrokeCap.square;
    p.strokeWidth = 1;
  }

  @override
  bool? hitTest(ui.Offset position) {
    // return super.hitTest(position);
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawText(canvas, size);
  }

  void drawText(Canvas canvas, Size size) {
    // draw text stroke
    p.color = Colors.black;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 1;
    drawTextInternal(canvas, size);
    // draw text body
    p.color = textColor;
    p.style = PaintingStyle.fill;
    drawTextInternal(canvas, size);
  }

  void drawTextInternal(Canvas canvas, Size size) {
    tp.text = TextSpan(
      text: "Test",
      style: TextStyle(
        fontSize: fontSize,
        // fontFamily: fontFamily,
        height: 1,
        foreground: p,
      ),
    );
    tp.layout(
      // minWidth:0,
      minWidth: 200,
      maxWidth: 200,
    );
    tp.paint(canvas, Offset(-100, -100));
  }

  @override
  bool shouldRepaint(PostTextPainter2 oldDelegate) {
    return this != oldDelegate;
  }
}

class TemplateViewSetting {
  final bool showFrame;
  final Map<int, EdgeButtonSetting> buttons;

  TemplateViewSetting({required this.buttons, this.showFrame = false});
}

class EdgeButtonSetting {
  final EdgeButtonLocation location;
  Function(dynamic data)? onPress;

  EdgeButtonSetting({required this.location, this.onPress});
}

enum EdgeButtonLocation { topLeft, topRight, bottomLeft, bottomRight }
