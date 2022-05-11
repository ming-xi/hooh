import 'package:app/ui/pages/feeds/waiting_list.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FeedsPage extends ConsumerStatefulWidget {
  const FeedsPage({
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
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      // if (tabController.index == 0) {
      //   node.requestFocus();
      // } else {
      //   FocusManager.instance.primaryFocus?.unfocus();
      // }
      // EditPostScreenViewModel model = ref.read(widget.provider.notifier);
      // model.changeTab(tabController.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(
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
                child: TabBar(controller: tabController, tabs: [
                  Tab(
                    text: "Following",
                  ),
                  Tab(
                    text: "Main",
                  ),
                  Tab(
                    text: "Waiting",
                  ),
                ]),
              ),
              IconButton(
                icon: HoohIcon(
                  "assets/images/icon_search.svg",
                  color: designColors.dark_01.auto(ref),
                  width: 20,
                  height: 20,
                ),
                onPressed: () {},
              )
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          Container(
            color: Colors.red,
          ),
          Container(
            color: Colors.blue,
          ),
          WaitingListPage(),
        ],
      ),
    );
  }
}
