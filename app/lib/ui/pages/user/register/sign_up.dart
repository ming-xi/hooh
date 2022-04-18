import 'package:app/ui/pages/User/register/set_nickname.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/user/register/register_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/pages/user/web_view.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  final StateNotifierProvider<RegisterViewModel, RegisterModelState> provider = StateNotifierProvider((ref) {
    return RegisterViewModel(RegisterModelState.init());
  });

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
    RegisterModelState modelState = ref.watch(widget.provider);
    RegisterViewModel model = ref.watch(widget.provider.notifier);
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
                  child: Text('Login',
                      style: TextStyle(
                        color: designColors.feiyu_blue.auto(ref),
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
                  TextField(
                    controller: usernameController,
                    focusNode: usernameNode,
                    style: RegisterStyles.inputTextStyle(ref),
                    decoration: RegisterStyles.commonInputDecoration("Username", ref,
                        helperText: "It cannot be modified after registration", errorText: modelState.usernameErrorText),
                    onChanged: (text) {
                      model.checkUsername(text);
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: emailController,
                    focusNode: emailNode,
                    style: RegisterStyles.inputTextStyle(ref),
                    decoration: RegisterStyles.commonInputDecoration("Email", ref, errorText: modelState.emailErrorText),
                    onChanged: (text) {
                      model.checkEmail(text);
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: passwordController,
                    focusNode: passwordNode,
                    style: RegisterStyles.inputTextStyle(ref),
                    decoration: RegisterStyles.commonInputDecoration("Enter password", ref,
                        helperText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters", errorText: modelState.passwordErrorText),
                    obscureText: true,
                    onChanged: (text) {
                      model.checkPassword(text, passwordConfirmController.text);
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    style: RegisterStyles.inputTextStyle(ref),
                    controller: passwordConfirmController,
                    focusNode: passwordConfirmNode,
                    decoration: RegisterStyles.commonInputDecoration("Confirmed password", ref, errorText: modelState.confirmPasswordErrorText),
                    obscureText: true,
                    onChanged: (text) {
                      model.checkPassword(passwordController.text, text);
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                    style: RegisterStyles.flatBlackButtonStyle(ref),
                    onPressed: () {
                      model.register(context, usernameController.text, passwordController.text, emailController.text, onSuccess: (user) {
                        Toast.showSnackBar(context, "注册成功");
                      });
                    },
                    child: const Text('Agree and sign up'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  RichText(
                      text: TextSpan(
                          style: TextStyle(
                            color: designColors.dark_01.auto(ref),
                            fontSize: 12,
                          ),
                          text: 'I read and agree ',
                          children: [
                        TextSpan(
                          style: TextStyle(
                            color: designColors.blue_dark.auto(ref),
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
