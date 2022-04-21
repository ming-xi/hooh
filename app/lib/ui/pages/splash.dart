import 'dart:convert';
import 'dart:math';

import 'package:app/providers.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/user/register/set_badge.dart';
import 'package:app/ui/pages/user/register/start.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/preferences.dart';
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
    Duration totalTime = const Duration(seconds: 3);
    DateTime start = DateTime.now();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Future.delayed(
        Duration(milliseconds: max(0, totalTime.inMilliseconds - DateTime.now().difference(start).inMilliseconds)),
        () {
          String? jsonString = preferences.getString(Preferences.KEY_USER_INFO);
          User? user;
          if (jsonString != null) {
            user = User.fromJson(json.decode(jsonString));
            ref.read(globalUserInfoProvider.state).state = user;
          }
          if (user == null) {
            if (preferences.getBool(Preferences.KEY_USER_HAS_SKIPPED_LOGIN) ?? false) {
              Navigator.pushReplacement(context, pageRouteBuilder(HomeScreen()));
            } else {
              Navigator.pushReplacement(context, pageRouteBuilder(const StartScreen()));
            }
          } else {
            if (user.hasFinishedRegisterSteps()) {
              Navigator.pushReplacement(context, pageRouteBuilder(HomeScreen()));
            } else {
              // int register_step = user.register_step!;
              // ......
              Navigator.pushReplacement(context, pageRouteBuilder(SetBadgeScreen()));
            }
          }
        },
      );
    });
  }

  PageRouteBuilder<dynamic> pageRouteBuilder(Widget widget) => PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => widget,
        transitionsBuilder: (context, anim1, anim2, child) => FadeTransition(opacity: anim1, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(
          flex: 1,
        ),
        Image.asset('assets/images/logo.png', height: 160, width: 160),
        Spacer(
          flex: 2,
        ),
      ],
    );
  }
}
