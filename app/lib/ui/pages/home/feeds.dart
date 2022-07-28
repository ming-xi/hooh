import 'package:app/global.dart';
import 'package:app/ui/pages/feeds/followed_users.dart';
import 'package:app/ui/pages/feeds/main_list.dart';
import 'package:app/ui/pages/feeds/waiting_list.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/home/home_view_model.dart';
import 'package:app/utils/design_colors.dart';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FeedsPage extends ConsumerStatefulWidget {
  static const PAGE_INDEX_FOLLOWED = 0;
  static const PAGE_INDEX_MAIN = 1;
  static const PAGE_INDEX_WAITING = 2;

  static const double LIST_TOP_PADDING = 16;
  static const double LIST_BOTTOM_PADDING = 100;
  final List<Widget> tabWidgets = [
    FollowedUserPostsPage(),
    MainListPage(),
    WaitingListPage(),
  ];

  FeedsPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _FeedsPageState();
}

class _FeedsPageState extends ConsumerState<FeedsPage> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    HomePageModelState homeModelState = ref.read(homePageProvider);
    HomePageViewModel homeModel = ref.read(homePageProvider.notifier);
    tabController = TabController(length: 3, vsync: this, initialIndex: homeModelState.feedsTabIndex);
    tabController.addListener(() {
      // if (tabController.index == 0) {
      //   node.requestFocus();
      // } else {
      //   FocusManager.instance.primaryFocus?.unfocus();
      // }
      // EditPostScreenViewModel model = ref.read(widget.provider.notifier);
      // model.changeTab(tabController.index);
      homeModel.updateFeedsTabIndex(tabController.index);
    });
    homeModel.setTabController(tabController);
  }

  @override
  Widget build(BuildContext context) {
    // important! make it change text when locale changes
    ref.watch(globalLocaleProvider);
    HomePageModelState homeModelState = ref.watch(homePageProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Material(
            color: designColors.light_00.auto(ref),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.search_rounded,
                    color: Colors.transparent,
                  ),
                  onPressed: null,
                ),
                Expanded(
                  child: TabBar(controller: tabController, indicatorSize: TabBarIndicatorSize.tab, tabs: [
                    Tab(
                      text: globalLocalizations.feeds_tag_following,
                    ),
                    Tab(
                      text: globalLocalizations.feeds_tag_main,
                    ),
                    Tab(
                      text: globalLocalizations.feeds_tag_waiting_list,
                    ),
                  ]),
                ),
                IconButton(
                  icon: Icon(
                    Icons.search_rounded,
                    color: Colors.transparent,
                  ),
                  onPressed: null,
                ),
                // IconButton(
                //   icon: HoohIcon(
                //     "assets/images/icon_search.svg",
                //     color: designColors.dark_01.auto(ref),
                //     width: 20,
                //     height: 20,
                //   ),
                //   onPressed: () {},
                // )
              ],
            ),
          ),
        ).frosted(
          blur: 10,
          frostColor: designColors.light_01.auto(ref),
          frostOpacity: 0.9,
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: widget.tabWidgets,
      ),
    );
  }
}
