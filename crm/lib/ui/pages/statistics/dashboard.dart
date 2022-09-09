import 'package:crm/ui/pages/base/base_panel.dart';
import 'package:crm/ui/pages/statistics/dashboard_view_model.dart';
import 'package:crm/utils/constants.dart';
import 'package:crm/utils/design_colors.dart';
import 'package:crm/utils/ui_util.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DashboardPage extends BasePanel {
  final StateNotifierProvider<DashboardPageViewModel, DashboardPageModelState> provider = StateNotifierProvider((ref) {
    return DashboardPageViewModel(DashboardPageModelState.init());
  });

  DashboardPage({super.key});

  @override
  BasePanelState<DashboardPage> createBaseState() => _DashboardPageState();
}

class _DashboardPageState extends BasePanelState<DashboardPage> {
  @override
  Widget buildHorizontalContainer() {
    DashboardPageViewModel model = ref.read(widget.provider.notifier);
    DashboardPageModelState modelState = ref.watch(widget.provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, children: [
          buildPageTitle(Constants.PAGE_NAME_STATISTICS),
          Spacer(),
        ]),
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            SizedBox(
              width: 100,
              child: buildRefreshButton(),
            )
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Expanded(
            child: CustomScrollView(slivers: [
          SliverToBoxAdapter(
              child: Material(
            type: MaterialType.transparency,
            child: Wrap(
              // spacing: 12,
              // runSpacing: 12,
              children: buildCards(),
            ),
          ))
        ]))
      ],
    );
  }

  List<Widget> buildCards() {
    DashboardPageModelState modelState = ref.watch(widget.provider);
    return [buildCard(modelState.total, "总用户数"), buildCard(modelState.totalReal, "总真实用户数"), buildCard(modelState.yesterdayLoginUsers, "昨日登录用户数")];
  }

  Widget buildCard(dynamic title, String content) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Ink(
        decoration: BoxDecoration(color: designColors.light_01.auto(ref), borderRadius: BorderRadius.circular(12), boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: Offset(0, 1),
            blurRadius: 3,
          )
        ]),
        child: InkWell(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 120, maxWidth: 240),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title == null ? "计算中..." : title.toString(),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref)),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      content,
                      style: TextStyle(color: designColors.dark_03.auto(ref)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildVerticalContainer() {
    return Material(
        type: MaterialType.transparency,
        child: buildDefaultRefresher(
            canLoadMore: false,
            sliverBody: SliverList(
                delegate: SliverChildListDelegate(
              buildCards(),
            ))));
  }

  @override
  void requestData({bool horizontalLayout = false, bool isRefresh = true}) {
    DashboardPageViewModel model = ref.read(widget.provider.notifier);
    model.getUserStatistics(
      onSuccess: (state) {
        if (isRefresh) {
          notifyRefreshComplete();
        } else {
          notifyLoadMoreComplete(state);
        }
      },
      onFailed: (error) {
        showCommonRequestErrorDialog(ref, context, error);
      },
    );
  }
}
