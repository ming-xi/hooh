import 'dart:convert';

import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/user/web_view.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/push.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void handleUserLogin(WidgetRef ref, User user, String token) {
  ref.read(globalUserInfoProvider.state).state = user;
  network.setUserToken(token);
  preferences.putString(Preferences.KEY_USER_INFO, json.encode(user.toJson()));
  pushUtil.updateUserToken(ref);
}

void handleUserLogout(WidgetRef ref) {
  pushUtil.clearUserToken(ref);
  preferences.remove(Preferences.KEY_FCM_TOKEN);
  ref.read(globalUserInfoProvider.state).state = null;
  preferences.remove(Preferences.KEY_USER_INFO);
  network.setUserToken(null);
}

void openLink(BuildContext context, String url, {String? title}) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewScreen(title ?? "", url)));
  // launchUrlString(url);
}

late AppLocalizations globalLocalizations;
// bool globalIsKeyboardVisible = false;
bool globalHomeScreenIsInStack = false;
double globalDarkModeImageOpacity = 0.7;
int globalDarkModeImageAlpha = (255 * globalDarkModeImageOpacity).toInt();

void popToHomeScreen(BuildContext context) {
  debugPrint("globalHomeScreenIsInStack=$globalHomeScreenIsInStack");
  if (globalHomeScreenIsInStack) {
    Navigator.popUntil(context, ModalRoute.withName("/home"));
  } else {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
        settings: const RouteSettings(name: "/home"),
      ),
          (route) => false,
    );
  }
}

final StateProvider<bool> globalKeyboardInfoProvider = StateProvider<bool>((ref) => false);
final StateProvider<User?> globalUserInfoProvider = StateProvider<User?>((ref) => null);
const DARK_MODE_SYSTEM = 0;
const DARK_MODE_LIGHT = 1;
const DARK_MODE_DARK = 2;
const DARK_MODE_VALUES = [
  DARK_MODE_SYSTEM,
  DARK_MODE_LIGHT,
  DARK_MODE_DARK,
];
final StateProvider<int> globalDarkModeProvider = StateProvider((ref) {
  return DARK_MODE_SYSTEM;
});

final globalLightTheme = ThemeData(
    primaryColor: designColors.bar90_1.light,
    brightness: Brightness.light,
    backgroundColor: designColors.light_00.light,
    fontFamily: 'Linotte',
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: designColors.bar90_1.light,
      titleTextStyle: TextStyle(color: designColors.dark_01.light, fontFamily: 'Linotte', fontWeight: FontWeight.bold, fontSize: 16),
      actionsIconTheme: IconThemeData(color: designColors.dark_01.light),
      iconTheme: IconThemeData(color: designColors.dark_01.light),
      foregroundColor: designColors.feiyu_blue.generic,
      toolbarTextStyle: TextStyle(color: designColors.feiyu_blue.generic, fontFamily: 'Linotte', fontWeight: FontWeight.bold, fontSize: 16),
      // shadowColor: Colors.transparent,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
    }),
    dialogTheme: DialogTheme(
      backgroundColor: designColors.light_01.light,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
    ),
    checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.all(designColors.light_01.light),
        fillColor: MaterialStateProperty.all(designColors.dark_01.light),
        side: BorderSide(color: designColors.dark_01.light, width: 1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        )),
    tabBarTheme: TabBarTheme(
        labelStyle: TextStyle(
          color: designColors.dark_01.light,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Linotte',
        ),
        unselectedLabelStyle: TextStyle(
          color: designColors.dark_01.light,
          fontSize: 16,
          fontFamily: 'Linotte',
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: designColors.dark_01.light, width: 1),
        )),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
                TextStyle(fontSize: 16, color: designColors.feiyu_blue.generic, fontFamily: 'Linotte', fontWeight: FontWeight.bold)))));

final globalDarkTheme = ThemeData(
    primaryColor: designColors.bar90_1.dark,
    brightness: Brightness.dark,
    backgroundColor: designColors.light_00.dark,
    fontFamily: 'Linotte',
    toggleableActiveColor: designColors.feiyu_blue.generic,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: designColors.bar90_1.dark,
      titleTextStyle: TextStyle(color: designColors.dark_01.dark, fontFamily: 'Linotte', fontWeight: FontWeight.bold, fontSize: 16),
      actionsIconTheme: IconThemeData(color: designColors.dark_01.dark),
      iconTheme: IconThemeData(color: designColors.dark_01.dark),
      foregroundColor: designColors.feiyu_blue.generic,
      toolbarTextStyle: TextStyle(color: designColors.feiyu_blue.generic, fontFamily: 'Linotte', fontWeight: FontWeight.bold, fontSize: 16),
      // shadowColor: Colors.transparent,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    }),
    dialogTheme: DialogTheme(
      backgroundColor: designColors.light_01.dark,
      shape: const RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(24))),
    ),
    checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.all(designColors.light_01.dark),
        fillColor: MaterialStateProperty.all(designColors.dark_01.dark),
        side: BorderSide(color: designColors.dark_01.dark, width: 1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        )),
    tabBarTheme: TabBarTheme(
        labelStyle: TextStyle(
          color: designColors.dark_01.dark,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Linotte',
        ),
        unselectedLabelStyle: TextStyle(
          color: designColors.dark_01.dark,
          fontSize: 16,
          fontFamily: 'Linotte',
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: designColors.dark_01.dark, width: 1),
        )),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
                TextStyle(fontSize: 16, color: designColors.feiyu_blue.generic, fontFamily: 'Linotte', fontWeight: FontWeight.bold)))));
