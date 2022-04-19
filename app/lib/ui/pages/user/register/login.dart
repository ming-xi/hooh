import 'package:app/extensions/extensions.dart';
import 'package:app/test.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/user/register/sign_up.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/design_colors.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    debugPrint("color=${designColors.bar90_1.auto(ref).toHex()}");
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Text("test"),
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TestUploadingAvatarScreen()));
          // LoginResponse loginResponse = await network.login("app_test1", "123456");
          // network.setUserToken(loginResponse.jwtResponse.accessToken);
          // ref.read(globalUserInfoProvider.state).state=loginResponse.user;
          // Navigator.push(context, MaterialPageRoute(builder: (context) => SetBadgeScreen()));
        },
      ),
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                        },
                        style: RegisterStyles.blackButtonStyle(ref),
                        child: const Text('Sign Up')),
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Or Login'),
                      style: RegisterStyles.blackOutlineButtonStyle(ref),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        onPressed: () {
                          String hasSkipped = "hasSkipped";
                          preferences.putBool(hasSkipped, true);
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
