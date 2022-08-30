import 'package:app/global.dart';
import 'package:app/ui/pages/user/register/reset_password.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/pages/user/register/validate_code_view_model.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/ui/widgets/verification_code_input.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sprintf/sprintf.dart';

class ValidateCodeScreen extends ConsumerStatefulWidget {
  static const SCENE_BIND_EMAIL = 0;
  static const SCENE_RESET_PASSWORD = 1;

  late final StateNotifierProvider<ValidateCodeScreenViewModel, ValidateCodeScreenModelState> provider;
  final int scene;

  ValidateCodeScreen({
    required this.scene,
    required String target,
    required int type,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return ValidateCodeScreenViewModel(ValidateCodeScreenModelState.init(target, type, scene));
    });
  }

  @override
  ConsumerState createState() => _ValidateCodeScreenState();
}

class _ValidateCodeScreenState extends ConsumerState<ValidateCodeScreen> {
  TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ValidateCodeScreenModelState modelState = ref.watch(widget.provider);
    ValidateCodeScreenViewModel model = ref.read(widget.provider.notifier);
    InputDecoration decoration = buildDecoration();

    return Scaffold(
      appBar: HoohAppBar(
        // leading: Text("test"),
        title: const Text(""),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        globalLocalizations.validate_code_title,
                        style: RegisterStyles.titleTextStyle(ref),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sprintf(globalLocalizations.validate_code_subtitle, [modelState.target]),
                          style: TextStyle(color: designColors.dark_03.auto(ref)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  VerificationCodeInput2(
                      textEditingController: codeController,
                      onComplete: (code) {
                        model.validationCode(context, code, onSuccess: (data) {
                          if (widget.scene == ValidateCodeScreen.SCENE_BIND_EMAIL) {
                            ref.read(globalUserInfoProvider.state).state = data;
                            showHoohDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (popContext) {
                                  return AlertDialog(
                                    content: Text(globalLocalizations.validate_code_success),
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
                          } else if (widget.scene == ValidateCodeScreen.SCENE_RESET_PASSWORD) {
                            Navigator.push<bool>(
                                    context, MaterialPageRoute(builder: (context) => ResetPasswordScreen(token: (data as ValidateCodeResponse).token)))
                                .then((result) {
                              debugPrint("validate code result=$result");
                              if (result != null && result) {
                                Navigator.of(context, rootNavigator: true).pop(true);
                              }
                            });
                          }
                        }, onFailed: () {
                          setState(() {
                            codeController.text = "";
                          });
                        });
                      }),

                  // VerificationCodeInput(
                  //     controller: verificationCodeInputController,
                  //     textStyle: TextStyle(fontSize: 20.0, color: designColors.dark_01.auto(ref)),
                  //     inputDecoration: decoration,
                  //     onComplete: (code) {
                  //       model.validationCode(context, code, onSuccess: (data) {
                  //         if (widget.scene == ValidateCodeScreen.SCENE_BIND_EMAIL) {
                  //           ref.read(globalUserInfoProvider.state).state = data;
                  //           showHoohDialog(
                  //               context: context,
                  //               barrierDismissible: false,
                  //               builder: (popContext) {
                  //                 return AlertDialog(
                  //                   content: Text(globalLocalizations.validate_code_success),
                  //                   actions: [
                  //                     TextButton(
                  //                         onPressed: () {
                  //                           Navigator.of(context).pop();
                  //                         },
                  //                         child: Text(globalLocalizations.common_ok))
                  //                   ],
                  //                 );
                  //               }).then((_) {
                  //             Navigator.of(context).pop(true);
                  //           });
                  //         } else if (widget.scene == ValidateCodeScreen.SCENE_RESET_PASSWORD) {
                  //           Navigator.push<bool>(
                  //                   context, MaterialPageRoute(builder: (context) => ResetPasswordScreen(token: (data as ValidateCodeResponse).token)))
                  //               .then((result) {
                  //             debugPrint("validate code result=$result");
                  //             if (result != null && result) {
                  //               Navigator.of(context, rootNavigator: true).pop(true);
                  //             }
                  //           });
                  //         }
                  //       }, onFailed: () {
                  //         verificationCodeInputController.clearAll();
                  //       });
                  //     }),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Spacer(),
                      MainStyles.smallTextButton(
                          ref: ref,
                          context: context,
                          enabled: modelState.buttonEnabled,
                          text: modelState.buttonText,
                          textStyle: TextStyle(
                              color: modelState.buttonEnabled ? designColors.blue_dark.auto(ref) : designColors.dark_03.auto(ref),
                              fontWeight: FontWeight.normal,
                              fontSize: 14),
                          onClick: () {
                            showHoohDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return LoadingDialog(LoadingDialogController());
                                });
                            model.resendCode(context, modelState.target, onSuccess: () {
                              Navigator.of(context).pop();
                            }, onFailed: () {
                              Navigator.of(context).pop();
                            });
                          })
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: modelState.errorText != null
                            ? Text(
                                modelState.errorText!,
                                style: TextStyle(color: designColors.orange.auto(ref)),
                              )
                            : Text(
                                globalLocalizations.validate_code_helper,
                                style: TextStyle(color: designColors.feiyu_blue.auto(ref)),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  InputDecoration buildDecoration() {
    ValidateCodeScreenModelState modelState = ref.watch(widget.provider);
    BorderRadius radius = BorderRadius.all(Radius.circular(18.0));
    BorderSide borderSide = BorderSide(width: 1, color: designColors.light_02.auto(ref));
    Color errorColor = designColors.orange.auto(ref);
    Color disabledColor = designColors.light_00.auto(ref);
    Color focusedColor = designColors.feiyu_blue.auto(ref);
    InputDecoration decoration = InputDecoration(
        focusedErrorBorder: OutlineInputBorder(borderSide: borderSide.copyWith(color: focusedColor), borderRadius: radius),
        errorBorder: OutlineInputBorder(borderSide: borderSide.copyWith(color: errorColor), borderRadius: radius),
        disabledBorder: OutlineInputBorder(borderSide: borderSide.copyWith(color: disabledColor), borderRadius: radius),
        focusedBorder: OutlineInputBorder(borderSide: borderSide.copyWith(color: focusedColor), borderRadius: radius),
        enabledBorder: OutlineInputBorder(borderSide: borderSide, borderRadius: radius),
        errorText: modelState.errorText != null ? "" : null);
    return decoration;
  }
}
