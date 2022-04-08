import 'package:app/ui/pages/User/register/verify_code.dart';
import 'package:app/ui/pages/User/web_view.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phone_form_field/phone_form_field.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  SignUpScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TapGestureRecognizer _tapGestureRecognizer = TapGestureRecognizer();
  String _phoneNumber = "";
  int _countryCode = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tapGestureRecognizer.dispose();
    debugPrint("sign up dispose");
  }

  @override
  Widget build(BuildContext context) {
    PhoneNumber phone = PhoneNumber(isoCode: 'AS', nsn:'');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        actions: [
          Center(
            child: SizedBox(
              width: 80,
              child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                  child: const Text('Login',
                      style: TextStyle(
                        color: Colors.blue,
                      ))),
            ),
          ),
          // Icon(
          //     Icons.more_vert
          // ),
        ],
      ),
      // body: Container(
      //   child: Center(
      //     child: FloatingActionButton(
      //       onPressed: (){
      //         // 登陆成功之后进入主页
      //         Navigator.of(context).popUntil((route) => route.isFirst);
      //         Navigator.pushReplacement(context,
      //             MaterialPageRoute(builder: (context) => HomeScreen()));
      //       },
      //     ),
      //   ),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: PhoneFormField(
                    autofocus: true,

                    // selectorNavigator: const DraggableModalBottomSheetNavigator(
                    //
                    // ),
                    onSaved: (p) => debugPrint('saved $p'),
                    // ignore: avoid_print
                    onChanged: (p) {
                      if (p != null) {
                        // if (p.validate()) {
                        phone = p;
                        _phoneNumber = p.nsn;
                        _countryCode = int.tryParse(p.countryCode)!;
                        // }
                      }
                      debugPrint(_phoneNumber);
                      debugPrint('changed $p');
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!phone.validate()) {
                      showDialog(
                          context: context,
                          builder: (e) => AlertDialog(
                                content: Text("invalid mobile"),
                              ));
                      return;
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyCodeScreen(_countryCode, _phoneNumber)));
                  },
                  child: const Text('Agree and sign up'),
                ),
                const SizedBox(
                  height: 10,
                ),
                RichText(
                    text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        text: 'I read and agree ',
                        children: [
                      TextSpan(
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                        text: 'User Agreement and Privacy Policy',
                        recognizer: _tapGestureRecognizer
                          ..onTap = () {
                            debugPrint("点击了隐私协议");
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => const WebViewScreen('User Agreement and Privacy Policy', 'https://www.baidu.com')));
                          },
                      )
                    ]))
              ],
            ),
          )
        ],
      ),
    );
  }

  bool checkMobileNumber(String mobile) {
    // String? match = RegExp(r"/^(\+\d{1,3}[- ]?)?\d{10}$/").stringMatch(mobile);
    // return match != null && match == mobile;
    return true;
  }
}
