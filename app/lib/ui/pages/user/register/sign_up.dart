import 'package:app/ui/pages/User/register/set_nickname.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/pages/user/web_view.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  SignUpScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TapGestureRecognizer _tapGestureRecognizer = TapGestureRecognizer();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  FocusNode usernameNode = FocusNode();
  FocusNode emailNode = FocusNode();
  FocusNode passwordNode = FocusNode();
  FocusNode passwordConfirmNode = FocusNode();


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tapGestureRecognizer.dispose();
    debugPrint("sign up dispose");
  }

  @override
  Widget build(BuildContext context) {
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
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Username",
                        style: RegisterStyles.titleTextStyle(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: usernameController,
                    focusNode: usernameNode,
                    style: RegisterStyles.inputTextStyle(),
                    decoration: RegisterStyles.commonInputDecoration("Enter username"),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Email",
                        style: RegisterStyles.titleTextStyle(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: emailController,
                    focusNode: emailNode,
                    style: RegisterStyles.inputTextStyle(),
                    decoration: RegisterStyles.commonInputDecoration("Enter email"),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Password",
                        style: RegisterStyles.titleTextStyle(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                      controller: passwordController,
                      focusNode: passwordNode,
                      style: RegisterStyles.inputTextStyle(),
                      decoration: RegisterStyles.commonInputDecoration("Enter password"),
                      obscureText: true),
                  SizedBox(
                    height: 24,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Confirm Password",
                        style: RegisterStyles.titleTextStyle(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                      style: RegisterStyles.inputTextStyle(),
                      controller: passwordConfirmController,
                      focusNode: passwordConfirmNode,
                      decoration: RegisterStyles.commonInputDecoration("Enter password again"),
                      obscureText: true),
                  SizedBox(
                    height: 24,
                  ),
                  ElevatedButton(
                    style: RegisterStyles.flatBlackButtonStyle(),
                    onPressed: () {
                      network.requestAsync<LoginResponse>(network.register(usernameController.text,passwordController.text,emailController.text), (data){
                        Toast.show(context: context, message: "注册成功");
                        network.setUserToken(data.jwtResponse.accessToken);
                        preferences.putInt(Preferences.keyUserRegisterStep, data.user.register_step);
                        Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SetNicknameScreen()));
                      }, (error) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return  AlertDialog(
                                content: Text(error.message),
                              );
                            });
                      });

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
