import 'dart:convert';

import 'package:app/global.dart';
import 'package:app/ui/pages/user/register/login.dart';
import 'package:app/ui/pages/user/register/register_view_model.dart';
import 'package:app/ui/pages/user/register/set_badge.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final StateNotifierProvider<RegisterViewModel, RegisterModelState> provider = StateNotifierProvider((ref) {
    return RegisterViewModel(RegisterModelState.init());
  });

  RegisterScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // final TapGestureRecognizer _tapGestureRecognizer = TapGestureRecognizer();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  FocusNode usernameNode = FocusNode();
  FocusNode emailNode = FocusNode();
  FocusNode passwordNode = FocusNode();
  FocusNode passwordConfirmNode = FocusNode();

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   _tapGestureRecognizer.dispose();
  //   // debugPrint("sign up dispose");
  // }

  @override
  Widget build(BuildContext context) {
    RegisterModelState modelState = ref.watch(widget.provider);
    RegisterViewModel model = ref.read(widget.provider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              style: RegisterStyles.appbarTextButtonStyle(ref),
              child: Text(
                globalLocalizations.login_login,
              )),
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
                    children: [
                      Text(
                        globalLocalizations.register_welcome,
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
                    decoration: RegisterStyles.commonInputDecoration(globalLocalizations.login_username, ref,
                        helperText: globalLocalizations.register_username_hint, errorText: modelState.usernameErrorText),
                    onChanged: (text) {
                      model.checkAll(text, emailController.text, passwordController.text, passwordConfirmController.text);
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: emailController,
                    focusNode: emailNode,
                    style: RegisterStyles.inputTextStyle(ref),
                    decoration: RegisterStyles.commonInputDecoration(globalLocalizations.register_email, ref, errorText: modelState.emailErrorText),
                    onChanged: (text) {
                      model.checkAll(usernameController.text, text, passwordController.text, passwordConfirmController.text);
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: passwordController,
                    focusNode: passwordNode,
                    style: RegisterStyles.inputTextStyle(ref),
                    decoration: RegisterStyles.passwordInputDecoration(globalLocalizations.login_password, ref,
                        helperText: globalLocalizations.register_password_hint,
                        errorText: modelState.passwordErrorText,
                        passwordVisible: modelState.passwordVisible, onTogglePasswordVisible: () {
                      model.togglePasswordVisible();
                    }),
                    obscureText: !modelState.passwordVisible,
                    onChanged: (text) {
                      model.checkAll(usernameController.text, emailController.text, text, passwordConfirmController.text);
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    style: RegisterStyles.inputTextStyle(ref),
                    controller: passwordConfirmController,
                    focusNode: passwordConfirmNode,
                    decoration: RegisterStyles.passwordInputDecoration(globalLocalizations.register_confirm_password, ref,
                        errorText: modelState.confirmPasswordErrorText, passwordVisible: modelState.confirmPasswordVisible, onTogglePasswordVisible: () {
                      model.toggleConfirmPasswordVisible();
                    }),
                    obscureText: !modelState.confirmPasswordVisible,
                    onChanged: (text) {
                      model.checkAll(usernameController.text, emailController.text, passwordController.text, text);
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextButton(
                    style: RegisterStyles.blackButtonStyle(ref),
                    onPressed: !modelState.registerButtonEnabled
                        ? null
                        : () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return LoadingDialog(LoadingDialogController());
                                });
                            model.register(context, usernameController.text, passwordController.text, emailController.text, onSuccess: (user) {
                              ref.read(globalUserInfoProvider.state).state = user;
                              preferences.putString(Preferences.KEY_USER_INFO, json.encode(user.toJson()));
                              Navigator.of(context).pop();
                              // Toast.showSnackBar(context, "注册成功");
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => SetBadgeScreen()),
                                (route) => false,
                              );
                            }, onFailed: (error) {
                              Navigator.of(context).pop();
                              if (error.errorCode == Constants.USERNAME_ALREADY_REGISTERED) {
                                usernameNode.requestFocus();
                              } else if (error.errorCode == Constants.EMAIL_ALREADY_VALIDATED) {
                                emailNode.requestFocus();
                              }
                            });
                          },
                    child: Text(globalLocalizations.register_agree),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Builder(builder: (context) {
                    TextStyle defaultTextStyle = TextStyle(
                      color: designColors.dark_01.auto(ref),
                      fontFamily: 'Linotte',
                      fontSize: 12,
                    );
                    TextStyle highlightedStyle = TextStyle(
                      color: designColors.blue_dark.auto(ref),
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                      fontFamily: 'Linotte',
                    );
                    String template = globalLocalizations.register_read_agreements;
                    String userAgreement = globalLocalizations.register_user_agreement;
                    String privacyPolicy = globalLocalizations.register_privacy_policy;
                    return HoohLocalizedRichText(
                        text: template,
                        keys: [
                          HoohLocalizedTextKey(
                              key: "%1\$s",
                              text: userAgreement,
                              style: highlightedStyle,
                              onTap: () {
                                openLink(context, 'https://www.baidu.com', title: userAgreement);
                              }),
                          HoohLocalizedTextKey(
                              key: "%2\$s",
                              text: privacyPolicy,
                              style: highlightedStyle,
                              onTap: () {
                                openLink(context, 'https://www.163.com', title: privacyPolicy);
                              }),
                        ],
                        defaultTextStyle: defaultTextStyle);
                    // return HoohLocalizedRichText(
                    //     template: template,
                    //     keys: [
                    //       HoohLocalizedKey(
                    //           key: "%1\$s",
                    //           text: userAgreement,
                    //           style: highlightedStyle,
                    //           onTap: (text) {
                    //             Navigator.push(
                    //                 context, MaterialPageRoute(builder: (context) => const WebViewScreen('User Agreement', 'https://www.baidu.com')));
                    //           }),
                    //       HoohLocalizedKey(
                    //           key: "%2\$s",
                    //           text: privacyPolicy,
                    //           style: highlightedStyle,
                    //           onTap: (text) {
                    //             Navigator.push(context, MaterialPageRoute(builder: (context) => const WebViewScreen('Privacy Policy', 'https://www.163.com')));
                    //           }),
                    //     ],
                    //     defaultTextStyle: defaultTextStyle);
                  })
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
