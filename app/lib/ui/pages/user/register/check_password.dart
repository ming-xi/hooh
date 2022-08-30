import 'package:app/global.dart';
import 'package:app/ui/pages/user/register/bind_email.dart';
import 'package:app/ui/pages/user/register/check_password_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/pages/user/register/validate_code.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CheckPasswordScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<CheckPasswordScreenViewModel, CheckPasswordScreenModelState> provider;

  CheckPasswordScreen({
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return CheckPasswordScreenViewModel(CheckPasswordScreenModelState.init(ref.read(globalUserInfoProvider)!.username!));
    });
  }

  @override
  ConsumerState createState() => _CheckPasswordScreenState();
}

class _CheckPasswordScreenState extends ConsumerState<CheckPasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  FocusNode passwordNode = FocusNode();
  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    CheckPasswordScreenModelState modelState = ref.watch(widget.provider);
    CheckPasswordScreenViewModel model = ref.read(widget.provider.notifier);
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
                  globalLocalizations.check_password_title,
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
                model.updateButtonState(text.isNotEmpty);
              },
              style: RegisterStyles.inputTextStyle(ref),
              decoration: RegisterStyles.passwordInputDecoration(globalLocalizations.login_password, ref,
                  passwordVisible: passwordVisible, errorText: modelState.errorText, onTogglePasswordVisible: () {
                setState(() {
                  passwordVisible = !passwordVisible;
                });
              }),
              obscureText: !passwordVisible,
            ),
            Spacer(),
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
                      model.checkPassword(context, passwordController.text, onSuccess: () {
                        //dialog
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(true);
                      }, onFailed: (error) {
                        Navigator.of(context).pop();
                      });
                    },
              child: Text(globalLocalizations.change_email_button),
            ),
            MainStyles.smallTextButton(
                ref: ref,
                context: context,
                text: globalLocalizations.login_forget_password,
                onClick: () {
                  Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BindEmailScreen(
                                scene: BindEmailScreen.SCENE_FORGET_PASSWORD,
                              ))).then((result) {
                    debugPrint("check password result=$result");
                    if (result != null && result) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  });
                }),
            Spacer()
          ],
        ),
      ),
    );
  }
}
