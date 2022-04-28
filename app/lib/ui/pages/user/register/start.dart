import 'package:app/extensions/extensions.dart';
import 'package:app/test.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/user/register/login.dart';
import 'package:app/ui/pages/user/register/register.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/design_colors.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  @override
  Widget build(BuildContext context) {
    debugPrint("color=${designColors.bar90_1.auto(ref).toHex()}");
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              // color: Colors.red,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Let\'s start',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFFF26218),
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
            flex: 3,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                        onPressed: () {
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
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
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        onPressed: () {
                          preferences.putBool(Preferences.KEY_USER_HAS_SKIPPED_LOGIN, true);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                        },
                        child: Text('Skip', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey))),
                  ],
                ),
              ),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }
}
