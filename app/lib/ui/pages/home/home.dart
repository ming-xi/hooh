import 'dart:convert';

import 'package:app/global.dart';
import 'package:app/ui/pages/home/feeds.dart';
import 'package:app/ui/pages/home/home_view_model.dart';
import 'package:app/ui/pages/home/input.dart';
import 'package:app/ui/pages/home/me.dart';
import 'package:app/ui/pages/home/templates.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:blur/blur.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final StateProvider<bool> bottomBarVisibilityProvider = StateProvider((ref) => true);
final StateNotifierProvider<HomePageViewModel, HomePageModelState> homePageProvider = StateNotifierProvider((ref) {
  return HomePageViewModel(HomePageModelState.init());
});

class HomeScreen extends ConsumerStatefulWidget {
  static const PAGE_INDEX_INPUT = 0;
  static const PAGE_INDEX_TEMPLATES = 1;
  static const PAGE_INDEX_FEEDS = 2;
  static const PAGE_INDEX_ME = 3;

  HomeScreen({
    Key? key,
  }) : super(key: key) {}

  @override
  ConsumerState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final List<Widget> pageContents;
  late final List<Widget?> floatingButtons;
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    globalHomeScreenIsInStack = true;
    pageContents = [
      InputPage(),
      GalleryPage(),
      FeedsPage(),
      MePage(),
    ];
    floatingButtons = [
      null,
      null,
      null,
      null,
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(const Duration(seconds: 1), () {
        User? user = ref.read(globalUserInfoProvider);
        if (user != null) {
          network.requestAsync<User>(network.getUserInfo(user.id), (data) {
            if (mounted) {
              ref.read(globalUserInfoProvider.state).state = data;
              preferences.putString(Preferences.KEY_USER_INFO, json.encode(user.toJson()));
            }
          }, (error) {});
        }
      });
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }
    });
    // User? user = ref.read(globalUserInfoProvider);
    // if (user != null) {
    //   network.requestAsync<User>(network.getUserInfo(user.id), (data) {
    //     ref.read(globalUserInfoProvider.state).state = data;
    //   }, (error) {});
    // }
  }

  @override
  void dispose() {
    controller.dispose();
    globalHomeScreenIsInStack = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    HomePageModelState modelState = ref.watch(homePageProvider);
    User? currentUser = ref.watch(globalUserInfoProvider);
    // debugPrint("home tab_index=${modelState.tabIndex}");
    double avatarSize = 14.4;
    double avatarStrokeWidth = 2.4;
    Widget meTabIcon = currentUser == null
        ? HoohIcon(
            "assets/images/default_avatar_1.jpg",
            width: avatarSize,
            height: avatarSize,
          )
        : HoohImage(
            imageUrl: currentUser.avatarUrl ?? "",
            width: avatarSize,
            height: avatarSize,
          );
    meTabIcon = Container(
      width: 28,
      height: 28,
      child: ClipOval(child: meTabIcon),
      decoration: BoxDecoration(border: Border.all(color: designColors.light_06.auto(ref), width: avatarStrokeWidth), shape: BoxShape.circle),
    );
    return Scaffold(
      floatingActionButton: floatingButtons[modelState.tabIndex],
      extendBody: true,
      body: pageContents[modelState.tabIndex],
      bottomNavigationBar: AnimatedSlide(
        duration: Duration(milliseconds: 250),
        offset: Offset(0, ref.watch(bottomBarVisibilityProvider.state).state ? 0 : 1),
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                  icon: HoohIcon(
                    modelState.tabIndex != 0 ? "assets/images/icon_tab_creation_off.svg" : "assets/images/icon_tab_creation_on.svg",
                    width: 36,
                    height: 36,
                    color: modelState.tabIndex != 0 ? designColors.light_06.auto(ref) : null,
                  ),
                  label: ""),
              BottomNavigationBarItem(
                  icon: HoohIcon(
                    modelState.tabIndex != 1 ? "assets/images/icon_tab_templates_off.svg" : "assets/images/icon_tab_templates_on.svg",
                    color: modelState.tabIndex != 1 ? designColors.light_06.auto(ref) : null,
                    width: 36,
                    height: 36,
                  ),
                  label: ""),
              BottomNavigationBarItem(
                  icon: HoohIcon(
                    modelState.tabIndex != 2 ? "assets/images/icon_tab_feeds_off.svg" : "assets/images/icon_tab_feeds_on.svg",
                    color: modelState.tabIndex != 2 ? designColors.light_06.auto(ref) : null,
                    width: 36,
                    height: 36,
                  ),
                  label: ""),
              // BottomNavigationBarItem(icon: Icon(Icons.person),
              //     label: ""
              // ),
              BottomNavigationBarItem(icon: meTabIcon, label: ""),
            ],
            // selectedItemColor: designColors.feiyu_blue.auto(ref),
            // unselectedItemColor: designColors.dark_03.auto(ref),
            onTap: (index) {
              FocusManager.instance.primaryFocus?.unfocus();
              ref.read(homePageProvider.notifier).updateTabIndex(index);
              // if (index == HomeScreen.PAGE_INDEX_ME) {
              //   User? user = ref.read(globalUserInfoProvider);
              //   if (user != null) {
              //     network.requestAsync<User>(network.getUserInfo(user.id), (data) {
              //       ref.read(globalUserInfoProvider.state).state = data;
              //     }, (error) {});
              //   }
              // }
            },
            currentIndex: modelState.tabIndex,
          ),
        ).frosted(
          blur: 10,
          frostColor: designColors.light_01.auto(ref),
          frostOpacity: 0.9,
        ),
      ),
    );
  }

// String getTitle(int index) {
//   switch (index) {
//     case 0:
//       return "input";
//     case 1:
//       return "gallery";
//     case 2:
//       return "social";
//     case 3:
//       return "me";
//     default:
//       return "";
//   }
// }
}
