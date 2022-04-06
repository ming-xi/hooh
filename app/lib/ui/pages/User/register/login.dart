import 'package:app/ui/pages/User/register/sign_up.dart';
import 'package:app/ui/pages/home/home.dart';
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
                    children: const [
                      Text(
                        'Let\'s start',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'HOOH',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.black,
                        ),
                      ),
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
                      TextButton(onPressed: (){
                        Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUpScreen()));
                      }, child: Text('Sign Up')),
                      TextButton(onPressed: (){}, child: Text('Or Login')),
                      TextButton(onPressed: (){
                        String hasSkipped = "hasSkipped";
                        preferences.putBool(hasSkipped, true);
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => HomeScreen()));
                      }, child: Text('Skip')),
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
}
