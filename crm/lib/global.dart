import 'dart:convert';

import 'package:crm/utils/design_colors.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void handleUserLogin(WidgetRef ref, User user, String token) {
  ref.read(globalUserInfoProvider.state).state = user;
  network.setUserToken(token);
  preferences.putString(Preferences.KEY_USER_INFO, json.encode(user.toJson()));
}

void handleUserLogout(WidgetRef ref) {
  preferences.remove(Preferences.KEY_FCM_TOKEN);
  ref.read(globalUserInfoProvider.state).state = null;
  preferences.remove(Preferences.KEY_USER_INFO);
  network.setUserToken(null);
}

void openLink(BuildContext context, String url, {String? title}) async {
  // Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewScreen(title ?? "", url)));
}

final GlobalRouteObserver<PageRoute> routeObserver = GlobalRouteObserver<PageRoute>();

bool globalHomeScreenIsInStack = false;
double globalDarkModeImageOpacity = 0.7;
int globalDarkModeImageAlpha = (255 * globalDarkModeImageOpacity).toInt();

final StateProvider<bool> globalKeyboardVisibilityProvider = StateProvider<bool>((ref) => false);
final StateProvider<Orientation?> globalOrientationProvider = StateProvider<Orientation?>((ref) => null);
final StateProvider<User?> globalUserInfoProvider = StateProvider<User?>((ref) => null);
final StateProvider<Locale?> globalLocaleProvider = StateProvider<Locale?>((ref) => null);
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
