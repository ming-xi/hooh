import 'package:app/global.dart';
import 'package:app/ui/pages/user/register/bind_email_view_model.dart';
import 'package:app/ui/pages/user/register/change_email.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/pages/user/register/validate_code.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BindEmailScreen extends ConsumerStatefulWidget {
  ///从账号设置过来
  static const SCENE_VERIFY = 0;

  ///从修改邮箱过来
  static const SCENE_CHANGE = 1;

  ///从忘记密码过来
  static const SCENE_FORGET_PASSWORD = 2;
  final int scene;
  final StateNotifierProvider<BindEmailScreenViewModel, BindEmailScreenModelState> provider = StateNotifierProvider((ref) {
    return BindEmailScreenViewModel(BindEmailScreenModelState.init());
  });

  BindEmailScreen({
    required this.scene,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _BindEmailScreenState();
}

class _BindEmailScreenState extends ConsumerState<BindEmailScreen> {
  TextEditingController emailController = TextEditingController();
  FocusNode emailNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scene == BindEmailScreen.SCENE_VERIFY || widget.scene == BindEmailScreen.SCENE_FORGET_PASSWORD) {
        User? user = ref.read(globalUserInfoProvider);
        emailController.text = user?.email ?? "";
        BindEmailScreenViewModel model = ref.read(widget.provider.notifier);
        model.checkEmail(emailController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint("_BindEmailScreenState build");
    BindEmailScreenModelState modelState = ref.watch(widget.provider);
    BindEmailScreenViewModel model = ref.read(widget.provider.notifier);
    User? user = ref.watch(globalUserInfoProvider);
    BorderRadius radius = BorderRadius.all(Radius.circular(18.0));
    BorderSide borderSide = BorderSide(width: 1, color: designColors.light_02.auto(ref));
    String title;
    switch (widget.scene) {
      case BindEmailScreen.SCENE_FORGET_PASSWORD:
        {
          title = globalLocalizations.forget_password_title;
          break;
        }
      case BindEmailScreen.SCENE_CHANGE:
        {
          title = globalLocalizations.reset_email_title;
          break;
        }
      case BindEmailScreen.SCENE_VERIFY:
      default:
        {
          title = globalLocalizations.bind_email_title;
        }
    }
    bool inputEnabled = widget.scene == BindEmailScreen.SCENE_CHANGE || user == null;
    String buttonText = widget.scene != BindEmailScreen.SCENE_CHANGE ? globalLocalizations.bind_email_button : globalLocalizations.reset_email_button;
    bool smallTextVisible = widget.scene == BindEmailScreen.SCENE_VERIFY;
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
                  title,
                  style: RegisterStyles.titleTextStyle(ref),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: emailController,
              focusNode: emailNode,
              enabled: inputEnabled,
              style: RegisterStyles.inputTextStyle(ref).copyWith(color: inputEnabled ? null : designColors.light_06.auto(ref)),
              decoration: RegisterStyles.commonInputDecoration(globalLocalizations.bind_email_hint, ref, errorText: modelState.errorText).copyWith(
                  disabledBorder: OutlineInputBorder(borderSide: borderSide.copyWith(color: designColors.dark_03.auto(ref)), borderRadius: radius),
                  border: OutlineInputBorder(
                    borderSide: borderSide,
                    borderRadius: radius,
                  ),
                  filled: !inputEnabled,
                  fillColor: designColors.light_02.auto(ref),
                  prefixIcon: SizedBox(
                    width: 36,
                    child: Center(
                      child: HoohIcon(
                        "assets/images/icon_forget_password_email.svg",
                        color: designColors.dark_03.auto(ref),
                        width: 24,
                      ),
                    ),
                  )),
              onChanged: (text) {
                model.checkEmail(text);
              },
            ),
            Spacer(),
            Visibility(
                visible: kDebugMode,
                child: TextButton(
                  style: RegisterStyles.blackButtonStyle(ref),
                  onPressed: () {
                    if (kDebugMode) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: Text("Fake verify"),
                )),
            SizedBox(
              height: 16,
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
                      var onFailed = (error) {
                        Navigator.of(context).pop();
                        if (error.errorCode == Constants.EMAIL_ALREADY_VALIDATED) {
                          showEmailUsedDialog();
                        }
                      };
                      if (widget.scene == BindEmailScreen.SCENE_FORGET_PASSWORD) {
                        model.requestResetPasswordValidationCode(context, emailController.text, onSuccess: () {
                          //dialog
                          Navigator.of(context).pop();
                          onValidationCodeReceived(ValidateCodeScreen.SCENE_RESET_PASSWORD);
                        }, onFailed: onFailed);
                      } else {
                        model.requestBindEmailValidationCode(context, emailController.text, onSuccess: () {
                          //dialog
                          Navigator.of(context).pop();
                          onValidationCodeReceived(ValidateCodeScreen.SCENE_BIND_EMAIL);
                        }, onFailed: onFailed);
                      }
                    },
              child: Text(buttonText),
            ),
            Visibility(
              visible: smallTextVisible,
              child: MainStyles.smallTextButton(
                  ref: ref,
                  context: context,
                  text: globalLocalizations.bind_email_change,
                  onClick: () {
                    goToChangeEmailScreen();
                  }),
            ),
            Spacer()
          ],
        ),
      ),
    );
  }

  void onValidationCodeReceived(int scene) {
    Navigator.push<bool>(
            context,
            MaterialPageRoute(
                builder: (context) => ValidateCodeScreen(scene: scene, target: emailController.text, type: RequestValidationCodeResponse.TYPE_EMAIL)))
        .then((result) {
      debugPrint("bind email result=$result");
      if (result != null && result) {
        Navigator.of(context).pop(true);
      }
    });
  }

  void showEmailUsedDialog() {
    RegisterStyles.showRegisterStyleDialog(
        ref: ref,
        context: context,
        title: globalLocalizations.bind_email_dialog_title,
        content: globalLocalizations.bind_email_dialog_content,
        cancelText: globalLocalizations.common_cancel,
        okText: globalLocalizations.common_ok,
        onOk: () {
          goToChangeEmailScreen();
        });
  }

  void goToChangeEmailScreen() {
    Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => ChangeEmailScreen())).then((result) {
      if (result != null && result) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }
}
