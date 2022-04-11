import 'package:app/ui/pages/User/register/sign_up.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    debugPrint("login dispose");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // child: Center(
        //   child: FloatingActionButton(
        //     onPressed: () {
        //       Navigator.pushReplacement(context,
        //           MaterialPageRoute(builder: (context) => HomeScreen()));
        //     },
        //   ),
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                // color: Colors.red,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Let\'s start',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFFF26218),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SvgPicture.asset('assets/images/logo.svg', height: 160, width: 160)
                    ],
                  ),
                ),
              ),
              flex: 3,
            ),
            Expanded(
              child: Container(
                // color: Colors.blue,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                          },
                          style: flatBlackButtonStyle,
                          child: const Text('Sign Up')),
                      const SizedBox(
                        height: 20,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Or Login'),
                        style: flatWhiteButtonStyle,
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
      ),
    );
  }

  final ButtonStyle flatBlackButtonStyle = TextButton.styleFrom(
      primary: Colors.white,
      minimumSize: const Size(275, 64),
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22.0)),
      ),
      textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));

  final ButtonStyle flatWhiteButtonStyle = OutlinedButton.styleFrom(
      primary: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22.0)),
      ),
      minimumSize: const Size(275, 64),
      side: BorderSide(width: 1, color: Colors.black),
      textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black));
}
