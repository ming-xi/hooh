import 'package:app/global.dart';
import 'package:app/ui/pages/me/followers_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/user.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class FollowerScreen extends ConsumerStatefulWidget {
  final String userId;
  final bool isFollower;

  const FollowerScreen({
    required this.userId,
    this.isFollower = true,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _FollowerScreenState();
}

class _FollowerScreenState extends ConsumerState<FollowerScreen> with TickerProviderStateMixin {
  late TabController tabController;
  int selectedTab = 0;
  late List<FollowerPage> pages;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: widget.isFollower ? 0 : 1);
    tabController.addListener(() {
      setState(() {
        selectedTab = tabController.index;
      });
    });
    pages = [
      FollowerPage(
        userId: widget.userId,
        isFollower: true,
      ),
      FollowerPage(
        userId: widget.userId,
        isFollower: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(globalLocalizations.common_follow),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              child: TabBar(
                controller: tabController,
                indicator: RectangularIndicator(
                  bottomLeftRadius: 100,
                  bottomRightRadius: 100,
                  topLeftRadius: 100,
                  topRightRadius: 100,
                  color: designColors.feiyu_yellow.auto(ref),
                ),
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: [
                  Tab(
                    text: globalLocalizations.me_follower,
                  ),
                  Tab(
                    text: globalLocalizations.me_following,
                  ),
                ],
              ),
              data: ThemeData(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  tabBarTheme: TabBarTheme(
                    labelStyle: TextStyle(
                      color: designColors.dark_01.auto(ref),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Linotte',
                    ),
                    unselectedLabelStyle: TextStyle(
                      color: designColors.dark_01.auto(ref),
                      fontSize: 16,
                      fontFamily: 'Linotte',
                    ),
                  )),
            ),
          ),
          Expanded(child: TabBarView(controller: tabController, children: pages)),
        ],
      ),
    );
  }
}

class FollowerPage extends ConsumerStatefulWidget {
  late final StateNotifierProvider<FollowerScreenViewModel, FollowerScreenModelState> provider;

  FollowerPage({
    required String userId,
    required bool isFollower,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return FollowerScreenViewModel(FollowerScreenModelState.init(userId, isFollower));
    });
  }

  @override
  ConsumerState createState() => _FollowerPageState();
}

class _FollowerPageState extends ConsumerState<FollowerPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    FollowerScreenModelState modelState = ref.watch(widget.provider);
    FollowerScreenViewModel model = ref.read(widget.provider.notifier);

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: MainStyles.getRefresherHeader(ref),
      onRefresh: () async {
        model.getUsers((state) {
          // debugPrint("refresh state=$state");
          _refreshController.refreshCompleted();
          _refreshController.resetNoData();
        });
      },
      onLoading: () async {
        model.getUsers((state) {
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
      child: ListView.builder(
        itemBuilder: (context, index) {
          return buildUserItem(modelState.users[index]);
        },
        itemCount: modelState.users.length,
      ),
    );
  }

  Widget buildUserItem(User user) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AvatarView.fromUser(user, size: 64),
          SizedBox(
            width: 8,
          ),
          Expanded(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Text(
                    user.name,
                    style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                  )),
                  SizedBox(
                    width: 8,
                  ),
                  TextButton(
                      onPressed: () {
                        FollowerScreenViewModel model = ref.read(widget.provider.notifier);
                        model.setFollowState(user.id, !(user.followed ?? false), callback: (msg) {
                          Toast.showSnackBar(context, msg);
                        });
                      },
                      child: Text(
                        user.followed ?? false ? globalLocalizations.common_unfollow : globalLocalizations.common_follow,
                        style: const TextStyle(fontFamily: 'Linotte'),
                      ),
                      style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          primary: Colors.white,
                          onSurface: Colors.white,
                          minimumSize: const Size(64, 24),
                          backgroundColor: user.followed ?? false ? designColors.dark_03.auto(ref) : designColors.feiyu_blue.auto(ref),
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)))
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Text(
                    user.username == null ? "" : "@${user.username}",
                    style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref), overflow: TextOverflow.ellipsis),
                  )),
                ],
              ),
            ],
          ))
        ],
      ),
    );
  }
}
