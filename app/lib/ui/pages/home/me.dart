import 'package:app/global.dart';
import 'package:app/ui/pages/me/badges.dart';
import 'package:app/ui/pages/me/settings/setting.dart';
import 'package:app/ui/pages/user/register/login.dart';
import 'package:app/ui/pages/user/register/register.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 1), () {
        User? user = ref.read(globalUserInfoProvider);
        if (user != null) {
          network.requestAsync<User>(network.getUserInfo(user.id), (data) {
            if (mounted) {
              ref.read(globalUserInfoProvider.state).state = data;
            }
          }, (error) {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(globalUserInfoProvider.state).state == null ? GuestPage() : UserCenterPage();
  }
}

class GuestPage extends ConsumerWidget {
  const GuestPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.yellow.withAlpha(100),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("not login"),
              SizedBox(
                height: 24,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                  },
                  style: RegisterStyles.blackButtonStyle(ref),
                  child: const Text('Sign Up')),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: const Text('Or Login'),
                style: RegisterStyles.blackOutlineButtonStyle(ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserCenterPage extends ConsumerStatefulWidget {
  const UserCenterPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _UserCenterPageState();
}

class _UserCenterPageState extends ConsumerState<UserCenterPage> {
  final List<BoxShadow> cardShadow = [BoxShadow(color: Color(0x00000000).withAlpha((255 * 0.2).toInt()), blurRadius: 10, spreadRadius: -4)];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle? titleTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref));
    User user = ref.watch(globalUserInfoProvider)!;
    bool loading = user.username == null || user.badgeImageUrl == null;
    if (loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              user.name,
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
              onPressed: () {},
              icon: HoohIcon(
                "assets/images/icon_me_message.svg",
                width: 24,
                height: 24,
                color: designColors.dark_01.auto(ref),
              ))
        ],
        leading: IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
            icon: HoohIcon(
              "assets/images/icon_me_setting.svg",
              width: 24,
              height: 24,
              color: designColors.dark_01.auto(ref),
            )),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 16,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        HoohImage(
                          imageUrl: user.avatarUrl ?? "",
                          cornerRadius: 100,
                          width: 72,
                          height: 72,
                        ),
                        const Spacer(),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.me_following,
                              style: TextStyle(fontSize: 12, color: designColors.light_06.auto(ref)),
                            ),
                            Text(
                              formatAmount(user.followingCount ?? 0),
                              style: titleTextStyle,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.me_follower,
                              style: TextStyle(fontSize: 12, color: designColors.light_06.auto(ref)),
                            ),
                            Text(
                              formatAmount(user.followerCount ?? 0),
                              style: titleTextStyle,
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(
                          width: 17,
                        ),
                      ],
                    )),
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
                SizedBox(
                  height: 8,
                ),
                buildBadgeBar(user),
                SizedBox(
                  height: 32,
                ),
                buildProfileCard(user, titleTextStyle),
                SizedBox(
                  height: 32,
                ),
                buildWalletCard(user, titleTextStyle),
                SizedBox(
                  height: 32,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Title?",
                    style: titleTextStyle,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                buildTileButtons(user),
                SizedBox(
                  height: 96,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildTileButtons(User user) {
    List<Tuple4<String, String, bool, void Function()?>> configs = [
      Tuple4("Post", "assets/images/icon_user_center_post.svg", true, () {}),
      Tuple4("Contents", "assets/images/icon_user_center_contents.svg", true, () {}),
      Tuple4("NFTs", "assets/images/icon_user_center_nft.svg", false, null),
      Tuple4("Collection", "assets/images/icon_user_center_fav.svg", true, () {}),
      Tuple4("Liked", "assets/images/icon_user_center_liked.svg", true, () {}),
      Tuple4("Trends", "assets/images/icon_user_center_trends.svg", true, () {}),
    ];
    LinearGradient gradient = const LinearGradient(colors: [
      Color(0xFF0167F9),
      Color(0xFF20E0C2),
    ], begin: Alignment.topLeft, end: Alignment.bottomRight);
    Color disabledColor = designColors.dark_03.auto(ref);
    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 20),
    //   child: Wrap(children:
    //       configs.map((config) =>  AspectRatio(
    //         aspectRatio: 1,
    //         child: Material(
    //           type: MaterialType.transparency,
    //           child: Ink(
    //             decoration:
    //             BoxDecoration(gradient: config.item3 ? gradient : null, color: config.item3 ? disabledColor : null, borderRadius: BorderRadius.circular(20)),
    //             child: InkWell(
    //               onTap: config.item4,
    //               child: Column(
    //                 mainAxisSize: MainAxisSize.max,
    //                 crossAxisAlignment: CrossAxisAlignment.stretch,
    //                 children: [
    //                   Expanded(
    //                     child: Row(
    //                       mainAxisSize: MainAxisSize.min,
    //                       children: [
    //                         HoohIcon(
    //                           config.item2,
    //                           width: 48,
    //                           height: 48,
    //                         ),
    //                         Spacer()
    //                       ],
    //                     ),
    //                   ),
    //                   Expanded(
    //                     child: Center(
    //                       child: Text(
    //                         config.item1,
    //                         style: TextStyle(fontSize: 16, color: Colors.white),
    //                       ),
    //                     ),
    //                   )
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       )).toList(),runSpacing: 4,spacing: 4,),
    // );
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
          physics: NeverScrollableScrollPhysics(),
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columnCount, mainAxisSpacing: spacing, crossAxisSpacing: spacing, childAspectRatio: 1),
          itemBuilder: (context, index) {
            Tuple4<String, String, bool, void Function()?> config = configs[index];
            return Material(
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
                              padding: EdgeInsets.only(top: 12, left: 12),
                              child: HoohIcon(
                                config.item2,
                                width: 48,
                                height: 48,
                              ),
                            ),
                            Spacer()
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            config.item1,
                            style: TextStyle(fontSize: 16, color: Colors.white),
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

  Widget buildCard(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 12),
        decoration: BoxDecoration(boxShadow: cardShadow, borderRadius: BorderRadius.circular(20), color: designColors.light_01.auto(ref)),
        child: child,
      ),
    );
  }

  Widget buildWalletCard(User user, TextStyle titleTextStyle) {
    return buildCard(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(
        height: 16,
      ),
      Text(
        "Wallet",
        style: titleTextStyle,
      ),
      SizedBox(
        height: 24,
      ),
      Center(
        child: Text(
          "Empty...",
          style: titleTextStyle,
        ),
      ),
    ]));
  }

  Widget buildProfileCard(User user, TextStyle titleTextStyle) {
    return buildCard(Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Profile",
              style: titleTextStyle,
            ),
            Spacer(),
            TextButton(
              onPressed: () {},
              child: Text(
                "Edit Profile",
                style: TextStyle(fontSize: 14, color: designColors.blue_dark.auto(ref), fontWeight: FontWeight.normal, decoration: TextDecoration.underline),
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
            SizedBox(
              width: 8,
            ),
            Text(
              "${DateUtil.getZonedDateString(user.createdAt!, format: "d MMMM yyyy")} Joined",
              style: TextStyle(fontSize: 16, color: designColors.dark_01.auto(ref)),
            )
          ],
        ),
        Visibility(
          visible: (user.signature?.trim() ?? "").isNotEmpty,
          child: Column(
            children: [
              SizedBox(
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
    ));
  }

  Widget buildBadgeBar(User user) {
    const double height = 64;
    const double middleSpacing = 12;
    const double paddingLeft = 20;
    const double outerSpacing = 16;
    const double buttonSize = 36;
    const double badgeWidth = 32;
    double screenWidth = MediaQuery.of(context).size.width;
    int maxBadgeCount = (screenWidth - (paddingLeft * 2 + height + outerSpacing * 2 + buttonSize) + middleSpacing) ~/ (badgeWidth + middleSpacing);

    List<Widget>? badges = user.receivedBadges
        ?.take(maxBadgeCount)
        .map((e) => [
              HoohImage(
                imageUrl: e,
                width: badgeWidth,
                isBadge: true,
              ),
              SizedBox(
                width: middleSpacing,
              )
            ])
        .expand((element) => element)
        .toList();
    if (badges != null && badges.isNotEmpty) {
      badges.removeLast();
    }
    var list = [
      buildMyBadge(user, height),
      SizedBox(
        width: outerSpacing,
      ),
      ...?badges,
      SizedBox(
        width: outerSpacing,
      ),
      Spacer(),
      IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BadgesScreen(userId: user.id)));
          },
          icon: Icon(
            Icons.more_horiz_rounded,
            color: designColors.dark_03.auto(ref),
            size: 26,
          ))
    ];

    return Padding(
      padding: const EdgeInsets.only(left: paddingLeft),
      child: Container(
        decoration: BoxDecoration(
          color: designColors.light_01.auto(ref),
          boxShadow: cardShadow,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
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

  Widget buildMyBadge(User user, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: MainStyles.badgeGradient(),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 6,
            ),
            HoohImage(
              imageUrl: user.badgeImageUrl!,
              isBadge: true,
              height: 36,
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              "mine",
              style: TextStyle(color: Colors.white, fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}
