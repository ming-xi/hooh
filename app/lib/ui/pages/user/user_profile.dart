import 'package:app/global.dart';
import 'package:app/ui/pages/me/activities.dart';
import 'package:app/ui/pages/me/activities_view_model.dart';
import 'package:app/ui/pages/me/badges.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/pages/user/user_profile_view_model.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  late final StateNotifierProvider<UserProfileScreenViewModel, UserProfileScreenModelState> provider;
  late final StateNotifierProvider<ActivitiesScreenViewModel, ActivitiesScreenModelState> trendsProvider;

  UserProfileScreen({
    required this.userId,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return UserProfileScreenViewModel(UserProfileScreenModelState.init(userId));
    });
    trendsProvider = StateNotifierProvider((ref) {
      return ActivitiesScreenViewModel(ActivitiesScreenModelState.init(userId));
    });
  }

  @override
  ConsumerState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  User? user;
  final List<BoxShadow> cardShadow = [BoxShadow(color: const Color(0x00000000).withAlpha((255 * 0.2).toInt()), blurRadius: 10, spreadRadius: -4)];
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserProfileScreenModelState modelState = ref.watch(widget.provider);
    UserProfileScreenViewModel model = ref.read(widget.provider.notifier);

    ActivitiesScreenModelState trendsModelState = ref.watch(widget.trendsProvider);
    ActivitiesScreenViewModel trendsModel = ref.read(widget.trendsProvider.notifier);

    TextStyle? titleTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref));

    bool loading = modelState.user == null && modelState.isLoading;
    String title = "";
    String subtitle = "";
    if (!loading) {
      User user = modelState.user!;
      title = user.name;
      subtitle = user.username == null ? "" : "@${user.username}";
    }
    AppBar appBar = buildAppBar(title, subtitle);
    if (loading) {
      return Scaffold(
        appBar: appBar,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    double avatarSize = 72;
    double badgeOffset = 22;
    User user = modelState.user!;
    return Scaffold(
      appBar: appBar,
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: MainStyles.getRefresherHeader(ref),
        onRefresh: () async {
          model.getUserInfo(callback: () {
            trendsModel.getActivities((state) {
              // debugPrint("refresh state=$state");
              _refreshController.refreshCompleted();
              _refreshController.resetNoData();
            });
          });
        },
        onLoading: () async {
          trendsModel.getActivities((state) {
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
        child: CustomScrollView(
          slivers: [buildUserInfo(avatarSize, badgeOffset, user, context, titleTextStyle), ...UserActivityPage.buildGridView(context, ref, trendsModelState)],
        ),
      ),
    );
  }

  AppBar buildAppBar(String title, String subtitle) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref)),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: designColors.light_06.auto(ref)),
          ),
        ],
      ),
      actions: [
        IconButton(
            onPressed: () {},
            icon: HoohIcon(
              "assets/images/icon_me_message.svg",
              width: 24,
              height: 24,
              color: designColors.dark_01.auto(ref),
            ))
      ],
      centerTitle: true,
    );
  }

  Widget buildUserInfo(double avatarSize, double badgeOffset, User user, BuildContext context, TextStyle titleTextStyle) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Spacer(),
              Center(
                child: SizedBox(
                  width: avatarSize + badgeOffset * 2,
                  height: avatarSize,
                  child: Stack(
                    children: [
                      Center(
                        child: HoohImage(
                          imageUrl: user.avatarUrl ?? "",
                          cornerRadius: 100,
                          width: avatarSize,
                          height: avatarSize,
                        ),
                      ),
                      Positioned(
                          left: 0,
                          bottom: 0,
                          child: HoohImage(
                            imageUrl: user.badgeImageUrl ?? "",
                            width: 32,
                            height: 36,
                          ))
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Spacer(),
                    buildFollowButton(user),
                  ],
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 80,
              child: Row(
                children: [
                  Expanded(child: buildFollowerCard(AppLocalizations.of(context)!.me_following, user.followingCount)),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(child: buildFollowerCard(AppLocalizations.of(context)!.me_follower, user.followerCount)),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              AppLocalizations.of(context)!.me_personal_social_icon,
              style: titleTextStyle,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          buildBadgeBar(user),
          const SizedBox(
            height: 32,
          ),
          buildProfileCard(user, titleTextStyle),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 80,
              child: Row(
                children: [
                  Expanded(child: buildFollowerCard(globalLocalizations.me_tile_posts, user.publicPostCount)),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(child: buildFollowerCard(globalLocalizations.me_tile_templates, user.templateCount)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Text(
              globalLocalizations.me_tile_trends,
              style: titleTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFollowButton(User user) {
    User? currentUser = ref.read(globalUserInfoProvider);
    if (currentUser != null && currentUser.id == widget.userId) {
      return Container();
    }
    bool followed = user.followed ?? false;
    Color color = followed ? designColors.dark_03.auto(ref) : designColors.feiyu_blue.auto(ref);
    return TextButton(
      onPressed: () {
        UserProfileScreenViewModel model = ref.read(widget.provider.notifier);
        model.setFollowState(!followed, callback: (msg) {
          Toast.showSnackBar(context, msg);
        });
      },
      child: Text(
        followed ? "Unfollow" : "Follow",
        style: TextStyle(fontFamily: 'Linotte', fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14), topRight: Radius.zero, bottomRight: Radius.zero),
        ),
        primary: Colors.white,
        onSurface: Colors.white,
        padding: EdgeInsets.only(top: 4),
        fixedSize: Size(108, 40),
        backgroundColor: color,
      ),
    );
  }

  Container buildFollowerCard(String title, int? amount) {
    return Container(
      decoration: buildCardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Spacer(
            flex: 22,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: designColors.light_06.auto(ref)),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            formatAmount(amount ?? 0),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref)),
          ),
          const Spacer(
            flex: 12,
          ),
        ],
      ),
    );
  }

  BoxDecoration buildCardDecoration() => BoxDecoration(boxShadow: cardShadow, borderRadius: BorderRadius.circular(20), color: designColors.light_01.auto(ref));

  Widget buildMainCard(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 12),
        decoration: buildCardDecoration(),
        child: child,
      ),
    );
  }

  Widget buildProfileCard(User user, TextStyle titleTextStyle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
        ),
        HoohIcon(
          "assets/images/icon_me_calendar.svg",
          width: 24,
          height: 24,
          color: designColors.dark_01.auto(ref),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 24,
                    child: Center(
                      child: Text(
                        "${DateUtil.getZonedDateString(user.createdAt!, format: "d MMMM yyyy")} Joined",
                        style: TextStyle(fontSize: 16, color: designColors.dark_01.auto(ref)),
                      ),
                    ),
                  )
                ],
              ),
              Visibility(
                visible: (user.signature?.trim() ?? "").isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      user.signature ?? "",
                      style: TextStyle(fontSize: 14, color: designColors.light_06.auto(ref)),
                    ),
                  ],
                ),
              ),
              Visibility(
                  visible: (user.website?.trim() ?? "").isNotEmpty,
                  child: GestureDetector(
                    onTap: () {
                      if ((user.website ?? "").isNotEmpty) {
                        openLink(context, user.website ?? "");
                      }
                    },
                    child: Text(
                      user.website ?? "",
                      style: TextStyle(fontSize: 14, color: designColors.feiyu_blue.auto(ref), decoration: TextDecoration.underline),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildBadgeBar(User user) {
    const double height = 64;
    const double middleSpacing = 16;
    const double paddingLeft = 20;
    const double paddingRight = 8;
    const double outerSpacing = 24;
    const double buttonSize = 36;
    const double badgeWidth = 32;
    double screenWidth = MediaQuery.of(context).size.width;
    int maxBadgeCount = (screenWidth - (paddingLeft + outerSpacing * 2 + buttonSize + paddingRight) + middleSpacing) ~/ (badgeWidth + middleSpacing);
    // debugPrint("maxBadgeCount=${maxBadgeCount}");
    // var temp = user.receivedBadges!;
    // user.receivedBadges = [
    //   ...temp,
    //   ...temp,
    //   ...temp,
    // ];
    List<Widget>? badges = user.receivedBadges
        ?.take(maxBadgeCount)
        .map((e) => [
              HoohImage(
                imageUrl: e,
                width: badgeWidth,
                isBadge: true,
              ),
              const SizedBox(
                width: middleSpacing,
              )
            ])
        .expand((element) => element)
        .toList();
    if (badges != null && badges.isNotEmpty) {
      badges.removeLast();
    }
    var list = [
      // buildMyBadge(user, height),
      const SizedBox(
        width: outerSpacing,
      ),
      ...?badges,
      // SizedBox(
      //   width: outerSpacing,
      // ),
      const Spacer(),
      IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BadgesScreen(userId: user.id)));
          },
          icon: Icon(
            Icons.more_horiz_rounded,
            color: designColors.dark_03.auto(ref),
            size: 32,
          )),
      const SizedBox(
        width: paddingRight,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(left: paddingLeft),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: designColors.light_01.auto(ref),
          boxShadow: cardShadow,
          borderRadius: const BorderRadius.only(
            topLeft: const Radius.circular(24),
            bottomLeft: const Radius.circular(24),
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: list,
          ),
        ),
      ),
    );
  }
}
