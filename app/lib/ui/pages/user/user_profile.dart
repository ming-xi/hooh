import 'package:app/global.dart';
import 'package:app/ui/pages/me/activities.dart';
import 'package:app/ui/pages/me/activities_view_model.dart';
import 'package:app/ui/pages/me/badges.dart';
import 'package:app/ui/pages/me/followers.dart';
import 'package:app/ui/pages/user/posts.dart';
import 'package:app/ui/pages/user/posts_view_model.dart';
import 'package:app/ui/pages/user/register/start.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/pages/user/templates.dart';
import 'package:app/ui/pages/user/user_profile_view_model.dart';
import 'package:app/ui/widgets/appbar.dart';
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
import 'package:common/utils/ui_utils.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tuple/tuple.dart';

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
  ScrollController scrollController = ScrollController();

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

    // bool loading = modelState.user == null && modelState.isLoading;
    bool loading = modelState.user == null;
    debugPrint("loading=$loading modelState.user=${modelState.user} modelState.isLoading=${modelState.isLoading}");
    String title = "";
    String subtitle = "";
    if (!loading) {
      User user = modelState.user!;
      title = user.name;
      subtitle = user.username == null ? "" : "@${user.username}";
    }
    HoohAppBar appBar = buildAppBar(title, subtitle);
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
          controller: scrollController,
          slivers: [
            buildUserInfo(avatarSize, badgeOffset, user, context, titleTextStyle),
            ...UserActivityPage.buildGridView(context, ref, trendsModelState, trendsModel, 12)
          ],
        ),
      ),
    );
  }

  HoohAppBar buildAppBar(String title, String subtitle) {
    return HoohAppBar(
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
      // actions: [
      //   IconButton(
      //       onPressed: () {},
      //       icon: HoohIcon(
      //         "assets/images/icon_me_message.svg",
      //         width: 24,
      //         height: 24,
      //         color: designColors.dark_01.auto(ref),
      //       ))
      // ],
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
                            isBadge: true,
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
                  Expanded(
                      child: buildFollowerCard(
                          title: AppLocalizations.of(context)!.me_following,
                          amount: user.followingCount,
                          onClick: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FollowerScreen(
                                          userId: widget.userId,
                                          isFollower: false,
                                        )));
                          })),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                      child: buildFollowerCard(
                          title: AppLocalizations.of(context)!.me_follower,
                          amount: user.followerCount,
                          onClick: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FollowerScreen(
                                          userId: widget.userId,
                                          isFollower: true,
                                        )));
                          })),
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
          const SizedBox(
            height: 36,
          ),
          buildTileButtons(user),
          // buildPostAndTemplateCards(user, context),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 32),
            child: Text(
              globalLocalizations.me_tile_trends,
              style: titleTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTileButtons(User user) {
    List<Tuple4<String, String, bool, void Function()?>> configs = [
      Tuple4(globalLocalizations.me_tile_posts, "assets/images/icon_user_center_post.svg", true, () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    UserPostsScreen(title: globalLocalizations.me_tile_posts, userId: user.id, type: UserPostsScreenModelState.TYPE_CREATED)));
      }),
      Tuple4(globalLocalizations.me_tile_templates, "assets/images/icon_user_center_contents.svg", true, () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserTemplateScreen(
                      userId: user.id,
                    )));
      }),
      Tuple4(globalLocalizations.me_tile_nfts, "assets/images/icon_user_center_nft.svg", false, () {
        showSnackBar(context, globalLocalizations.me_tile_nfts_coming_soon);
      }),
    ];
    List<Color> colors = [
      const Color(0xFF0167F9),
      const Color(0xFF20E0C2),
    ];
    if (MainStyles.isDarkMode(ref)) {
      colors = colors.map((e) => e.withAlpha(globalDarkModeImageAlpha)).toList();
    }
    LinearGradient gradient = LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight);
    Color disabledColor = designColors.dark_03.auto(ref);
    const int columnCount = 3;
    const double spacing = 4;
    const double padding = 20;
    double screenWidth = MediaQuery.of(context).size.width;
    double itemSize = (screenWidth - padding * 2 - (columnCount - 1) * spacing) / columnCount;
    var rowCount = (configs.length / columnCount).ceil();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: padding),
      child: SizedBox(
        height: itemSize * rowCount + spacing * (rowCount - 1),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnCount, mainAxisSpacing: spacing, crossAxisSpacing: spacing, childAspectRatio: 1),
          itemBuilder: (context, index) {
            Tuple4<String, String, bool, void Function()?> config = configs[index];
            return Material(
              color: designColors.light_00.auto(ref),
              type: MaterialType.transparency,
              child: Ink(
                decoration: BoxDecoration(
                    gradient: config.item3 ? gradient : null, color: !config.item3 ? disabledColor : null, borderRadius: BorderRadius.circular(20)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: config.item4,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 12, left: 12),
                              child: HoohIcon(
                                config.item2,
                                width: 48,
                                height: 48,
                              ),
                            ),
                            const Spacer()
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            config.item1,
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: configs.length,
        ),
      ),
    );
  }

  Padding buildPostAndTemplateCards(User user, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 80,
        child: Row(
          children: [
            Expanded(
                child: buildFollowerCard(
                    title: globalLocalizations.user_profile_posts,
                    amount: user.publicPostCount,
                    onClick: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserPostsScreen(
                                  title: globalLocalizations.user_profile_posts, userId: user.id, type: UserPostsScreenModelState.TYPE_CREATED)));
                    })),
            const SizedBox(
              width: 8,
            ),
            Expanded(
                child: buildFollowerCard(
                    title: globalLocalizations.user_profile_templates,
                    amount: user.templateCount,
                    onClick: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserTemplateScreen(
                                    userId: user.id,
                                  )));
                    })),
          ],
        ),
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
        User? user = ref.read(globalUserInfoProvider);
        if (user == null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
          return;
        }
        UserProfileScreenViewModel model = ref.read(widget.provider.notifier);
        showHoohDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return LoadingDialog(LoadingDialogController());
            });
        model.setFollowState(context, !followed, onSuccess: () {
          Navigator.of(
            context,
          ).pop();
        }, onFailure: (error) {
          Navigator.of(
            context,
          ).pop();
          // showSnackBar(context, msg);
          showCommonRequestErrorDialog(ref, context, error);
        });
      },
      child: Text(
        followed ? globalLocalizations.common_unfollow : globalLocalizations.common_follow,
        style: TextStyle(fontFamily: 'Baloo', fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14), topRight: Radius.zero, bottomRight: Radius.zero),
        ),
        primary: Colors.white,
        onSurface: Colors.white,
        padding: EdgeInsets.zero,
        minimumSize: Size(108, 40),
        backgroundColor: color,
      ),
    );
  }

  Widget buildFollowerCard({required String title, int? amount, Function()? onClick}) {
    var column = Column(
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
    );
    ElevatedButton card = ElevatedButton(
      onPressed: () {
        if (onClick != null) {
          onClick();
        }
      },
      child: column,
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(10),
          primary: designColors.light_01.auto(ref),
          onPrimary: designColors.light_02.auto(ref),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          shadowColor: Colors.black.withAlpha((255 * 0.2).toInt()),
          elevation: 4),
    );
    return card;
    // return Container(
    //   decoration: buildCardDecoration(),
    //   child: column,
    // );
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
                        sprintf(globalLocalizations.me_profile_joined,
                            [DateUtil.getZonedDateString(user.createdAt!, format: globalLocalizations.me_profile_joined_date_format)]),
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

    List<Widget> list;
    if (user.receivedBadges == null || user.receivedBadges!.isEmpty) {
      list = [
        // buildMyBadge(user, height),
        const SizedBox(
          width: outerSpacing,
        ),
        Expanded(
          child: Text(
            globalLocalizations.me_no_badges,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: designColors.dark_03.auto(ref)),
          ),
        ),
        IconButton(
            onPressed: () {
              goToBadgeScreen(user);
            },
            icon: HoohIcon(
              "assets/images/icon_more.svg",
              width: 32,
              height: 32,
              color: designColors.dark_03.auto(ref),
            )),
        const SizedBox(
          width: paddingRight,
        ),
      ];
    } else {
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
      list = [
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
              goToBadgeScreen(user);
            },
            icon: HoohIcon(
              "assets/images/icon_more.svg",
              width: 32,
              height: 32,
              color: designColors.dark_03.auto(ref),
            )),
        const SizedBox(
          width: paddingRight,
        ),
      ];
    }

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
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            goToBadgeScreen(user);
          },
          child: Material(
            type: MaterialType.transparency,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: list,
            ),
          ),
        ),
      ),
    );
  }

  void goToBadgeScreen(User user) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BadgesScreen(userId: user.id)));
  }
}
