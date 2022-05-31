import 'package:app/global.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/me/settings/setting.dart';
import 'package:app/ui/pages/user/register/login.dart';
import 'package:app/ui/pages/user/register/register.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StartScreen extends ConsumerStatefulWidget {
  final bool isStandaloneScreen;

  StartScreen({
    this.isStandaloneScreen = true,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  @override
  Widget build(BuildContext context) {
    // debugPrint("_StartScreenState build");
    TextStyle skipStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: designColors.dark_03.auto(ref));
    return Scaffold(
      appBar: widget.isStandaloneScreen
          ? null
          : AppBar(
              actions: [
                TextButton(
                  child: Text(globalLocalizations.start_settings),
                  style: RegisterStyles.appbarTextButtonStyle(ref),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                  },
                )
              ],
              leading: null,
            ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Container(
            // color: Colors.red,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    globalLocalizations.start_title,
                    style: TextStyle(
                      fontSize: 24,
                      color: designColors.orange.auto(ref),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // SvgPicture.asset('assets/images/logo.svg', height: 160, width: 160)
                  Image.asset('assets/images/logo.png', height: 160, width: 160)
                ],
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                    onPressed: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                    },
                    style: RegisterStyles.blackButtonStyle(ref),
                    child: Text(globalLocalizations.login_register)),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text(globalLocalizations.start_login),
                  style: RegisterStyles.blackOutlineButtonStyle(ref),
                ),
                const SizedBox(
                  height: 20,
                ),
                Visibility(
                  visible: widget.isStandaloneScreen,
                  child: TextButton(
                      style: MainStyles.textButtonStyle(ref),
                      onPressed: () {
                        preferences.putBool(Preferences.KEY_USER_HAS_SKIPPED_LOGIN, true);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                              settings: const RouteSettings(name: "/home"),
                            ));
                      },
                      child: Text(globalLocalizations.start_skip, style: skipStyle)),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      globalLocalizations.start_base_on,
                      style: skipStyle,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    HoohIcon(
                      "assets/images/figure_near_logo.svg",
                      width: 64,
                      height: 17,
                    )
                  ],
                ),
                SizedBox(
                  height: !widget.isStandaloneScreen ? 72 : 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
