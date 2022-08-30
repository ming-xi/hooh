import 'dart:convert';

import 'package:app/launcher.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/user/web_view.dart';
import 'package:app/utils/push.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void handleUserLogin(WidgetRef ref, User user, String token, String? password) {
  ref.read(globalUserInfoProvider.state).state = user;
  network.setUserToken(token);
  preferences.putString(Preferences.KEY_USER_INFO, json.encode(user.toJson()));
  _saveLoginHistory(password, user);
  pushUtil.updateUserToken(ref);
}

void _saveLoginHistory(String? password, User user) {
  if (!FlavorConfig.instance.variables[Launcher.KEY_ADMIN_MODE]) {
    return;
  }
  List<dynamic> list = json.decode(preferences.getString(Preferences.KEY_HISTORY_USER_LOGIN_INFO) ?? "[]");
  List<UserLoginHistory> history = list.map((e) => UserLoginHistory.fromJson(e)).toList();
  DateTime currentUtcDate = DateUtil.getCurrentUtcDate();
  if (history.map((e) => e.username).contains(user.username)) {
    history.firstWhere((element) => element.username == user.username).lastLoginAt = currentUtcDate;
  } else if (password != null) {
    String encryptedPassword = sha512.convert(utf8.encode(password)).toString();
    history.add(UserLoginHistory(network.serverType, user.username!, encryptedPassword, user.name, user.avatarUrl!, currentUtcDate));
  }
  history.sort(
    (a, b) => b.lastLoginAt.compareTo(a.lastLoginAt),
  );
  preferences.putString(Preferences.KEY_HISTORY_USER_LOGIN_INFO, json.encode(history));
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

final GlobalRouteObserver<PageRoute> routeObserver = GlobalRouteObserver<PageRoute>();

late AppLocalizations globalLocalizations;
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

final StateProvider<bool> globalKeyboardVisibilityProvider = StateProvider<bool>((ref) => false);
final StateProvider<User?> globalUserInfoProvider = StateProvider<User?>((ref) => null);
final StateProvider<Locale?> globalLocaleProvider = StateProvider<Locale?>((ref) => null);
// final StateProvider<Locale?> globalLocaleProvider = StateProvider<Locale?>((ref) => const Locale("en"));
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

// final globalLightTheme = ThemeData(
//         primaryColor: designColors.bar90_1.light,
//         brightness: Brightness.light,
//         backgroundColor: designColors.light_00.light,
//         fontFamily: 'Linotte',
//         appBarTheme: AppBarTheme(
//           elevation: 0,
//           centerTitle: true,
//           backgroundColor: designColors.bar90_1.light,
//           titleTextStyle: TextStyle(color: designColors.dark_01.light, fontFamily: 'Linotte', fontWeight: FontWeight.bold, fontSize: 16),
//           actionsIconTheme: IconThemeData(color: designColors.dark_01.light),
//           iconTheme: IconThemeData(color: designColors.dark_01.light),
//           foregroundColor: designColors.feiyu_blue.generic,
//           toolbarTextStyle: TextStyle(color: designColors.feiyu_blue.generic, fontFamily: 'Linotte', fontWeight: FontWeight.bold, fontSize: 16),
//           // shadowColor: Colors.transparent,
//         ),
//         pageTransitionsTheme: const PageTransitionsTheme(builders: {
//           TargetPlatform.android: CupertinoPageTransitionsBuilder(),
//           TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
//           TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
//         }),
//         dialogTheme: DialogTheme(
//           backgroundColor: designColors.light_01.light,
//           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
//         ),
//         checkboxTheme: CheckboxThemeData(
//             checkColor: MaterialStateProperty.all(designColors.light_01.light),
//             fillColor: MaterialStateProperty.all(designColors.dark_01.light),
//             side: BorderSide(color: designColors.dark_01.light, width: 1),
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(
//                 Radius.circular(4),
//               ),
//             )),
//         tabBarTheme: TabBarTheme(
//             labelStyle: TextStyle(
//               color: designColors.dark_01.light,
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Linotte',
//             ),
//             unselectedLabelStyle: TextStyle(
//               color: designColors.dark_01.light,
//               fontSize: 16,
//               fontFamily: 'Linotte',
//             ),
//             indicatorSize: TabBarIndicatorSize.label,
//             indicator: UnderlineTabIndicator(
//               borderSide: BorderSide(color: designColors.dark_01.light, width: 1),
//             )),
//         textButtonTheme: TextButtonThemeData(
//             style: ButtonStyle(
//                 textStyle: MaterialStateProperty.all(
//                     TextStyle(fontSize: 16, color: designColors.feiyu_blue.generic, fontFamily: 'Linotte', fontWeight: FontWeight.bold)))))
//     .copyWith(
//         dialogTheme: DialogTheme(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             titleTextStyle: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//               color: designColors.dark_01.light,
//               fontFamily: 'Linotte',
//             ),
//             contentTextStyle: TextStyle(
//               color: designColors.dark_01.light,
//               fontSize: 12,
//               fontFamily: 'Linotte',
//             )));
//
// final globalDarkTheme = ThemeData(
//         primaryColor: designColors.bar90_1.dark,
//         brightness: Brightness.dark,
//         backgroundColor: designColors.light_00.dark,
//         fontFamily: 'Linotte',
//         toggleableActiveColor: designColors.feiyu_blue.generic,
//         appBarTheme: AppBarTheme(
//           elevation: 0,
//           centerTitle: true,
//           backgroundColor: designColors.bar90_1.dark,
//           titleTextStyle: TextStyle(color: designColors.dark_01.dark, fontFamily: 'Linotte', fontWeight: FontWeight.bold, fontSize: 16),
//           actionsIconTheme: IconThemeData(color: designColors.dark_01.dark),
//           iconTheme: IconThemeData(color: designColors.dark_01.dark),
//           foregroundColor: designColors.feiyu_blue.generic,
//           toolbarTextStyle: TextStyle(color: designColors.feiyu_blue.generic, fontFamily: 'Linotte', fontWeight: FontWeight.bold, fontSize: 16),
//           // shadowColor: Colors.transparent,
//         ),
//         pageTransitionsTheme: const PageTransitionsTheme(builders: {
//           TargetPlatform.android: CupertinoPageTransitionsBuilder(),
//         }),
//         dialogTheme: DialogTheme(
//           backgroundColor: designColors.light_01.dark,
//           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
//         ),
//         checkboxTheme: CheckboxThemeData(
//             checkColor: MaterialStateProperty.all(designColors.light_01.dark),
//             fillColor: MaterialStateProperty.all(designColors.dark_01.dark),
//             side: BorderSide(color: designColors.dark_01.dark, width: 1),
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(
//                 Radius.circular(4),
//               ),
//             )),
//         tabBarTheme: TabBarTheme(
//             labelStyle: TextStyle(
//               color: designColors.dark_01.dark,
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Linotte',
//             ),
//             unselectedLabelStyle: TextStyle(
//               color: designColors.dark_01.dark,
//               fontSize: 16,
//               fontFamily: 'Linotte',
//             ),
//             indicatorSize: TabBarIndicatorSize.label,
//             indicator: UnderlineTabIndicator(
//               borderSide: BorderSide(color: designColors.dark_01.dark, width: 1),
//             )),
//         textButtonTheme: TextButtonThemeData(
//             style: ButtonStyle(
//                 textStyle: MaterialStateProperty.all(
//                     TextStyle(fontSize: 16, color: designColors.feiyu_blue.generic, fontFamily: 'Linotte', fontWeight: FontWeight.bold)))))
//     .copyWith(
//         dialogTheme: DialogTheme(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             titleTextStyle: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//               color: designColors.dark_01.dark,
//               fontFamily: 'Linotte',
//             ),
//             contentTextStyle: TextStyle(
//               color: designColors.dark_01.dark,
//               fontSize: 12,
//               fontFamily: 'Linotte',
//             )));
class GlobalRouteObserver<R extends Route<dynamic>> extends RouteObserver<R> {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    print('didPush route: $route,previousRoute:$previousRoute');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    print('didPop route: $route,previousRoute:$previousRoute');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    print('didReplace newRoute: $newRoute,oldRoute:$oldRoute');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    print('didRemove route: $route,previousRoute:$previousRoute');
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    print('didStartUserGesture route: $route,previousRoute:$previousRoute');
  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
    print('didStopUserGesture');
  }
}
