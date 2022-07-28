import 'package:app/global.dart';
import 'package:app/ui/pages/me/activities_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/ui/widgets/empty_views.dart';
import 'package:app/ui/widgets/user_activity_view.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

class UserActivityScreen extends ConsumerStatefulWidget {
  final String userId;

  late final StateNotifierProvider<ActivitiesScreenViewModel, ActivitiesScreenModelState> provider;

  UserActivityScreen({
    required this.userId,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return ActivitiesScreenViewModel(ActivitiesScreenModelState.init(userId));
    });
  }

  @override
  ConsumerState createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends ConsumerState<UserActivityScreen> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HoohAppBar(title: Text(globalLocalizations.me_tile_trends)),
      floatingActionButton: SafeArea(
          child: SizedBox(
        width: 40,
        height: 40,
        child: FloatingActionButton(
            backgroundColor: designColors.feiyu_blue.auto(ref),
            onPressed: () {
              scrollController.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.easeOutCubic);
            },
            child: HoohIcon(
              "assets/images/icon_back_to_top.svg",
              width: 16,
              color: designColors.light_01.light,
            )),
      )),
      body: UserActivityPage(
        scrollController: scrollController,
        provider: widget.provider,
      ),
    );
  }
}

class UserActivityPage extends ConsumerStatefulWidget {
  final StateNotifierProvider<ActivitiesScreenViewModel, ActivitiesScreenModelState> provider;
  final ScrollController? scrollController;

  UserActivityPage({
    required this.provider,
    this.scrollController,
    Key? key,
  }) : super(key: key) {}

  @override
  ConsumerState createState() => _UserActivityPageState();

  static List<Widget> buildGridView(
      BuildContext context, WidgetRef ref, ActivitiesScreenModelState modelState, ActivitiesScreenViewModel model, double topPadding) {
    List objs = _prepareGroupedItems(context, modelState.activities);
    List<Widget> list = objs.map((e) {
      if (e is String) {
        return SliverToBoxAdapter(child: _buildDateHeader(ref, e, objs.indexOf(e), topPadding));
      } else if (e is List<UserActivity>) {
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => UserActivityView(
                user: modelState.user!,
                activity: e[index],
                onDelete: (activity) {
                  model.onDeleteActivity(activity);
                },
              ),
              childCount: e.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 4, childAspectRatio: 165 / 211),
          ),
        );
      } else {
        return Container();
      }
    }).toList();
    // return CustomScrollView(
    //   slivers: list,
    // );
    return list;
  }

  static List<dynamic> _prepareGroupedItems(BuildContext context, List<UserActivity> activities) {
    List<dynamic> objs = [];
    List<UserActivity> temp = [];
    DateTime now = DateTime.now();
    int lastHoursAgo = 0;
    bool isFirst = true;
    int i = 0;
    for (; i < activities.length; i++) {
      UserActivity activity = activities[i];
      DateTime date = DateUtil.getZonedDate(activity.createdAt);
      Duration diff = now.difference(date);
      int hoursAgo = diff.inHours;
      if (hoursAgo > 24) {
        break;
      }
      if (isFirst || hoursAgo == lastHoursAgo) {
        // same section
        temp.add(activity);
        if (isFirst) {
          lastHoursAgo = hoursAgo;
          isFirst = false;
        }
      } else {
        // next time range section
        objs.add(sprintf(AppLocalizations.of(context)!.datetime_ago, [AppLocalizations.of(context)!.hour(lastHoursAgo)]));
        objs.add(temp);
        temp = [activity];
        lastHoursAgo = hoursAgo;
      }
    }
    if (temp.isNotEmpty) {
      DateTime date = DateUtil.getZonedDate(temp.first.createdAt);
      Duration diff = now.difference(date);
      int hoursAgo = diff.inHours;
      objs.add(sprintf(AppLocalizations.of(context)!.datetime_ago, [AppLocalizations.of(context)!.hour(hoursAgo)]));
      objs.add(temp);
    }
    temp = [];
    String? lastDate;
    isFirst = true;
    for (; i < activities.length; i++) {
      UserActivity activity = activities[i];
      String date = DateUtil.getZonedDateString(activity.createdAt, format: DateUtil.FORMAT_ONLY_DATE);
      if (isFirst || date == lastDate) {
        // same section
        temp.add(activity);
        if (isFirst) {
          lastDate = date;
          isFirst = false;
        }
      } else {
        // next time range section
        objs.add(lastDate);
        objs.add(temp);
        temp = [activity];
        lastDate = date;
      }
    }
    if (temp.isNotEmpty) {
      objs.add(DateUtil.getZonedDateString(temp.first.createdAt, format: DateUtil.FORMAT_ONLY_DATE));
      objs.add(temp);
    }
    return objs;
  }

  // GridView buildGridView(ActivitiesScreenModelState modelState) {
  //   return GridView.builder(
  //     padding: EdgeInsets.all(20),
  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 4, childAspectRatio: 165 / 211),
  //     itemBuilder: (context, index) => UserActivityView(
  //       user: modelState.user!,
  //       activity: modelState.activities[index],
  //     ),
  //     itemCount: modelState.activities.length,
  //   );
  // }

  static Widget _buildDateHeader(WidgetRef ref, String dateString, int index, double topPadding) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12, top: index == 0 ? topPadding : 40, left: 20, right: 20),
      child: Text(
        dateString,
        style: TextStyle(fontSize: 18, color: designColors.light_06.auto(ref), fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _UserActivityPageState extends ConsumerState<UserActivityPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    ActivitiesScreenModelState modelState = ref.watch(widget.provider);
    ActivitiesScreenViewModel model = ref.read(widget.provider.notifier);

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: MainStyles.getRefresherHeader(ref),
      onRefresh: () async {
        model.getActivities((state) {
          // debugPrint("refresh state=$state");
          _refreshController.refreshCompleted();
          _refreshController.resetNoData();
        });
      },
      onLoading: () async {
        model.getActivities((state) {
          if (state == PageState.noMore) {
            _refreshController.loadNoData();
            // debugPrint("load no more state=$state");
          } else {
            _refreshController.loadComplete();
            // debugPrint("load complete state=$state");
          }
        }, isRefresh: false);
      },
      controller: _refreshController,
      child: modelState.activities.isEmpty
          ? EmptyView(text: globalLocalizations.empty_view_no_activities)
          : CustomScrollView(
              controller: widget.scrollController,
              slivers: UserActivityPage.buildGridView(context, ref, modelState, model, 20),
            ),
    );
  }
}
