import 'dart:ui';

import 'package:app/extensions/extensions.dart';
import 'package:app/ui/pages/user/register/draw_badge_view_model.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'template_text_setting_view_model.g.dart';

@CopyWith()
class TemplateTextSettingPageModelState {
  final int selectedTab;
  final double frameX;
  final double frameY;
  final double frameW;
  final double frameH;
  final List<PaletteItem> paletteItems;

  TemplateTextSettingPageModelState({
    required this.selectedTab,
    required this.frameX,
    required this.frameY,
    required this.frameW,
    required this.frameH,
    required this.paletteItems,
  });

  factory TemplateTextSettingPageModelState.init(List<PaletteItem> paletteItems) =>
      TemplateTextSettingPageModelState(selectedTab: 0, frameX: 10, frameY: 10, frameW: 80, frameH: 40, paletteItems: paletteItems);
}

class TemplateTextSettingPageViewModel extends StateNotifier<TemplateTextSettingPageModelState> {
  TemplateTextSettingPageViewModel(TemplateTextSettingPageModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    // search(isRefresh: true);
  }

  void changeTab(int newTab) {
    updateState(state.copyWith(selectedTab: newTab));
  }

  Color setSelectedColor(int index) {
    for (var value in state.paletteItems) {
      value.selected = false;
    }
    state.paletteItems[index].selected = true;
    updateState(state.copyWith(paletteItems: [...state.paletteItems]));
    return state.paletteItems[index].color;
  }
}
