import 'dart:convert';

import 'package:app/global.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/user/register/set_badge.dart';
import 'package:app/ui/pages/user/register/start.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      Future.delayed(
        Duration(milliseconds: 0),
        () {
          String? jsonString = preferences.getString(Preferences.KEY_USER_INFO);
          int darkMode = preferences.getInt(Preferences.KEY_DARK_MODE) ?? DARK_MODE_SYSTEM;
          ref.read(globalDarkModeProvider.state).state = darkMode;
          User? user;
          if (jsonString != null) {
            user = User.fromJson(json.decode(jsonString));
            ref.read(globalUserInfoProvider.state).state = user;
          }
          if (user == null) {
            if (preferences.getBool(Preferences.KEY_USER_HAS_SKIPPED_LOGIN) ?? false) {
              Navigator.pushReplacement(context, pageRouteBuilder(HomeScreen(), isHome: true));
            } else {
              Navigator.pushReplacement(context, pageRouteBuilder(StartScreen()));
            }
          } else {
            if (user.hasFinishedRegisterSteps()) {
              Navigator.pushReplacement(context, pageRouteBuilder(HomeScreen(), isHome: true));
            } else {
              // int register_step = user.register_step!;
              // ......
              Navigator.pushReplacement(context, pageRouteBuilder(SetBadgeScreen()));
            }
          }
          // Future.delayed(Duration(milliseconds: 250), () {
          //
          // });
        },
      );
    });
  }

  PageRouteBuilder<dynamic> pageRouteBuilder(Widget widget, {bool isHome = false}) => PageRouteBuilder(
        settings: !isHome ? null : const RouteSettings(name: "/home"),
        pageBuilder: (context, anim1, anim2) => widget,
        // transitionsBuilder: (context, anim1, anim2, child) => FadeTransition(opacity: anim1, child: child),
        // transitionDuration: const Duration(milliseconds: 250),
      );

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
