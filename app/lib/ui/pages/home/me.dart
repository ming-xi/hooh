import 'package:app/global.dart';
import 'package:app/ui/pages/home/me_model.dart';
import 'package:app/ui/pages/me/activities.dart';
import 'package:app/ui/pages/me/badges.dart';
import 'package:app/ui/pages/me/followers.dart';
import 'package:app/ui/pages/me/notifications.dart';
import 'package:app/ui/pages/me/settings/edit_profile.dart';
import 'package:app/ui/pages/me/settings/setting.dart';
import 'package:app/ui/pages/me/wallet.dart';
import 'package:app/ui/pages/misc/share.dart';
import 'package:app/ui/pages/user/posts.dart';
import 'package:app/ui/pages/user/posts_view_model.dart';
import 'package:app/ui/pages/user/register/start.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/pages/user/templates.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:badges/badges.dart' as badge;
import 'package:common/models/network/responses.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tuple/tuple.dart';

class MePage extends ConsumerStatefulWidget {
  const MePage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _MePageState();
}

class _MePageState extends ConsumerState<MePage> {
  @override
  Widget build(BuildContext context) {
    // important! make it change text when locale changes
    ref.watch(globalLocaleProvider);
    debugPrint("me build");
    return ref.watch(globalUserInfoProvider) == null
        ? StartScreen(
            scene: StartScreen.SCENE_ME,
          )
        : MyProfilePage();
  }
}

class MyProfilePage extends ConsumerStatefulWidget {
  late final StateNotifierProvider<MePageViewModel, MePageModelState> provider;

