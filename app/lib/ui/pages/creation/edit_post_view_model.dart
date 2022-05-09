import 'dart:io';
import 'dart:ui';

import 'package:app/extensions/extensions.dart';
import 'package:app/ui/pages/user/register/draw_badge_view_model.dart';
import 'package:app/ui/widgets/template_text_setting_view.dart';
import 'package:app/utils/creation_strategy.dart';
import 'package:common/models/template.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'edit_post_view_model.g.dart';

@CopyWith()
class EditPostScreenModelState {
  final int selectedTab;
  final PostImageSetting setting;
  final List<PaletteItem> paletteItems;
  final bool frameLocked;
  final bool touchingFrame;

  EditPostScreenModelState({required this.selectedTab, required this.setting, required this.paletteItems, this.frameLocked = true, this.touchingFrame = false});

  factory EditPostScreenModelState.init(List<PaletteItem> paletteItems, PostImageSetting setting) {
    return EditPostScreenModelState(selectedTab: 0, setting: setting, paletteItems: paletteItems, frameLocked: false);
  }
// factory EditPostScreenModelState.withTemplate(List<PaletteItem> paletteItems, Template template, {String? text}) {
//   return EditPostScreenModelState(selectedTab: 0, setting: PostImageSetting.withTemplate(template, text: text), paletteItems: paletteItems);
// }
//
// factory EditPostScreenModelState.withLocalImage(
//   List<PaletteItem> paletteItems,
//   File imageFile,
//   Color textColor, {
//   String? text,
// }) =>
//     EditPostScreenModelState(selectedTab: 0, setting: PostImageSetting.withLocalFile(imageFile, textColor, text: text), paletteItems: paletteItems);
}

class EditPostScreenViewModel extends StateNotifier<EditPostScreenModelState> {
  EditPostScreenViewModel(EditPostScreenModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    // search(isRefresh: true);
  }

  void changeTab(int newTab) {
    updateState(state.copyWith(selectedTab: newTab));
  }

  void setTouchingFrame(bool touching) {
    updateState(state.copyWith(touchingFrame: touching));
  }

  void setText(String text) {
    updateState(state.copyWith(setting: state.setting.copyWith(text: text)));
  }

  void toggleDrawMask() {
    updateState(state.copyWith(setting: state.setting.copyWith(mask: !state.setting.mask)));
  }

  void toggleDrawShadow() {
    updateState(state.copyWith(setting: state.setting.copyWith(shadow: !state.setting.shadow)));
  }

  void toggleDrawStroke() {
    updateState(state.copyWith(setting: state.setting.copyWith(stroke: !state.setting.stroke)));
  }

  void toggleBold() {
    updateState(state.copyWith(setting: state.setting.copyWith(bold: !state.setting.bold)));
  }

  void toggleBlur() {
    updateState(state.copyWith(setting: state.setting.copyWith(blur: !state.setting.blur)));
  }

  void increaseFontSize() {
    updateState(state.copyWith(setting: state.setting.copyWith(fontSize: state.setting.fontSize + 1)));
  }

  void decreaseFontSize() {
    updateState(state.copyWith(setting: state.setting.copyWith(fontSize: state.setting.fontSize - 1)));
  }

  void increaseLineHeight() {
    updateState(state.copyWith(setting: state.setting.copyWith(lineHeight: state.setting.lineHeight + 0.1)));
  }

  void decreaseLineHeight() {
    updateState(state.copyWith(setting: state.setting.copyWith(lineHeight: state.setting.lineHeight - 0.1)));
  }

  Color setSelectedColor(int index) {
    for (var value in state.paletteItems) {
      value.selected = false;
    }
    state.paletteItems[index].selected = true;
    updateState(state.copyWith(paletteItems: [...state.paletteItems], setting: state.setting.copyWith(textColor: state.paletteItems[index].color)));
    return state.paletteItems[index].color;
  }

  void setFrameLocked(bool locked) {
    updateState(state.copyWith(frameLocked: locked));
  }

  void updateFrameLocation(double x, double y, double width, double height) {
    updateState(state.copyWith(
        setting: state.setting.copyWith(
      frameX: x,
      frameY: y,
      frameW: width,
      frameH: height,
    )));
  }
}

@CopyWith()
class PostImageSetting {
  final File? imageFile;
  final String? imageUrl;
  final String? text;
  final Color textColor;
  final double frameX;
  final double frameY;
  final double frameW;
  final double frameH;
  final double fontSize;
  final TextAlignment alignment;
  final bool shadow;
  final bool stroke;
  final bool mask;
  final bool bold;
  final bool blur;
  final double lineHeight;

  PostImageSetting(
      {this.imageFile,
      this.imageUrl,
      this.text,
      required this.textColor,
      required this.frameX,
      required this.frameY,
      required this.frameW,
      required this.frameH,
      required this.fontSize,
      this.alignment = TextAlignment.left,
      this.shadow = false,
      this.stroke = false,
      this.mask = false,
      this.bold = false,
      this.blur = false,
      this.lineHeight = 1.0});

  factory PostImageSetting.withLocalFile(File imageFile, Color textColor, {String? text}) => PostImageSetting(
      imageFile: imageFile,
      text: text,
      textColor: textColor,
      fontSize: CreationStrategy.calculateFontSize(text ?? ""),
      lineHeight: CreationStrategy.calculateLineHeight(text ?? ""),
      frameX: TemplateTextSettingView.MIN_MARGIN_PERCENT,
      frameY: TemplateTextSettingView.MIN_MARGIN_PERCENT,
      frameW: 100 - 2 * TemplateTextSettingView.MIN_MARGIN_PERCENT,
      frameH: 100 - 2 * TemplateTextSettingView.MIN_MARGIN_PERCENT);

  factory PostImageSetting.withTemplate(Template template, {String? text}) => PostImageSetting(
      imageUrl: template.imageUrl,
      text: text,
      textColor: HexColor.fromHex(template.textColor),
      fontSize: CreationStrategy.calculateFontSize(text ?? ""),
      lineHeight: CreationStrategy.calculateLineHeight(text ?? ""),
      frameX: double.tryParse(template.frameX)!,
      frameY: double.tryParse(template.frameY)!,
      frameW: double.tryParse(template.frameWidth)!,
      frameH: double.tryParse(template.frameHeight)!);

  @override
  String toString() {
    return 'PostImageSetting{imageFile: $imageFile, imageUrl: $imageUrl, text: $text, textColor: $textColor, frameX: $frameX, frameY: $frameY, frameW: $frameW, frameH: $frameH, fontSize: $fontSize, alignment: $alignment, shadow: $shadow, stroke: $stroke, mask: $mask, bold: $bold, blur: $blur, letterSpacing: $lineHeight}';
  }
}

enum TextAlignment { left, center, right }
