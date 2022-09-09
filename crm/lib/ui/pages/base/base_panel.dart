import 'package:common/models/page_state.dart';
import 'package:crm/global.dart';
import 'package:crm/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class BasePanel extends ConsumerStatefulWidget {
  const BasePanel({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => createBaseState();

  BasePanelState createBaseState();
}

abstract class BasePanelState<T extends BasePanel> extends ConsumerState<T> {
  final RefreshController _refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    Orientation? orientation = ref.watch(globalOrientationProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          switch (orientation) {
            case Orientation.landscape:
              return buildHorizontalContainer();
            default:
              return buildVerticalContainer();
          }
        },
      ),
    );
  }

  Widget buildPageTitle(String title) {
    return Text(
      title,
      style: MainStyles.pageTitleStyle(ref),
    );
  }

  Widget buildRefreshButton({String text = "刷新"}) {
    return buildGeneralButton(
        text: text,
        onClick: () {
          requestData(horizontalLayout: true, isRefresh: true);
        });
  }

  Widget buildGeneralButton({required String text, Function()? onClick}) {
    return MainStyles.blueButton(ref, text, onClick);
  }

  Widget buildDefaultRefresher({RefreshController? controller, Widget? header, required Widget sliverBody, bool canRefresh = true, bool canLoadMore = true}) {
    return SmartRefresher(
      enablePullDown: canRefresh,
      enablePullUp: canLoadMore,
      header: MainStyles.getRefresherHeader(ref),
      onRefresh: () async {
        requestData(horizontalLayout: false, isRefresh: true);
      },
      onLoading: () async {
        requestData(horizontalLayout: false, isRefresh: false);
      },
      controller: controller ?? _refreshController,
      child: CustomScrollView(
        // controller: scrollController,
        slivers: [
          header == null
              ? null
              : SliverToBoxAdapter(
                  child: header,
                ),
          sliverBody
        ].where((element) => element != null).map((e) => e!).toList(),
      ),
    );
  }

  void requestData({bool horizontalLayout = false, bool isRefresh = true});

  void notifyRefreshComplete() {
    if (ref.watch(globalOrientationProvider) == Orientation.portrait) {
      _refreshController.refreshCompleted();
      _refreshController.resetNoData();
    }
  }

  void notifyLoadMoreComplete(PageState state) {
    if (ref.watch(globalOrientationProvider) == Orientation.portrait) {
      if (state == PageState.noMore) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  Widget buildVerticalContainer();

  Widget buildHorizontalContainer();
}