  MyProfilePage({
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      User? user = ref.read(globalUserInfoProvider);
      return MePageViewModel(MePageModelState.init(user!.id, user: user));
    });
  }

  @override
  ConsumerState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends ConsumerState<MyProfilePage> {
  late final Color cardShadowColor;
  late List<BoxShadow> cardShadow;

  _MyProfilePageState() {
    cardShadowColor = Colors.black.withAlpha((255 * 0.2).toInt());
  }

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    cardShadow = [BoxShadow(color: cardShadowColor, blurRadius: 10, spreadRadius: -4)];
    MePageModelState modelState = ref.watch(widget.provider);
    MePageViewModel model = ref.read(widget.provider.notifier);
    TextStyle? titleTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref));
    bool loading = modelState.user == null;
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    User user = modelState.user!;
    String? title = user.name;
    double avatarSize = 72;
    double badgeOffset = 22;
    return Scaffold(
      appBar: HoohAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref)),
            ),
            Text(
              user.username == null ? "" : "@${user.username}",
              style: TextStyle(fontSize: 12, color: designColors.light_06.auto(ref)),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SystemNotificationScreen())).then((value) {
                  refreshPage(ref.read(widget.provider.notifier));
                });
              },
              icon: badge.Badge(
                badgeColor: designColors.orange.auto(ref),
                padding: EdgeInsets.all(4),
                elevation: 0,
                position: badge.BadgePosition.topEnd(end: -4, top: -6),
                showBadge: (modelState.unread?.unreadCount ?? 0) != 0,
                badgeContent: Text(
                  "${modelState.unread?.unreadCount ?? 0}",
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
                child: HoohIcon(
                  "assets/images/icon_me_message.svg",
                  width: 24,
                  height: 24,
                  color: designColors.dark_01.auto(ref),
                ),
              ))
        ],
        hoohLeading: IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())).then((value) {
                refreshPage(ref.read(widget.provider.notifier));
              });
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
            icon: badge.Badge(
              badgeColor: designColors.orange.auto(ref),
              padding: EdgeInsets.all(4),
              elevation: 0,
              position: badge.BadgePosition.topEnd(end: -2, top: -2),
              showBadge: !(user.emailValidated ?? false),
              child: HoohIcon(
                "assets/images/icon_me_setting.svg",
                width: 24,
                height: 24,
                color: designColors.dark_01.auto(ref),
              ),
            )),
        centerTitle: true,
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: MainStyles.getRefresherHeader(ref),
        onRefresh: () async {
          refreshPage(model);
        },
        controller: _refreshController,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: SafeArea(
                child: Column(
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
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
                                    },
                                    child: HoohImage(
                                      imageUrl: user.avatarUrl ?? "",
                                      cornerRadius: 100,
                                      width: avatarSize,
                                      height: avatarSize,
                                    ),
                                  ),
                                ),
                                Positioned(
                                    left: 0,
                                    bottom: 0,
                                    child: HoohImage(
                                      isBadge: true,
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
                              buildShareCardButton(),
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
                            Expanded(child: buildFollowerCard(AppLocalizations.of(context)!.me_following, user.followingCount, false)),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(child: buildFollowerCard(AppLocalizations.of(context)!.me_follower, user.followerCount, true)),
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
                    buildTileButtons(user),
                    const SizedBox(
                      height: 32,
                    ),
                    buildProfileCard(user, titleTextStyle),
                    const SizedBox(
                      height: 32,
                    ),
                    buildWalletCard(user, modelState.wallet, titleTextStyle),
                    const SizedBox(
                      height: 24,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void refreshPage(MePageViewModel model) {
    model.refresh(callback: () {
      _refreshController.refreshCompleted();
      _refreshController.resetNoData();
    });
  }

  Widget buildFollowerCard(String title, int? amount, bool isFollower) {
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
        String userId = ref.read(globalUserInfoProvider)!.id;
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return FollowerScreen(userId: userId, isFollower: isFollower);
        }));
      },
      child: column,
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(10),
          primary: designColors.light_01.auto(ref),
          onPrimary: designColors.light_02.auto(ref),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          shadowColor: cardShadowColor,
          elevation: 8),
    );
    return card;
    // return Container(
    //   decoration: buildCardDecoration(),
    //   child: column,
    // );
  }

  Widget buildShareCardButton() {
    User user = ref.read(globalUserInfoProvider)!;
    var borderRadius = BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14), topRight: Radius.zero, bottomRight: Radius.zero);
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(gradient: MainStyles.badgeGradient(ref), borderRadius: borderRadius),
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () {
            Navigator.push(
                context,
                PageRouteBuilder(
                    pageBuilder: (context, anim1, anim2) => ShareScreen(
                          scene: ShareScreen.SCENE_USER_CARD,
                        ),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return child;
                    },
                    opaque: false));
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Center(
                child: Text(
              globalLocalizations.me_share_card,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
            )),
          ),
        ),
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
      Tuple4(globalLocalizations.me_tile_bookmarks, "assets/images/icon_user_center_fav.svg", true, () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    UserPostsScreen(title: globalLocalizations.me_tile_bookmarks, userId: user.id, type: UserPostsScreenModelState.TYPE_FAVORITED)));
      }),
      Tuple4(globalLocalizations.me_tile_liked, "assets/images/icon_user_center_liked.svg", true, () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserPostsScreen(title: globalLocalizations.me_tile_liked, userId: user.id, type: UserPostsScreenModelState.TYPE_LIKED)));
      }),
      Tuple4(globalLocalizations.me_tile_trends, "assets/images/icon_user_center_trends.svg", true, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserActivityScreen(userId: user.id))).then((value) {
          refreshPage(ref.read(widget.provider.notifier));
        });
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

  BoxDecoration buildCardDecoration() => BoxDecoration(boxShadow: cardShadow, borderRadius: BorderRadius.circular(20), color: designColors.light_01.auto(ref));

  Widget buildWalletCard(User user, UserWalletResponse? wallet, TextStyle titleTextStyle) {
    if (wallet == null) {
      return Container();
    }
    int total = wallet.totalEarnedPowInt + wallet.totalEarnedReputationInt;
    int yesterday = wallet.yesterdayEarnedPowInt + wallet.yesterdayEarnedReputationInt;
    double totalPowPercentage = total == 0 ? 0 : (wallet.totalEarnedPowInt / total);
    double totalReputationPercentage = total == 0 ? 0 : (wallet.totalEarnedReputationInt / total);
    double yesterdayPowPercentage = yesterday == 0 ? 0 : (wallet.yesterdayEarnedPowInt / yesterday);
    double yesterdayReputationPercentage = yesterday == 0 ? 0 : (wallet.yesterdayEarnedReputationInt / yesterday);
    debugPrint("total=$total,"
        "yesterday=$yesterday,"
        "totalPowPercentage=$totalPowPercentage,"
        "totalReputationPercentage=$totalReputationPercentage,"
        "yesterdayPowPercentage=$yesterdayPowPercentage,"
        "yesterdayReputationPercentage=$yesterdayReputationPercentage,");
    var column = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // const SizedBox(
      //   height: 16,
      // ),
      Text(
        globalLocalizations.me_wallet,
        style: titleTextStyle,
      ),
      const SizedBox(
        height: 8,
      ),
      Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(globalLocalizations.me_wallet_balance, style: TextStyle(color: designColors.dark_01.auto(ref), fontSize: 16)),
          SizedBox(
            width: 16,
          ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HoohIcon(
                  "assets/images/common_ore.svg",
                  width: 24,
                  height: 24,
                ),
                SizedBox(
                  width: 4,
                ),
                Expanded(
                  child: Text(sprintf(globalLocalizations.me_wallet_ore_amount, [formatCurrency(wallet.balanceInt, precise: true)]),
                      style: TextStyle(color: designColors.feiyu_blue.auto(ref), fontSize: 16, fontWeight: FontWeight.bold, overflow: TextOverflow.fade)),
                ),
              ],
            ),
          ),
        ],
      ),
      SizedBox(
        height: 8,
      ),
      Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildEarnDetail(globalLocalizations.me_wallet_total_earn, total, totalPowPercentage, totalReputationPercentage),
          buildEarnDetail(globalLocalizations.me_wallet_yesterday_earn, yesterday, yesterdayPowPercentage, yesterdayReputationPercentage),
        ],
      )
    ]);
    // return buildMainCard(column);
    ElevatedButton card = ElevatedButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WalletScreen(
                      userId: ref.read(globalUserInfoProvider)!.id,
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: column,
      ),
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(10),
          primary: designColors.light_01.auto(ref),
          onPrimary: designColors.light_02.auto(ref),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          shadowColor: cardShadowColor,
          elevation: 8),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: card,
    );
  }

  Widget buildEarnDetail(String title, int amount, double powPercentage, double reputationPercentage) {
    String pow = sprintf("%.0f%%", [powPercentage * 100]);
    String reputation = sprintf("%.0f%%", [reputationPercentage * 100]);
    return Expanded(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: designColors.dark_01.auto(ref), fontSize: 16),
        ),
        SizedBox(
          height: 4,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HoohIcon(
              "assets/images/common_ore.svg",
              width: 24,
              height: 24,
            ),
            SizedBox(
              width: 4,
            ),
            Text(sprintf(globalLocalizations.me_wallet_ore_amount, [formatCurrency(amount, precise: true)]),
                style: TextStyle(color: designColors.feiyu_blue.auto(ref), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          sprintf(globalLocalizations.me_wallet_pow_percentage, [pow]),
          style: TextStyle(color: designColors.light_06.auto(ref), fontSize: 14),
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          sprintf(globalLocalizations.me_wallet_reputation_percentage, [reputation]),
          style: TextStyle(color: designColors.light_06.auto(ref), fontSize: 14),
        ),
      ],
    ));
  }

  Widget buildProfileCard(User user, TextStyle titleTextStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 4),
        decoration: buildCardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  globalLocalizations.me_profile,
                  style: titleTextStyle,
                ),
                const Spacer(),
                TextButton(
                  style: MainStyles.textButtonStyle(ref),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
                  },
                  child: Text(
                    globalLocalizations.me_profile_edit,
                    style:
                        TextStyle(fontSize: 14, color: designColors.blue_dark.auto(ref), fontWeight: FontWeight.normal, decoration: TextDecoration.underline),
                  ),
                )
              ],
            ),
            // SizedBox(
            //   height: 8,
            // ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HoohIcon(
                  "assets/images/icon_me_calendar.svg",
                  width: 24,
                  height: 24,
                  color: designColors.dark_01.auto(ref),
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  sprintf(globalLocalizations.me_profile_joined,
                      [DateUtil.getZonedDateString(user.createdAt!, format: globalLocalizations.me_profile_joined_date_format)]),
                  style: TextStyle(fontSize: 16, color: designColors.dark_01.auto(ref)),
                )
              ],
            ),
            Visibility(
              visible: (user.signature?.trim() ?? "").isNotEmpty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 8,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 2,
                    ),
                    GestureDetector(
                      onTap: () {
                        if ((user.website ?? "").isNotEmpty) {
                          openLink(context, user.website ?? "");
                        }
                      },
                      child: Text(
                        user.website ?? "",
                        style: TextStyle(fontSize: 14, color: designColors.feiyu_blue.auto(ref), decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
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
      var badges = user.receivedBadges
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
        const SizedBox(
          width: outerSpacing,
        ),
        ...?badges,
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => BadgesScreen(userId: user.id))).then((value) {
      refreshPage(ref.read(widget.provider.notifier));
    });
  }
}
