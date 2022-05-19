import 'package:app/extensions/extensions.dart';
import 'package:app/ui/pages/home/feeds.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'home_view_model.g.dart';

@CopyWith()
class HomePageModelState {
  final bool showFloatingButton;
  final int tabIndex;
  final int feedsTabIndex;

  HomePageModelState({
    this.tabIndex = HomeScreen.PAGE_INDEX_INPUT,
    this.feedsTabIndex = FeedsPage.PAGE_INDEX_MAIN,
    this.showFloatingButton = true,
  });

  factory HomePageModelState.init() => HomePageModelState();
}

class HomePageViewModel extends StateNotifier<HomePageModelState> {
  TabController? tabController;

  HomePageViewModel(HomePageModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
  }

  void setTabController(TabController controller) {
    tabController = controller;
  }

  void setShowFloatingButton(bool visible) {
    updateState(state.copyWith(showFloatingButton: visible));
  }

  void updateTabIndex(int index) {
    updateState(state.copyWith(tabIndex: index));
  }

  void updateFeedsTabIndex(int index, {bool notifyController = false}) {
    updateState(state.copyWith(feedsTabIndex: index));
    if (notifyController) {
      tabController?.index = index;
    }
  }
}
