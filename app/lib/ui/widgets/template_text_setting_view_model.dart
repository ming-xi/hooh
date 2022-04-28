import 'dart:ui';

import 'package:app/extensions/extensions.dart';
import 'package:app/ui/widgets/template_text_setting_view.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart' as material;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math';

part 'template_text_setting_view_model.g.dart';

@CopyWith()
class TemplateTextSettingModelState {
  final double frameX;
  final double frameY;
  final double frameW;
  final double frameH;
  final material.Color textColor;
  final Image? buttonImage;
  final bool frameLocked;

  TemplateTextSettingModelState(
      {required this.frameX,
      required this.frameY,
      required this.frameW,
      required this.frameH,
      required this.textColor,
      this.buttonImage,
      this.frameLocked = false});

  factory TemplateTextSettingModelState.init(material.Color textColor) => TemplateTextSettingModelState(
        frameX: TemplateTextSettingView.MIN_MARGIN_PERCENT,
        frameY: TemplateTextSettingView.MIN_MARGIN_PERCENT,
        frameW: 100 - TemplateTextSettingView.MIN_MARGIN_PERCENT * 2,
        frameH: (100 - TemplateTextSettingView.MIN_MARGIN_PERCENT * 2) / 2,
        textColor: textColor,
      );
}

class TemplateTextSettingViewModel extends StateNotifier<TemplateTextSettingModelState> {
  TemplateTextSettingViewModel(TemplateTextSettingModelState state) : super(state) {}

  void setButtonImage(Image image) {
    updateState(state.copyWith(buttonImage: image));
  }

  void setSelectedColor(material.Color color) {
    updateState(state.copyWith(textColor: color));
  }

  void setFrameLocked(bool locked) {
    updateState(state.copyWith(frameLocked: locked));
  }

  void updateFrameLocation(double x, double y, double width, double height) {
    updateState(state.copyWith(
      frameX: x,
      frameY: y,
      frameW: width,
      frameH: height,
    ));
  }
}
