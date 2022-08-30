import 'dart:convert';
import 'dart:typed_data';

import 'package:app/global.dart';
import 'package:app/launcher.dart';
import 'package:app/ui/pages/user/register/bind_email.dart';
import 'package:app/ui/pages/user/register/set_badge_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sprintf/sprintf.dart';

class SetBadgeScreen extends ConsumerStatefulWidget {
  static const SCENE_REGISTER = 0;
  static const SCENE_CHANGE = 1;

  late final StateNotifierProvider<SetBadgeScreenViewModel, SetBadgeScreenModelState> provider;
  final int scene;

  SetBadgeScreen({
    required this.scene,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      String? userId = ref.watch(globalUserInfoProvider.state).state?.id;
      return SetBadgeScreenViewModel(userId, SetBadgeScreenModelState.init());
    });
  }

  @override
  ConsumerState createState() => _SetBadgeScreenState();
}

class _SetBadgeScreenState extends ConsumerState<SetBadgeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getRandomBadge();
    });
  }

  @override
  Widget build(BuildContext context) {
    SetBadgeScreenModelState modelState = ref.watch(widget.provider);
    SetBadgeScreenViewModel model = ref.read(widget.provider.notifier);

    List<TextButton> actions = [
      TextButton(
          onPressed: () async {
            if (widget.scene == SetBadgeScreen.SCENE_CHANGE) {
              FeeInfoResponse response = await network.getFeeInfo();
              bool? result = await showHoohDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (popContext) {
                    return AlertDialog(
                      title: Text(globalLocalizations.common_confirm),
                      content: Text(sprintf(globalLocalizations.publish_post_cost_dialog_content, [formatCurrency(response.createBadge)])),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(popContext).pop(false);
                            },
                            child: Text(globalLocalizations.common_cancel)),
                        TextButton(
                            onPressed: () {
                              Navigator.of(popContext).pop(true);
                            },
                            child: Text(globalLocalizations.common_ok)),
                      ],
                    );
                  });
              if (!result!) {
                return;
              }
            }
            showHoohDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return LoadingDialog(LoadingDialogController());
                });
            model.changeUserBadge().then((result) {
              Navigator.pop(context);
              if (result is HoohApiErrorResponse) {
                if (result.errorCode == Constants.INSUFFICIENT_FUNDS) {
                  List<String> split = result.message.split("\n");
                  showNotEnoughOreDialog(ref: ref, context: context, needed: int.tryParse(split[0])!, current: int.tryParse(split[1])!);
                } else {
                  showCommonRequestErrorDialog(ref, context, result);
                }
              } else if (result is bool && !result) {
                showHoohDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text(globalLocalizations.set_badge_uploading_failed),
                      );
                    });
              } else if (result is User) {
                ref.read(globalUserInfoProvider.state).state = result;
                preferences.putString(Preferences.KEY_USER_INFO, json.encode(result.toJson()));
                // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
                // popToHomeScreen(context);
                if (widget.scene == SetBadgeScreen.SCENE_REGISTER) {
                  if (result.emailValidated ?? false) {
                    Navigator.of(context).pop(true);
                  } else {
                    showVerifyEmailDialog();
                  }
                } else {
                  Navigator.of(context).pop(true);
                }
              }
            });
          },
          style: RegisterStyles.appbarTextButtonStyle(ref),
          child: Text(
            globalLocalizations.common_ok,
          )),
      // Icon(
      //     Icons.more_vert
      // ),
    ];
    if (FlavorConfig.instance.variables[Launcher.KEY_ADMIN_MODE]) {
      actions.insert(
          0,
          TextButton(
              style: RegisterStyles.appbarTextButtonStyle(ref),
              onPressed: () {
                model.toggleOriginalColor();
              },
              child: Text(
                modelState.originalColor ? "显示变色" : "显示原颜色",
              )));
    }
    List<Uint8List> imageLayerBytes =
        modelState.layers.map((e) => model.getImageBytesWithHue(e.bytes, double.tryParse(e.template.hue) ?? 0, modelState.originalColor)).toList();
    // var oldColumn = Column(
    //   mainAxisSize: MainAxisSize.max,
    //   crossAxisAlignment: CrossAxisAlignment.center,
    //   children: [
    //     Row(
    //       mainAxisSize: MainAxisSize.max,
    //       children: [
    //         Padding(
    //           padding: const EdgeInsets.all(20.0),
    //           child: Text(
    //             "Setting your social icon",
    //             style: RegisterStyles.titleTextStyle(ref),
    //           ),
    //         )
    //       ],
    //     ),
    //     Row(
    //       mainAxisSize: MainAxisSize.max,
    //       children: [
    //         Expanded(
    //           child: Padding(
    //             padding: const EdgeInsets.symmetric(horizontal: 20.0),
    //             child: Text(
    //               "After following to each other, you can get each other's social icon. The social icon will be record of paying attention to history",
    //               style: RegisterStyles.titleTextStyle(ref).copyWith(fontSize: 14),
    //             ),
    //           ),
    //         )
    //       ],
    //     ),
    //     SizedBox(
    //       height: 16,
    //     ),
    //     SizedBox(
    //       width: 160,
    //       height: 180,
    //       child: Stack(
    //           children: imageLayerBytes.map((e) {
    //         return Image.memory(
    //           // getImageBytes(e.bytes, e.template.hue, modelState.originalColor),
    //           e,
    //           gaplessPlayback: true,
    //           fit: BoxFit.fill,
    //           filterQuality: FilterQuality.none,
    //           width: 160,
    //           height: 180,
    //         );
    //       }).toList()),
    //     ),
    //     SizedBox(
    //       height: 24,
    //     ),
    //     Row(
    //       mainAxisSize: MainAxisSize.max,
    //       children: [
    //         Expanded(
    //           child: TextButton.icon(
    //             style: RegisterStyles.blueButtonStyle(ref).copyWith(
    //                 shape: MaterialStateProperty.all(const RoundedRectangleBorder(
    //               borderRadius: BorderRadius.only(topRight: Radius.circular(22.0), bottomRight: Radius.circular(22.0)),
    //             ))),
    //             label: Text(globalLocalizations.set_badge_edit),
    //             icon: HoohIcon('assets/images/magic.svg', height: 36, width: 36),
    //             onPressed: () {},
    //           ),
    //         ),
    //         SizedBox(
    //           width: 16,
    //         ),
    //         Expanded(
    //           child: TextButton.icon(
    //             style: RegisterStyles.blueButtonStyle(ref).copyWith(
    //                 shape: MaterialStateProperty.all(const RoundedRectangleBorder(
    //               borderRadius: BorderRadius.only(topLeft: Radius.circular(22.0), bottomLeft: Radius.circular(22.0)),
    //             ))),
    //             label: Text(globalLocalizations.set_badge_change),
    //             icon: HoohIcon('assets/images/shuffle.svg', height: 36, width: 36),
    //             onPressed: () {
    //               String? userId = ref.read(globalUserInfoProvider.state).state?.id;
    //               model.getRandomBadge(userId!);
    //             },
    //           ),
    //         ),
    //       ],
    //     ),
    //     Expanded(
    //       child: Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 20.0),
    //         child: Center(
    //           child: RegisterStyles.rainbowButton(ref,
    //               icon: Text(globalLocalizations.set_badge_create_new), label: HoohIcon('assets/images/arrow_right_blue.svg', height: 24, width: 24), onPress: () {
    //             Navigator.push(
    //                 context,
    //                 MaterialPageRoute(
    //                     builder: (context) => DrawBadgeScreen(
    //                           imageLayerBytes: imageLayerBytes,
    //                         )));
    //           }),
    //         ),
    //       ),
    //     ),
    //   ],
    // );
    Widget newColumn = Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                globalLocalizations.set_badge_title,
                style: RegisterStyles.titleTextStyle(ref),
              ),
            )
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  globalLocalizations.set_badge_description,
                  style: RegisterStyles.titleTextStyle(ref).copyWith(fontSize: 14),
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Spacer(),
        SizedBox(
          width: 160,
          height: 180,
          child: Stack(
              children: imageLayerBytes.map((e) {
            return Image.memory(
              // getImageBytes(e.bytes, e.template.hue, modelState.originalColor),
              e,
              gaplessPlayback: true,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
              width: 160,
              height: 180,
            );
          }).toList()),
        ),
        Spacer(),
        SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Center(
            child: TextButton.icon(
              style: RegisterStyles.blueButtonStyle(ref).copyWith(
                  shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(22)),
              ))),
              label: Text(globalLocalizations.set_badge_change),
              icon: HoohIcon('assets/images/shuffle.svg', height: 36, width: 36),
              onPressed: () {
                SetBadgeScreenModelState modelState = ref.watch(widget.provider);
                SetBadgeScreenViewModel model = ref.read(widget.provider.notifier);
                if (!(preferences.getBool(Preferences.KEY_CHANGE_BADGE_DIALOG_CHECKED) ?? false)) {
                  showChangeBadgeDialog();
                } else {
                  getRandomBadge();
                }
              },
            ),
          ),
        ),
        SizedBox(
          height: 24,
        ),
      ],
    );
    Scaffold scaffold = Scaffold(
      appBar: HoohAppBar(
        hoohLeading: null,
        automaticallyImplyLeading: widget.scene != SetBadgeScreen.SCENE_REGISTER,
        actions: actions,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: SafeArea(child: newColumn),
          )
        ],
      ),
    );
    if (widget.scene == SetBadgeScreen.SCENE_REGISTER) {
      return WillPopScope(
        onWillPop: () => Future.value(false),
        child: scaffold,
      );
    } else {
      return scaffold;
    }
  }

  void showVerifyEmailDialog() {
    RegisterStyles.showRegisterStyleDialog(
        ref: ref,
        context: context,
        barrierDismissible: false,
        title: globalLocalizations.set_badge_verify_email_dialog_title,
        content: globalLocalizations.set_badge_verify_email_dialog_content,
        okText: globalLocalizations.account_verify,
        cancelText: globalLocalizations.set_badge_verify_email_dialog_later,
        onOk: () {
          Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => BindEmailScreen(scene: BindEmailScreen.SCENE_VERIFY))).then((result) {
            if (result != null && result) {
              Navigator.of(context, rootNavigator: true).pop(true);
            } else {
              showVerifyEmailDialog();
            }
          });
        },
        onCancel: () {
          Navigator.of(context).pop(true);
        });
  }

  void showChangeBadgeDialog() {
    showHoohDialog(
        context: context,
        barrierDismissible: false,
        builder: (popContext) {
          return Consumer(
            builder: (consumerContext, ref, child) {
              SetBadgeScreenModelState modelState = ref.watch(widget.provider);
              SetBadgeScreenViewModel model = ref.read(widget.provider.notifier);
              List<TextButton> buttons = [];
              buttons.add(TextButton(
                style: RegisterStyles.blackOutlineButtonStyle(ref),
                onPressed: () {
                  preferences.putBool(Preferences.KEY_CHANGE_BADGE_DIALOG_CHECKED, modelState.dialogCheckBoxChecked);
                  Navigator.of(context).pop();
                  getRandomBadge();
                },
                child: Text(globalLocalizations.common_yes),
              ));
              buttons.add(TextButton(
                style: RegisterStyles.blackButtonStyle(ref),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(globalLocalizations.common_no),
              ));
              return AlertDialog(
                insetPadding: EdgeInsets.all(20),
                title: Text(globalLocalizations.common_confirm),
                content: SizedBox(
                  height: 220,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: Text(globalLocalizations.set_badge_change_dialog_content)),
                      Row(
                        children: [
                          SizedBox(
                            width: 4,
                          ),
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: modelState.dialogCheckBoxChecked,
                              onChanged: (value) {
                                debugPrint("onChanged value=$value");
                                model.setDialogCheckBoxChecked(value!);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            globalLocalizations.templates_don_t_prompt_next_time,
                            style: TextStyle(color: designColors.dark_01.auto(ref), fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: buttons
                            .map((e) => [
                                  Expanded(child: e),
                                  SizedBox(
                                    width: 12,
                                  )
                                ])
                            .expand((element) => element)
                            .toList()
                          ..removeLast(),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  void getRandomBadge() {
    SetBadgeScreenModelState modelState = ref.watch(widget.provider);
    SetBadgeScreenViewModel model = ref.read(widget.provider.notifier);
    showHoohDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return LoadingDialog(LoadingDialogController());
        });
    String? userId = ref.read(globalUserInfoProvider.state).state?.id;
    model.getRandomBadge(userId!, callback: () {
      Navigator.of(context).pop();
    });
  }
}
