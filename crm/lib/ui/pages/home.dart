import 'dart:math';

import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:crm/global.dart';
import 'package:crm/ui/pages/home_view_model.dart';
import 'package:crm/ui/pages/template/templates.dart';
import 'package:crm/utils/constants.dart';
import 'package:crm/utils/design_colors.dart';
import 'package:crm/utils/styles.dart';
import 'package:crm/utils/ui_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final StateNotifierProvider<HomeScreenViewModel, HomeScreenModelState> homeScreenProvider = StateNotifierProvider((ref) {
  return HomeScreenViewModel(HomeScreenModelState.init(Constants.PAGE_ID_TEMPLATES));
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late int networkType;

  @override
  void initState() {
    super.initState();
    networkType = preferences.getInt(Preferences.KEY_SERVER) ?? Network.TYPE_PRODUCTION;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        usernameController.text = "app_test1";
        passwordController.text = "123456";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = ref.watch(globalUserInfoProvider);
    HomeScreenViewModel model = ref.read(homeScreenProvider.notifier);
    HomeScreenModelState modelState = ref.watch(homeScreenProvider);
    Orientation? orientation = ref.watch(globalOrientationProvider);

    if (user == null) {
      return Scaffold(
        body: Center(child: buildLoginPage(modelState, model)),
      );
    } else {
      double menuWidth = 200;
      Widget mainPanel = Container(
        child: buildMainPage(),
        color: designColors.light_00.auto(ref),
      );
      List<Widget> appbarActions = [buildLoginUserInfo(modelState, model, orientation)];
      if (kDebugMode) {
        appbarActions.add(SizedBox(
          width: 48,
        ));
      }
      AppBar appBar = AppBar(
        title: Text(
          "HOOH CRM",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: appbarActions,
      );
      switch (orientation) {
        case Orientation.landscape:
          return Scaffold(
            appBar: appBar,
            body: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: menuWidth,
                  child: Container(
                    decoration: BoxDecoration(
                        color: designColors.light_01.auto(ref), border: Border(right: BorderSide(color: designColors.light_02.auto(ref), width: 1))),
                    child: CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: buildDrawerItems(),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(child: mainPanel)
              ],
            ),
          );

        default:
          return Scaffold(
            drawer: Drawer(
                backgroundColor: designColors.light_00.auto(ref),
                width: menuWidth,
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: buildDrawerItems(),
                    )
                  ],
                )),
            appBar: appBar,
            body: mainPanel,
          );
      }

      // return OrientationBuilder(
      //   builder: (context, orientation) {
      //
      //     if (orientation == Orientation.landscape) {
      //       // pc
      //       return Scaffold(
      //         appBar: appBar,
      //         body: Row(
      //           mainAxisSize: MainAxisSize.max,
      //           children: [
      //             SizedBox(
      //               width: menuWidth,
      //               child: Container(
      //                 decoration: BoxDecoration(
      //                     color: designColors.light_01.auto(ref), border: Border(right: BorderSide(color: designColors.light_02.auto(ref), width: 1))),
      //                 child: CustomScrollView(
      //                   slivers: [
      //                     SliverFillRemaining(
      //                       hasScrollBody: false,
      //                       child: buildDrawerItems(),
      //                     )
      //                   ],
      //                 ),
      //               ),
      //             ),
      //             Expanded(child: mainPanel)
      //           ],
      //         ),
      //       );
      //     } else {
      //       // mobile
      //       return Scaffold(
      //         drawer: Drawer(
      //             backgroundColor: designColors.light_00.auto(ref),
      //             width: menuWidth,
      //             child: CustomScrollView(
      //               slivers: [
      //                 SliverFillRemaining(
      //                   hasScrollBody: false,
      //                   child: buildDrawerItems(),
      //                 )
      //               ],
      //             )),
      //         appBar: appBar,
      //         body: mainPanel,
      //       );
      //     }
      //   },
      // );
    }
  }

  Widget buildLoginUserInfo(HomeScreenModelState modelState, HomeScreenViewModel model, Orientation? orientation) {
    User? user = ref.watch(globalUserInfoProvider);
    if (user == null) {
      return Container();
    }
    PopupMenuButton button = PopupMenuButton(
      color: designColors.light_00.auto(ref),
      iconSize: 32,
      icon: HoohImage(
        imageUrl: user.avatarUrl!,
        cornerRadius: 100,
      ),
      onSelected: (value) {},
      // offset: Offset(0.0, appBarHeight),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(const Radius.circular(8)),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
            onTap: () {
              Future.delayed(const Duration(milliseconds: 250), () {
                handleUserLogout(ref);
              });
            },
            child: Text(
              "退出登录",
              style: TextStyle(color: designColors.dark_01.auto(ref)),
            ))
      ],
    );
    if (orientation == Orientation.landscape) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          button,
          SizedBox(
            width: 8,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: TextStyle(fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref)),
              ),
              Text(user.username != null ? "@${user.username!}" : "", style: TextStyle(fontSize: 12, color: designColors.dark_03.auto(ref))),
            ],
          )
        ],
      );
    } else {
      return button;
    }
  }

  Widget buildLoginPage(HomeScreenModelState modelState, HomeScreenViewModel model) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = min(constraints.maxWidth, 300);
        return SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "登录",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 28, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "欢迎，管理员",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 16, color: designColors.dark_03.auto(ref)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 36,
                ),
                TextField(
                  controller: usernameController,
                  style: TextStyle(color: designColors.dark_01.auto(ref)),
                  decoration: RegisterStyles.commonInputDecoration("用户名", ref),
                ),
                SizedBox(
                  height: 16,
                ),
                TextField(
                  obscureText: true,
                  controller: passwordController,
                  style: TextStyle(color: designColors.dark_01.auto(ref)),
                  decoration: RegisterStyles.commonInputDecoration("密码", ref),
                ),
                SizedBox(
                  height: 36,
                ),
                MainStyles.blueButton(ref, "登录", () {
                  model.login(
                    context,
                    usernameController.text,
                    passwordController.text,
                    onSuccess: (data) {
                      handleUserLogin(ref, data.user, data.jwtResponse.accessToken);
                    },
                  );
                }),
                SizedBox(
                  height: 36,
                ),
                Visibility(
                  visible: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "选择服务器：",
                          style: TextStyle(color: designColors.dark_01.auto(ref)),
                        ),
                      ),
                      DropdownButton<int>(
                        value: networkType,
                        dropdownColor: designColors.light_00.auto(ref),
                        style: TextStyle(color: designColors.dark_01.auto(ref)),
                        items: [Network.TYPE_LOCAL, Network.TYPE_STAGING, Network.TYPE_PRODUCTION]
                            .map((e) => DropdownMenuItem<int>(
                                  child: Text(Network.SERVER_HOST_NAMES[e]!),
                                  value: e,
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          preferences.putInt(Preferences.KEY_SERVER, value);
                          network.reloadServerType();
                          handleUserLogout(ref);
                          setState(() {
                            networkType = value;
                          });
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildDrawerItems() {
    TextStyle titleStyle = TextStyle(
      fontSize: 16,
      color: designColors.dark_01.auto(ref),
    );
    TextStyle titleDisabledStyle = TextStyle(
      fontSize: 16,
      color: designColors.dark_01.auto(ref).withOpacity(0.25),
    );
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MenuTabItem(
            pageId: Constants.PAGE_ID_USERS,
            title: Constants.PAGE_NAME_USERS,
          ),
          MenuTabItem(
            pageId: Constants.PAGE_ID_POSTS,
            title: Constants.PAGE_NAME_POSTS,
          ),
          MenuTabItem(pageId: Constants.PAGE_ID_TEMPLATES, title: Constants.PAGE_NAME_TEMPLATES, onClick: changePage),
          MenuTabItem(
            pageId: Constants.PAGE_ID_CONFIGS,
            title: Constants.PAGE_NAME_CONFIGS,
          ),
        ],
      ),
    );
  }

  void changePage(int pageId) {
    HomeScreenViewModel model = ref.read(homeScreenProvider.notifier);
    model.changePage(pageId);
  }

  Widget buildMainPage() {
    HomeScreenModelState modelState = ref.watch(homeScreenProvider);
    switch (modelState.selectedPageId) {
      case Constants.PAGE_ID_TEMPLATES:
        return TemplateReviewPage();
      default:
        return Container();
    }
  }
}

class MenuTabItem extends ConsumerWidget {
  final int pageId;
  final String title;
  final Function(int pageId)? onClick;

  const MenuTabItem({
    required this.pageId,
    required this.title,
    this.onClick,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextStyle titleStyle = TextStyle(
      fontSize: 16,
      color: designColors.dark_01.auto(ref),
    );
    TextStyle titleDisabledStyle = TextStyle(
      fontSize: 16,
      color: designColors.dark_01.auto(ref).withOpacity(0.25),
    );
    int? selectedPageId = ref.watch(homeScreenProvider).selectedPageId;
    bool selected = selectedPageId == pageId;
    return ListTile(
      selectedTileColor: designColors.feiyu_blue.auto(ref),
      selected: selected,
      onTap: onClick == null
          ? null
          : () {
              if (selected) {
                return;
              }
              if (onClick != null) {
                onClick!(pageId);
              }
            },
      title: Text(
        title,
        style: (onClick == null ? titleDisabledStyle : titleStyle).copyWith(color: selected ? designColors.light_01.light : null),
      ),
    );
  }
}
