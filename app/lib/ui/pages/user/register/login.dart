import 'dart:convert';

import 'package:app/global.dart';
import 'package:app/ui/pages/user/register/login_view_model.dart';
import 'package:app/ui/pages/user/register/register.dart';
import 'package:app/ui/pages/user/register/set_badge.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/push.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final StateNotifierProvider<LoginViewModel, LoginModelState> provider = StateNotifierProvider((ref) {
    return LoginViewModel(LoginModelState.init());
  });

  LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode usernameNode = FocusNode();
  FocusNode passwordNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    // debugPrint("_LoginScreenState build");
    LoginModelState modelState = ref.watch(widget.provider);
    LoginViewModel model = ref.read(widget.provider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
              style: RegisterStyles.appbarTextButtonStyle(ref),
              child: Text(
                globalLocalizations.login_register,
              )),
          // Icon(
          //     Icons.more_vert
          // ),
        ],
      ),
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
                    children: [
                      Text(
                        globalLocalizations.login_welcome,
                        style: RegisterStyles.titleTextStyle(ref),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: usernameController,
                    focusNode: usernameNode,
                    style: RegisterStyles.inputTextStyle(ref),
                    decoration: RegisterStyles.commonInputDecoration(
                      globalLocalizations.login_username,
                      ref,
                    ),
                    onChanged: (text) {
                      model.checkUsernameAndPassword(text, passwordController.text);
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: passwordController,
                    focusNode: passwordNode,
                    style: RegisterStyles.inputTextStyle(ref),
                    decoration: RegisterStyles.passwordInputDecoration(globalLocalizations.login_password, ref, passwordVisible: modelState.passwordVisible,
                        onTogglePasswordVisible: () {
                      model.togglePasswordVisible();
                    }),
                    obscureText: !modelState.passwordVisible,
                    onChanged: (text) {
                      model.checkUsernameAndPassword(text, usernameController.text);
                    },
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  TextButton(
                    style: RegisterStyles.blackButtonStyle(ref),
                    onPressed: !modelState.loginButtonEnabled
                        ? null
                        : () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return LoadingDialog(LoadingDialogController());
                                });
                            model.login(context, usernameController.text, passwordController.text, onSuccess: (response) {
                              handleUserLogin(ref, response.user, response.jwtResponse.accessToken);
                              // ref.read(globalUserInfoProvider.state).state = user;
                              // preferences.putString(Preferences.KEY_USER_INFO, json.encode(user.toJson()));
                              // pushUtil.updateUserToken(ref);
                              Navigator.of(context).pop();
                              // Toast.showSnackBar(context, "登录成功");
                              if (response.user.hasFinishedRegisterSteps()) {
                                // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
                                // popToHomeScreen(context);
                                Navigator.of(context).pop(true);
                              } else {
                                // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SetBadgeScreen()), (route) => false)
                                Navigator.push(context, MaterialPageRoute(builder: (context) => SetBadgeScreen())).then((result) {
                                  if (result != null && result is bool && result) {
                                    Navigator.of(context).pop(true);
                                  }
                                });
                              }
                            }, onFailed: () {
                              Navigator.of(context).pop();
                            });
                          },
                    child: Text(globalLocalizations.login_login),
                  ),
                  GestureDetector(
                    onTap: () {
                      Toast.showSnackBar(context, "暂不支持");
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        globalLocalizations.login_forget_password,
                        style: TextStyle(color: designColors.blue_dark.auto(ref), decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
