import 'package:app/global.dart';
import 'package:app/ui/pages/user/register/reset_password_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<ResetPasswordScreenViewModel, ResetPasswordScreenModelState> provider;

  ResetPasswordScreen({
    required String token,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return ResetPasswordScreenViewModel(ResetPasswordScreenModelState.init(token));
    });
  }

  @override
  ConsumerState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  FocusNode passwordNode = FocusNode();
  TextEditingController confirmPasswordController = TextEditingController();
  FocusNode confirmPasswordNode = FocusNode();
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    ResetPasswordScreenModelState modelState = ref.watch(widget.provider);
    ResetPasswordScreenViewModel model = ref.read(widget.provider.notifier);
    return Scaffold(
      appBar: HoohAppBar(
        // leading: Text("test"),
        title: const Text(""),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                Text(
                  globalLocalizations.reset_password_title,
                  style: RegisterStyles.titleTextStyle(ref),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: passwordController,
              focusNode: passwordNode,
              onChanged: (text) {
                model.checkAll(text, confirmPasswordController.text);
              },
              style: RegisterStyles.inputTextStyle(ref),
              decoration: RegisterStyles.passwordInputDecoration(globalLocalizations.login_password, ref,
                  passwordVisible: passwordVisible, errorText: modelState.passwordErrorText, onTogglePasswordVisible: () {
                setState(() {
                  passwordVisible = !passwordVisible;
                });
              }),
              obscureText: !passwordVisible,
            ),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: confirmPasswordController,
              focusNode: confirmPasswordNode,
              onChanged: (text) {
                model.checkAll(passwordController.text, text);
              },
              style: RegisterStyles.inputTextStyle(ref),
              decoration: RegisterStyles.passwordInputDecoration(globalLocalizations.register_confirm_password, ref,
                  passwordVisible: confirmPasswordVisible, errorText: modelState.confirmPasswordErrorText, onTogglePasswordVisible: () {
                setState(() {
                  confirmPasswordVisible = !confirmPasswordVisible;
                });
              }),
              obscureText: !confirmPasswordVisible,
            ),
            SizedBox(
              height: 48,
            ),
            TextButton(
              style: RegisterStyles.blackButtonStyle(ref),
              onPressed: !modelState.buttonEnabled
                  ? null
                  : () {
                showHoohDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return LoadingDialog(LoadingDialogController());
                          });
                      model.resetPassword(context, passwordController.text, onSuccess: (user) {
                        ref.read(globalUserInfoProvider.state).state = user;
                        //dialog
                        Navigator.of(context).pop();
                        showHoohDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (popContext) {
                              return AlertDialog(
                                content: Text(globalLocalizations.reset_password_success),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(globalLocalizations.common_ok))
                                ],
                              );
                            }).then((_) {
                          Navigator.of(context).pop(true);
                        });
                      }, onFailed: (error) {
                        Navigator.of(context).pop();
                      });
                    },
              child: Text(globalLocalizations.reset_password_button),
            ),
          ],
        ),
      ),
    );
  }
}
