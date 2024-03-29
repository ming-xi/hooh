import 'dart:math';
import 'dart:ui' as ui;

import 'package:app/global.dart';
import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/ui/pages/creation/publish_post.dart';
import 'package:app/ui/pages/home/input_view_model.dart';
import 'package:app/ui/pages/user/register/draw_badge_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/ui/widgets/template_compose_view.dart';
import 'package:app/ui/widgets/template_text_setting_view.dart';
import 'package:app/utils/creation_strategy.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EditPostScreen extends ConsumerStatefulWidget {
  static const PALETTE_COLORS = [
    Color(0xFFFFFFFF),
    Color(0xFF000000),
    Color(0xFFD2D2D2),
    Color(0xFFCF3A08),
    Color(0xFF2C7FFF),
    Color(0xFFFF7800),
    Color(0xFF1E942F),
    Color(0xFF643CFF),
    Color(0xFFF03C00),
    Color(0xFF004DC4),
    Color(0xFFFFD232),
    Color(0xFF50DC64),
    Color(0xFFB414FF),
    Color(0xFFFF5064),
    Color(0xFF5AC8FA),
    Color(0xFF5A2800),
    Color(0xFF50DCC6),
    Color(0xFFFF14D9),
  ];
  late final StateNotifierProvider<EditPostScreenViewModel, EditPostScreenModelState> provider;

  // final PostImageSetting setting;

  EditPostScreen({
    required PostImageSetting setting,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      if (setting.text == null || setting.text!.isEmpty) {
        setting = setting.copyWith(fontSize: CreationStrategy.getEmptyTextDefaultFontSize());
      }
      List<PaletteItem> colors =
          PALETTE_COLORS.map((e) => PaletteItem(color: e, type: PALETTE_COLORS.indexOf(e) < 2 ? PaletteItem.TYPE_OUTLINED : PaletteItem.TYPE_NORMAL)).toList();
      colors.firstWhere((element) => element.color.value == setting.textColor.value, orElse: () => colors[0]).selected = true;
      List<FontItem> fonts = CreationStrategy.FONT_LIST.map((e) => FontItem(fontFamily: e)).toList();
      fonts.firstWhere((element) => element.fontFamily == setting.fontFamily, orElse: () => fonts[0]).selected = true;
      return EditPostScreenViewModel(EditPostScreenModelState.init(colors, fonts, setting));
    });
  }

  @override
  ConsumerState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> with TickerProviderStateMixin {
  late TabController tabController;
  TextEditingController textController = TextEditingController();
  FocusNode node = FocusNode();

  bool userChangedContent = false;
  bool panning = false;
  bool scaling = false;
  int touchStartTime = 0;
  late Offset panStartLocation;
  late Offset originalFrameLocation;
  late Offset originalFrameSize;

  @override
  void initState() {
    super.initState();
    EditPostScreenModelState modelState = ref.read(widget.provider);
    tabController = TabController(length: 2, vsync: this);
    textController.text = modelState.setting.text ?? "";
    tabController.addListener(() {
      if (tabController.index == 0) {
        node.requestFocus();
      } else {
        hideKeyboard();
      }
      EditPostScreenViewModel model = ref.read(widget.provider.notifier);
      model.changeTab(tabController.index);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (textController.text.isNotEmpty) {
        tabController.index = 1;
      } else {
        showKeyboard(ref, node);
      }
    });
  }

  double translate(double value, double size) {
    return value / 100 * size;
  }

  @override
  Widget build(BuildContext context) {
    EditPostScreenViewModel model = ref.read(widget.provider.notifier);
    EditPostScreenModelState modelState = ref.watch(widget.provider);
    double tabbarHeight = 54;
    double statusbarHeight = MediaQuery.of(context).viewPadding.top;
    HoohAppBar appBar = HoohAppBar(
      title: Text(globalLocalizations.common_edit),
      actions: [
        IconButton(
            onPressed: () async {
              EditPostScreenModelState modelState = ref.watch(widget.provider);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PublishPostScreen(
                            setting: modelState.setting,
                          )));
            },
            icon: HoohIcon(
              "assets/images/icon_arrow_next.svg",
              width: 24,
              height: 24,
              color: designColors.dark_01.auto(ref),
            ))
      ],
    );
    var size2 = MediaQuery.of(context).size;
    // Size screenSize = Size(size2.width,size2.height+size2.width);
    Size screenSize = size2;
    // screenSize.height+=screenSize.width;

    return WillPopScope(
      onWillPop: () async {
        if (userChangedContent) {
          bool? result = await showHoohDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (popContext) {
                return AlertDialog(
                  content: Text(globalLocalizations.edit_post_discard_change_dialog_title),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(popContext).pop(true);
                        },
                        child: Text(globalLocalizations.common_discard)),
                    TextButton(
                        onPressed: () {
                          Navigator.of(popContext).pop(false);
                        },
                        child: Text(globalLocalizations.common_cancel))
                  ],
                );
              });
          return Future.value(result ?? false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        appBar: appBar,
        body: Stack(
          children: [
            Positioned.fill(
              child: ListView(
                physics: modelState.touchingFrame ? NeverScrollableScrollPhysics() : ScrollPhysics(),
                children: [
                  AspectRatio(aspectRatio: 1, child: buildMainView()),
                  SizedBox(
                    height: tabbarHeight,
                    child: TabBar(
                      controller: tabController,
                      tabs: [
                        Tab(
                          icon: HoohIcon(
                            "assets/images/icon_edit_post_edit_selected.svg",
                            width: 36,
                            height: 36,
                            color: modelState.selectedTab == 0 ? designColors.dark_01.auto(ref) : designColors.dark_03.auto(ref),
                          ),
                        ),
                        Tab(
                          icon: HoohIcon(
                            "assets/images/icon_edit_post_style_selected.svg.svg",
                            width: 36,
                            height: 36,
                            color: modelState.selectedTab == 1 ? designColors.dark_01.auto(ref) : designColors.dark_03.auto(ref),
                          ),
                        ),
                      ],
                      // indicatorColor: designColors.dark_01.auto(ref),
                      // indicatorSize: TabBarIndicatorSize.label,
                    ),
                  ),
                  SizedBox(
                    // height: screenSize.height - appBar.preferredSize.height - screenSize.width - tabbarHeight-statusbarHeight,
                    height: 204,
                    child: TabBarView(controller: tabController, children: [
                      buildInputTab(),
                      buildStyleTab(modelState, model),
                    ]),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Visibility(
                  visible: modelState.selectedTab == 0,
                  child: SizedBox(
                    height: min(screenSize.height - appBar.preferredSize.height - screenSize.width - tabbarHeight - statusbarHeight, 130),
                    child: buildFloatingInputPanel(),
                  )),
            )
          ],
        ),
      ),
    );
  }

  Widget buildMainView() {
    EditPostScreenViewModel model = ref.read(widget.provider.notifier);
    EditPostScreenModelState modelState = ref.watch(widget.provider);
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;
        ui.Rect buttonRect = ui.Rect.fromCenter(
            center: Offset(translate(modelState.setting.frameX + modelState.setting.frameW, width),
                translate(modelState.setting.frameY + modelState.setting.frameH, height)),
            width: 48,
            height: 48);
        ui.Rect frameRect = ui.Rect.fromLTWH(
          translate(modelState.setting.frameX, width),
          translate(modelState.setting.frameY, height),
          translate(modelState.setting.frameW, width),
          translate(modelState.setting.frameH, height),
        );
        TemplateViewSetting viewSetting = TemplateView.generateViewSetting(TemplateView.SCENE_EDIT_POST_CANVAS);
        debugPrint("modelState.setting.userChanged=${modelState.setting.userChanged}");
        var child = TemplateView(
          modelState.setting,
          viewSetting: viewSetting,
          radius: 0,
          onFontSizeChanged: (fontSize) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              model.setFontSize(fontSize);
            });
          },
        );
        return Listener(
          onPointerDown: (details) {
            if (buttonRect.contains(details.localPosition)) {
              model.setTouchingFrame(true);
            } else if (frameRect.contains(details.localPosition)) {
              model.setTouchingFrame(true);
            } else {}
            touchStartTime = DateUtil.getCurrentUtcDate().millisecondsSinceEpoch;
            panStartLocation = details.localPosition;
            originalFrameLocation = Offset(translate(modelState.setting.frameX, width), translate(modelState.setting.frameY, height));
            originalFrameSize = Offset(translate(modelState.setting.frameW, width), translate(modelState.setting.frameH, height));

            scaling = false;
            panning = false;
            if (buttonRect.contains(details.localPosition)) {
              scaling = true;
            } else if (frameRect.contains(details.localPosition)) {
              panning = true;
            } else {}
          },
          onPointerUp: (details) {
            if (modelState.touchingFrame) {
              if (DateUtil.getCurrentUtcDate().millisecondsSinceEpoch - touchStartTime < 500) {
                ui.Offset endLocation = details.localPosition;
                var dx = (panStartLocation.dx - endLocation.dx);
                var dy = (panStartLocation.dy - endLocation.dy);
                if (sqrt(dx * dx + dy * dy) < 16) {
                  //click
                  tabController.index = 0;
                }
              }
            }
            model.setTouchingFrame(false);
          },
          onPointerCancel: (details) {
            model.setTouchingFrame(false);
          },
          onPointerMove: (details) {
            if (modelState.frameLocked) {
              return;
            }
            var loc = details.localPosition;
            if (scaling) {
              // setUserChangedContent();
              var newWidth = (originalFrameSize.dx + loc.dx - panStartLocation.dx) / width * 100;
              var newHeight = (originalFrameSize.dy + loc.dy - panStartLocation.dy) / height * 100;
              if (newWidth < TemplateTextSettingView.MIN_SIZE_PERCENT) {
                newWidth = TemplateTextSettingView.MIN_SIZE_PERCENT;
              } else if (modelState.setting.frameX + newWidth > 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT) {
                newWidth = 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT - modelState.setting.frameX;
              }
              if (newHeight < TemplateTextSettingView.MIN_SIZE_PERCENT) {
                newHeight = TemplateTextSettingView.MIN_SIZE_PERCENT;
              } else if (modelState.setting.frameY + newHeight > 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT) {
                newHeight = 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT - modelState.setting.frameY;
              }
              model.updateFrameLocation(
                modelState.setting.frameX,
                modelState.setting.frameY,
                newWidth,
                newHeight,
              );
            } else if (panning) {
              // setUserChangedContent();
              var newX = (originalFrameLocation.dx + loc.dx - panStartLocation.dx) / width * 100;
              var newY = (originalFrameLocation.dy + loc.dy - panStartLocation.dy) / height * 100;
              if (newX < TemplateTextSettingView.MIN_MARGIN_PERCENT) {
                newX = TemplateTextSettingView.MIN_MARGIN_PERCENT;
              } else if (modelState.setting.frameW + newX > 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT) {
                newX = 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT - modelState.setting.frameW;
              }
              if (newY < TemplateTextSettingView.MIN_MARGIN_PERCENT) {
                newY = TemplateTextSettingView.MIN_MARGIN_PERCENT;
              } else if (modelState.setting.frameH + newY > 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT) {
                newY = 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT - modelState.setting.frameH;
              }
              model.updateFrameLocation(
                newX,
                newY,
                modelState.setting.frameW,
                modelState.setting.frameH,
              );
            }
          },
          child: child,
        );

        // return GestureDetector(
        //   onTapDown: (details) {
        //     debugPrint("onTapDown");
        //     setState(() {
        //       if (buttonRect.contains(details.localPosition)) {
        //         touchingFrame = true;
        //       } else if (frameRect.contains(details.localPosition)) {
        //         touchingFrame = true;
        //       } else {
        //         touchingFrame = false;
        //       }
        //     });
        //   },
        //   onPanStart: (details) {
        //     panStartLocation = details.localPosition;
        //     originalFrameLocation = Offset(translate(modelState.setting.frameX, width), translate(modelState.setting.frameY, height));
        //     originalFrameSize = Offset(translate(modelState.setting.frameW, width), translate(modelState.setting.frameH, height));
        //     debugPrint("onPanStart panStartLocation=$panStartLocation originalFrameLocation=$originalFrameLocation originalFrameSize=$originalFrameSize\n"
        //         "buttonRect=$buttonRect  frameRect=$frameRect  ");
        //
        //     scaling = false;
        //     panning = false;
        //     if (buttonRect.contains(details.localPosition)) {
        //       scaling = true;
        //     } else if (frameRect.contains(details.localPosition)) {
        //       panning = true;
        //     } else {}
        //   },
        //   onPanEnd: (details){
        //     touchingFrame = false;
        //   },
        //   onPanCancel: (){
        //     touchingFrame = false;
        //   },
        //   onPanUpdate: (details) {
        //     // debugPrint("onPanUpdate scaling=$scaling panning=$panning");
        //     if (modelState.frameLocked) {
        //       return;
        //     }
        //     var loc = details.localPosition;
        //     if (scaling) {
        //       var newWidth = (originalFrameSize.dx + loc.dx - panStartLocation.dx) / width * 100;
        //       var newHeight = (originalFrameSize.dy + loc.dy - panStartLocation.dy) / height * 100;
        //       if (newWidth < TemplateTextSettingView.MIN_SIZE_PERCENT) {
        //         newWidth = TemplateTextSettingView.MIN_SIZE_PERCENT;
        //       } else if (modelState.setting.frameX + newWidth > 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT) {
        //         newWidth = 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT - modelState.setting.frameX;
        //       }
        //       if (newHeight < TemplateTextSettingView.MIN_SIZE_PERCENT) {
        //         newHeight = TemplateTextSettingView.MIN_SIZE_PERCENT;
        //       } else if (modelState.setting.frameY + newHeight > 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT) {
        //         newHeight = 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT - modelState.setting.frameY;
        //       }
        //       model.updateFrameLocation(
        //         modelState.setting.frameX,
        //         modelState.setting.frameY,
        //         newWidth,
        //         newHeight,
        //       );
        //     } else if (panning) {
        //       var newX = (originalFrameLocation.dx + loc.dx - panStartLocation.dx) / width * 100;
        //       var newY = (originalFrameLocation.dy + loc.dy - panStartLocation.dy) / height * 100;
        //       if (newX < TemplateTextSettingView.MIN_MARGIN_PERCENT) {
        //         newX = TemplateTextSettingView.MIN_MARGIN_PERCENT;
        //       } else if (modelState.setting.frameW + newX > 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT) {
        //         newX = 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT - modelState.setting.frameW;
        //       }
        //       if (newY < TemplateTextSettingView.MIN_MARGIN_PERCENT) {
        //         newY = TemplateTextSettingView.MIN_MARGIN_PERCENT;
        //       } else if (modelState.setting.frameH + newY > 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT) {
        //         newY = 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT - modelState.setting.frameH;
        //       }
        //       model.updateFrameLocation(
        //         newX,
        //         newY,
        //         modelState.setting.frameW,
        //         modelState.setting.frameH,
        //       );
        //     }
        //   },
        //   child: child,
        // );
      },
    );
  }

  void setUserChangedContent() {
    // var lastStatus = userChangedContent;
    userChangedContent = true;
    // if (lastStatus != userChangedContent) {
    debugPrint("setUserChangedContent");
    EditPostScreenViewModel model = ref.read(widget.provider.notifier);
    model.setUserChanged(userChangedContent);
    // }
  }

  Widget buildFloatingInputPanel() {
    return Container(
      color: designColors.dark_01.auto(ref).withOpacity(0.5),
      child: Row(
        children: [
          Expanded(
            child: SafeArea(
              child: TextField(
                style: TextStyle(color: designColors.light_01.auto(ref)),
                decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(8)),
                controller: textController,
                focusNode: node,
                maxLength: InputPageModelState.MAX_CONTENT_LENGTH,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                  return null;
                },
                expands: true,
                maxLines: null,
                onChanged: (text) {
                  // setUserChangedContent();
                  EditPostScreenViewModel model = ref.read(widget.provider.notifier);
                  model.setText(text);
                },
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              tabController.index = 1;
            },
            child: HoohIcon(
              "assets/images/icon_ok.svg",
              width: 24,
              height: 24,
              color: Colors.white,
            ),
            style: RegisterStyles.blueButtonStyle(ref, cornerRadius: 0)
                .copyWith(minimumSize: MaterialStateProperty.all(Size.fromWidth(24)), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          )
        ],
      ),
    );
  }

  Widget buildInputTab() {
    return Container();
    // return TextField(
    //   controller: textController,
    //   focusNode: node,
    //   expands: true,
    //   maxLines: null,
    //   onChanged: (text){
    //     // EditPostScreenViewModel model = ref.read(widget.provider.notifier);
    //     // model.updateText(text);
    //   },
    // );
  }

  Widget buildStyleTab(EditPostScreenModelState modelState, EditPostScreenViewModel model) {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        Spacer(),
        buildFonts(model, modelState),
        Spacer(),
        buildPalette(model, modelState),
        Spacer(),
        buildButtons(),
        Spacer(),
        // buildButtons(),
      ],
    );
  }

  Widget buildButtons() {
    EditPostScreenModelState modelState = ref.watch(widget.provider);
    EditPostScreenViewModel model = ref.read(widget.provider.notifier);
    double itemSize = 36;
    double spacing = 6;
    double spacingLarge = 10;
    Map<TextAlignment, String> alignmentMap = {
      TextAlignment.left: "assets/images/icon_font_style_align_left.svg",
      TextAlignment.center: "assets/images/icon_font_style_align_center.svg",
      TextAlignment.right: "assets/images/icon_font_style_align_right.svg",
    };
    return SizedBox(
      height: itemSize,
      child: ListView(scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal: 16), children: [
        Material(
          color: designColors.light_00.auto(ref),
          type: MaterialType.transparency,
          child: Ink(
            width: itemSize,
            height: itemSize,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: false ? designColors.feiyu_blue.auto(ref) : designColors.dark_03.auto(ref),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: const BorderRadius.all(const Radius.circular(12)),
              onTap: () {
                model.cycleAlignment();
              },
              child: HoohIcon(
                alignmentMap[modelState.setting.alignment]!,
                width: itemSize,
                height: itemSize,
                color: designColors.dark_01.auto(ref),
              ),
            ),
          ),
        ),
        SizedBox(
          width: spacingLarge,
        ),
        MainStyles.outlinedIconButton(ref, "assets/images/icon_font_style_shadow.png", itemSize, modelState.setting.shadow, () {
          model.toggleDrawShadow();
          // setUserChangedContent();
        }),
        SizedBox(
          width: spacing,
        ),
        MainStyles.outlinedIconButton(ref, "assets/images/icon_font_style_stroke.svg", itemSize, modelState.setting.stroke, () {
          model.toggleDrawStroke();
          // setUserChangedContent();
        }),
        SizedBox(
          width: spacing,
        ),
        MainStyles.outlinedIconButton(ref, "assets/images/icon_font_style_mask.svg", itemSize, modelState.setting.mask, () {
          model.toggleDrawMask();
          // setUserChangedContent();
        }),
        SizedBox(
          width: spacing,
        ),
        MainStyles.outlinedIconButton(ref, "assets/images/icon_font_style_bold.svg", itemSize, modelState.setting.bold, () {
          model.toggleBold();
          // setUserChangedContent();
        }),
        SizedBox(
          width: spacing,
        ),
        MainStyles.outlinedIconButton(ref, "assets/images/icon_font_style_blur.svg", itemSize, modelState.setting.blur, () {
          model.toggleBlur();
          // setUserChangedContent();
        }),
        SizedBox(
          width: spacingLarge,
        ),
        MainStyles.outlinedIconButton(ref, "assets/images/icon_font_style_size_plus.svg", itemSize, false, () {
          model.increaseFontSize();
          setUserChangedContent();
        }),
        SizedBox(
          width: spacing,
        ),
        MainStyles.outlinedIconButton(ref, "assets/images/icon_font_style_size_minus.svg", itemSize, false, () {
          model.decreaseFontSize();
          setUserChangedContent();
        }),
        SizedBox(
          width: spacingLarge,
        ),
        MainStyles.outlinedIconButton(ref, "assets/images/icon_font_style_spacing_plus.svg", itemSize, false, () {
          model.increaseLineHeight();
          setUserChangedContent();
        }),
        SizedBox(
          width: spacing,
        ),
        MainStyles.outlinedIconButton(ref, "assets/images/icon_font_style_spacing_minus.svg", itemSize, false, () {
          model.decreaseLineHeight();
          setUserChangedContent();
        }),
      ]),
    );
  }

  Widget buildFonts(EditPostScreenViewModel model, EditPostScreenModelState modelState) {
    double itemSize = 36;
    double padding = 8;
    double borderRadius = 12;

    return SizedBox(
      height: itemSize,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount: modelState.fontItems.length,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => SizedBox(
          width: 8,
        ),
        itemBuilder: (context, index) {
          FontItem item = modelState.fontItems[index];
          return Ink(
              decoration: BoxDecoration(
                color: item.selected ? designColors.light_02.auto(ref) : Colors.transparent,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: InkWell(
                onTap: () {
                  // setUserChangedContent();
                  model.setSelectedFont(index);
                },
                borderRadius: BorderRadius.circular(borderRadius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      item.fontFamily,
                      style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref), fontFamily: item.fontFamily, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ));
        },
      ),
    );
  }

  Widget buildPalette(EditPostScreenViewModel model, EditPostScreenModelState modelState) {
    double itemSize = 40;
    double padding = 8;
    double borderRadius = 12;
    double outlineBorderRadius = 14;

    return SizedBox(
      height: itemSize + padding * 2,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: padding),
        itemCount: modelState.paletteItems.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          PaletteItem item = modelState.paletteItems[index];
          Widget res;
          Border selectedBorder = Border.all(color: item.selected ? designColors.feiyu_blue.auto(ref) : Colors.transparent, width: 0.5);

          switch (item.type) {
            case PaletteItem.TYPE_NORMAL:
              {
                res = Ink(
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    child: InkWell(
                      onTap: () {
                        // setUserChangedContent();
                        model.setSelectedColor(index);
                      },
                      borderRadius: BorderRadius.circular(borderRadius),
                    ));
                break;
              }
            case PaletteItem.TYPE_OUTLINED:
            default:
              {
                res = Ink(
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(color: designColors.dark_01.auto(ref), width: 0.5),
                    ),
                    child: InkWell(
                      onTap: () {
                        // setUserChangedContent();
                        model.setSelectedColor(index);
                      },
                      borderRadius: BorderRadius.circular(borderRadius),
                    ));
                break;
              }
          }
          return Container(
              width: itemSize,
              height: itemSize,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(border: selectedBorder, borderRadius: BorderRadius.circular(outlineBorderRadius)),
              child: res);
        },
      ),
    );
  }
}
