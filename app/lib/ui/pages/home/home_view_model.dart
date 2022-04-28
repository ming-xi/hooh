import 'package:app/extensions/extensions.dart';
import 'package:app/ui/pages/home/templates_view_model.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'home_view_model.g.dart';

@CopyWith()
class HomePageModelState {
  final TemplatesPageModelState templatesPageModelState;
  final bool showFloatingButton;
  final int tabIndex;

  HomePageModelState({
    required this.templatesPageModelState,
    this.showFloatingButton = true,
    this.tabIndex = 0,
  });

  factory HomePageModelState.init() => HomePageModelState(templatesPageModelState: TemplatesPageModelState.init());
}

class HomePageViewModel extends StateNotifier<HomePageModelState> {
  HomePageViewModel(HomePageModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
  }

  void setShowFloatingButton(bool visible) {
    updateState(state.copyWith(showFloatingButton: visible));
  }

  void updateTabIndex(int index) {
    updateState(state.copyWith(tabIndex: index));
  }
}
