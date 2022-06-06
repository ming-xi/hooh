import 'dart:ui' as ui;

import 'package:app/global.dart';
import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:blur/blur.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/template.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sprintf/sprintf.dart';

class TemplateDetailView extends ConsumerStatefulWidget {
  static const TYPE_FEEDS = 0;
  static const TYPE_DIALOG = 1;

  final Template template;
  final int type;

  final Function(Template template, HoohApiErrorResponse? error)? onFollow;

  const TemplateDetailView({
    required this.template,
    required this.type,
    this.onFollow,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TemplateDetailViewState();
}

class _TemplateDetailViewState extends ConsumerState<TemplateDetailView> {
  @override
  Widget build(BuildContext context) {
    Template template = widget.template;
    List<Positioned> children = [
      Positioned.fill(child: HoohImage(imageUrl: template.imageUrl)),
      Positioned(bottom: 12, left: 12, child: buildFavoriteButton(template)),
      Positioned(bottom: 12, right: 12, child: buildCreateButton(template)),
    ];
    User? user = ref.read(globalUserInfoProvider);
    if (user != null && widget.type == TemplateDetailView.TYPE_FEEDS) {
      // already login
      if (template.author!.id == user.id) {
        children.add(Positioned(top: 12, right: 12, child: buildMenuButton(template)));
      }
    }
    return Container(
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: Color(0x0C000000), offset: Offset(0, 8), blurRadius: 24)]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: children,
              ),
            ),
            Material(
              // padding: const EdgeInsets.only( top: 16, bottom: 20),

              color: designColors.light_01.auto(ref),
              child: Builder(builder: (context) {
                List<Widget> widgets = [];
                widgets.add(buildUserInfoRow(template));
                widgets.add(SizedBox(
                  height: 12,
                ));
                widgets.add(buildButtons(template));
                return Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  // padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widgets,
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget buildFavoriteButton(Template template, {Function(Template template)? onClick}) {
    return buildButtonBackground(
        width: 36,
        onClick: onClick,
        Center(
          child: HoohIcon(
            "assets/images/icon_template_bookmark_on.png",
            width: 16,
            color: template.favorited ? null : designColors.dark_01.auto(ref),
          ),
        ));
  }

  Widget buildMenuButton(Template template, {Function(Template template)? onClick}) {
    return buildButtonBackground(
        width: 36,
        onClick: onClick,
        Center(
          child: Icon(
            Icons.more_horiz_rounded,
            color: designColors.dark_01.auto(ref),
          ),
        ));
  }

  Widget buildCreateButton(Template template, {Function(Template template)? onClick}) {
    return buildButtonBackground(
        onClick: onClick,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                globalLocalizations.template_detail_use_this_template,
                style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 6,
              ),
              HoohIcon(
                "assets/images/icon_template_create.svg",
                width: 19,
                height: 19,
                color: designColors.dark_01.auto(ref),
              ),
            ],
          ),
        ));
  }

  Widget buildButtonBackground(Widget child, {double? width, Function(Template template)? onClick}) {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        width: width,
        height: 36,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: designColors.light_01.auto(ref).withOpacity(0.5)),
        child: InkWell(
          onTap: () {
            if (onClick != null) {
              onClick(widget.template);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }

  Builder buildButtons(Template template) {
    return Builder(builder: (context) {
      List<Widget> widgets = [
        HoohIcon(
          "assets/images/common_ore.svg",
          width: 24,
          height: 24,
        ),
        SizedBox(
          width: 8,
        ),
        SizedBox(
          width: 24,
          child: Text(
            formatAmount(template.profit),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref)),
          ),
        ),
        Spacer(),
        ...buildTitleAndAmount(globalLocalizations.template_detail_favorite_count, template.favoriteCount),
        SizedBox(
          width: 8,
        ),
        ...buildTitleAndAmount(globalLocalizations.template_detail_use_count, template.useCount),
      ];
      return Padding(
        padding: const EdgeInsets.only(left: 20, right: 8, bottom: 16),
        child: Row(
          children: widgets,
        ),
      );
    });
  }

  List<Widget> buildTitleAndAmount(String title, int amount) {
    return [
      Text(
        title,
        style: TextStyle(fontSize: 12, color: designColors.dark_03.auto(ref)),
      ),
      SizedBox(
        width: 6,
      ),
      SizedBox(
          width: 32,
          child: Text(
            formatAmount(amount),
            style: TextStyle(fontSize: 12, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold),
          )),
    ];
  }

  Widget buildUserInfoRow(Template template) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Builder(builder: (context) {
        List<Widget> widgets = buildUserInfo(template);
        widgets.add(SizedBox(
          width: 8,
        ));
        Widget? followButton = buildFollowButton(template);
        if (followButton != null) {
          widgets.add(followButton);
        } else {
          widgets.add(SizedBox(
            height: 40,
          ));
        }
        return Row(
          children: widgets,
        );
      }),
    );
  }

  List<Widget> buildUserInfo(Template template) {
    User author = template.author!;
    return [
      AvatarView.fromUser(author, size: 32),
      // HoohImage(
      //   imageUrl: author.avatarUrl!,
      //   cornerRadius: 100,
      //   width: 32,
      //   height: 32,
      // ),
      SizedBox(
        width: 8,
      ),
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              author.name,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: designColors.dark_00.auto(ref)),
            ),
            Text(
              DateUtil.getZonedDateString(template.createdAt!),
              style: TextStyle(fontSize: 10, color: designColors.light_06.auto(ref)),
            ),
          ],
        ),
      ),
    ];
  }

  Widget? buildFollowButton(Template template) {
    User? user = ref.watch(globalUserInfoProvider.state).state;
    User author = template.author!;
    if ((author.followed ?? false) || (user?.id == author.id)) {
      return null;
    }
    return _buildButton(
        text: Text(
          globalLocalizations.common_follow,
          style: TextStyle(fontFamily: 'Linotte'),
        ),
        isEnabled: true,
        onPress: () {
          onFollowPress(template);
        });
  }

  void onFollowPress(Template template) {
    if (template.author!.followed ?? false) {
      return;
    }
    network.requestAsync<void>(network.followUser(template.author!.id), (data) {
      if (widget.onFollow != null) {
        widget.onFollow!(template, null);
      }
    }, (error) {
      if (widget.onFollow != null) {
        widget.onFollow!(template, error);
      }
    });
  }

  Widget _buildButton({required Widget text, required bool isEnabled, required Function() onPress}) {
    ButtonStyle style = RegisterStyles.blueButtonStyle(ref, cornerRadius: 14).copyWith(
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        // fixedSize: MaterialStateProperty.all(Size(120,24)),
        minimumSize: MaterialStateProperty.all(Size(120, 40)),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap);
    if (!isEnabled) {
      style = style.copyWith(backgroundColor: MaterialStateProperty.all(designColors.dark_03.auto(ref)));
    }
    return TextButton(
      onPressed: onPress,
      child: text,
      style: style,
    );
  }
}

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

  TemplateView(
    this.setting, {
    required this.viewSetting,
    this.template,
    this.onPressBody,
    this.scale = 1,
    this.radius = 20,
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
    // if (widget.template != null && widget.viewSetting.buttons[TemplateView.EDGE_BUTTON_TYPE_INFO] != null) {
    //   widgets.add(buildUploaderWidget(visible, widget.template!.authorName));
    // }
    if (widget.template != null && widget.viewSetting.buttons[TemplateView.EDGE_BUTTON_TYPE_FAVORITE] != null) {
      widgets.add(getPositioned(widget.viewSetting.buttons[TemplateView.EDGE_BUTTON_TYPE_FAVORITE]!, buildFavoriteButton()));
    }
    if (widget.template != null && widget.viewSetting.buttons[TemplateView.EDGE_BUTTON_TYPE_INFO] != null) {
      widgets.add(getPositioned(widget.viewSetting.buttons[TemplateView.EDGE_BUTTON_TYPE_INFO]!, buildUploaderInfoButton()));
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

  Widget buildUploaderInfoButton() {
    var button = SizedBox(
      width: 44,
      height: 44,
      child: Center(
        child: HoohIcon('assets/images/image_info.svg', height: 17, width: 17),
      ),
    );
    return button;
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(widget.radius ?? 0), color: Color(TemplateView.MASK_COLOR)),
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
            fontFamily: widget.setting.fontFamily,
            bold: widget.setting.bold,
            drawShadow: widget.setting.shadow,
            drawStroke: widget.setting.stroke,
            lineHeight: widget.setting.lineHeight,
            showFrame: widget.viewSetting.showFrame,
            scale: widget.scale),
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
  final double fontSize;
  final String fontFamily;
  final double frameX; //0~100
  final double frameY; //0~100
  final double frameW; //0~100
  final double frameH; //0~100
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
    required this.fontFamily,
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
      fontFamily: fontFamily,
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
