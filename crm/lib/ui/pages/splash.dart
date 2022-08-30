import 'dart:convert';

import 'package:crm/global.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/preferences.dart';
import 'package:crm/ui/pages/home.dart';
import 'package:flutter/material.dart';
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
      Future.delayed(
        Duration(milliseconds: 0),
        () {
          String? jsonString = preferences.getString(Preferences.KEY_USER_INFO);
          int darkMode = preferences.getInt(Preferences.KEY_DARK_MODE) ?? DARK_MODE_SYSTEM;
          ref.read(globalDarkModeProvider.state).state = darkMode;
          String? languageCode = preferences.getString(Preferences.KEY_LANGUAGE);
          debugPrint("languageCode=$languageCode");
          ref.read(globalLocaleProvider.state).state = languageCode == null ? null : Locale(languageCode);
          User? user;
          if (jsonString != null) {
            user = User.fromJson(json.decode(jsonString));
            ref.read(globalUserInfoProvider.state).state = user;
          }
          Navigator.pushReplacement(context, pageRouteBuilder(HomeScreen(), isHome: true));

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
