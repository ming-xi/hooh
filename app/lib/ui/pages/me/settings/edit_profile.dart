import 'package:app/global.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/ui/pages/me/settings/edit_profile_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sprintf/sprintf.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final StateNotifierProvider<EditProfileScreenViewModel, EditProfileScreenModelState> provider = StateNotifierProvider((ref) {
    return EditProfileScreenViewModel(EditProfileScreenModelState.init(ref.read(globalUserInfoProvider)!.id));
  });

  EditProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    EditProfileScreenModelState modelState = ref.watch(widget.provider);
    EditProfileScreenViewModel model = ref.read(widget.provider.notifier);
    User user = ref.watch(globalUserInfoProvider)!;
    // User? user1=ref.watch(globalUserInfoProvider);
    // user1=null;
    // User user=user1!;
    return Scaffold(
      appBar: HoohAppBar(
        title: Text(globalLocalizations.me_profile_edit),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 36,
                ),
                HoohImage(
                  cornerRadius: 100,
                  imageUrl: user.avatarUrl!,
                  width: 128,
                  height: 128,
                  onPress: () {
                    changeAvatar(context, model);
                  },
                ),
                SizedBox(
                  height: 8,
                ),
                TextButton(
                  style: MainStyles.textButtonStyle(ref),
                  onPressed: () {
                    changeAvatar(context, model);
                  },
                  child: Text(
                    globalLocalizations.edit_profile_edit_avatar,
                    style:
                    TextStyle(fontSize: 14, color: designColors.blue_dark.auto(ref), fontWeight: FontWeight.normal, decoration: TextDecoration.underline),
                  ),
                ),
                SizedBox(
                  height: 36,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: designColors.light_02.auto(ref),
                ),
                buildTile(globalLocalizations.edit_profile_edit_name, onPress: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditNameScreen(name: user.name)));
                }),
                buildTile(globalLocalizations.edit_profile_edit_signature, onPress: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditSignatureScreen(signature: user.signature ?? "")));
                }),
                buildTile(globalLocalizations.edit_profile_edit_website, onPress: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditWebsiteScreen(website: user.website ?? "")));
                }),
              ],
            ),
          )
        ],
      ),
    );
  }

  void changeAvatar(BuildContext context, EditProfileScreenViewModel model) async {
    showSelectLocalImageActionSheet(
        context: context,
        cropRatio: 1,
        ref: ref,
        onSelected: (file) async {
          if (file == null) {
            return;
          }
          showHoohDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return LoadingDialog(LoadingDialogController());
              });
          await model.changeAvatar(file, (user, msg) {
            Navigator.of(context).pop();
            if (user != null) {
              ref.read(globalUserInfoProvider.state).state = user;
              showSnackBar(context, globalLocalizations.edit_profile_edit_success);
            } else {
              showSnackBar(context, msg!);
            }
          });
        });
  }

  Widget buildTile(String title, {Function()? onPress}) {
    TextStyle? titleTextStyle = TextStyle(
        fontSize: 14, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref));
    var titleWidget = Text(
      title,
      style: titleTextStyle,
    );
    return Ink(
      child: InkWell(
        onTap: onPress,
        child: Container(
          height: 48,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: designColors.light_02.auto(ref), width: 1))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Row(
                children: [
                  titleWidget,
                  const Spacer(),
                  HoohIcon(
                    "assets/images/icon_arrow_next_ios.svg",
                    width: 24,
                    height: 24,
                    color: designColors.light_06.auto(ref),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditNameScreen extends ConsumerStatefulWidget {
  final StateNotifierProvider<EditProfileScreenViewModel, EditProfileScreenModelState> provider = StateNotifierProvider((ref) {
    return EditProfileScreenViewModel(EditProfileScreenModelState.init(ref.read(globalUserInfoProvider)!.id));
  });
  final String name;

  EditNameScreen({
    required this.name,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _EditNameScreenState();
}

class _EditNameScreenState extends ConsumerState<EditNameScreen> {
  FocusNode node = FocusNode();
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.name;
  }

  @override
  Widget build(BuildContext context) {
    EditProfileScreenModelState modelState = ref.watch(widget.provider);
    EditProfileScreenViewModel model = ref.read(widget.provider.notifier);

    return Scaffold(
      appBar: HoohAppBar(
        title: Text(globalLocalizations.edit_profile_edit_name_title),
        actions: [
          IconButton(
              onPressed: modelState.error
                  ? null
                  : () {
                      hideKeyboard();
                      changeName(context, model);
                    },
              icon: HoohIcon(
                "assets/images/icon_ok.svg",
                width: 24,
                height: 24,
                color: designColors.dark_01.auto(ref),
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              controller: controller,
              focusNode: node,
              maxLength: 20,
              maxLengthEnforcement: MaxLengthEnforcement.none,
              style: RegisterStyles.inputTextStyle(ref),
              decoration: RegisterStyles.commonInputDecoration(
                globalLocalizations.edit_profile_edit_name_hint,
                ref,
                errorText: !modelState.error ? null : globalLocalizations.edit_profile_edit_name_helper,
                helperText: modelState.error ? null : globalLocalizations.edit_profile_edit_name_helper,
              ),
              onChanged: (text) {
                model.setErrorState(text.runes.length > 20);
              },
            ),
          ],
        ),
      ),
    );
  }

  void showChangeTooOftenDialog(BuildContext context, EditProfileScreenViewModel model) {
    model.getChangeNameLimit((days, msg) {
      if (days != null) {
        showHoohDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                content: Text(sprintf(globalLocalizations.edit_profile_edit_name_error_dialog_text, [days])),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(globalLocalizations.common_ok))
                ],
              );
            });
      } else {
        showCommonRequestErrorDialog(ref, context, msg);
      }
    });
  }

  void changeName(BuildContext context, EditProfileScreenViewModel model) {
    model.getChangeNameLimit((days, msg) {
      if (days != null) {
        showHoohDialog(
            context: context,
            barrierDismissible: false,
            builder: (popContext) {
              return AlertDialog(
                content: Text(sprintf(globalLocalizations.edit_profile_edit_name_confirm_dialog_text, [days])),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(popContext).pop();
                        showHoohDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return LoadingDialog(LoadingDialogController());
                            });
                        model.changeNickname(controller.text.trim(), (user, response) {
                          Navigator.of(context).pop();
                          if (user != null) {
                            ref.read(globalUserInfoProvider.state).state = user;
                            showSnackBar(context, globalLocalizations.edit_profile_edit_success);
                            Navigator.of(context, rootNavigator: true).pop();
                          } else {
                            if (response!.errorCode == Constants.EDIT_NAME_TOO_OFTEN) {
                              showChangeTooOftenDialog(context, model);
                            } else {
                              // showSnackBar(context, response!.message);
                              showCommonRequestErrorDialog(ref, context, response);
                            }
                          }
                        });
                      },
                      child: Text(globalLocalizations.common_confirm)),
                  TextButton(
                      onPressed: () {
                        Navigator.of(popContext).pop();
                      },
                      child: Text(globalLocalizations.common_cancel))
                ],
              );
            });
      } else {
        showCommonRequestErrorDialog(ref, context, msg);
      }
    });
  }
}

class EditSignatureScreen extends ConsumerStatefulWidget {
  final StateNotifierProvider<EditProfileScreenViewModel, EditProfileScreenModelState> provider = StateNotifierProvider((ref) {
    return EditProfileScreenViewModel(EditProfileScreenModelState.init(ref.read(globalUserInfoProvider)!.id));
  });
  final String signature;

  EditSignatureScreen({
    required this.signature,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _EditSignatureScreenState();
}

class _EditSignatureScreenState extends ConsumerState<EditSignatureScreen> {
  FocusNode node = FocusNode();
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.signature;
  }

  @override
  Widget build(BuildContext context) {
    EditProfileScreenModelState modelState = ref.watch(widget.provider);
    EditProfileScreenViewModel model = ref.read(widget.provider.notifier);

    return Scaffold(
      appBar: HoohAppBar(
        title: Text(globalLocalizations.edit_profile_edit_bio_title),
        actions: [
          IconButton(
              onPressed: modelState.error
                  ? null
                  : () {
                      hideKeyboard();
                      showHoohDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return LoadingDialog(LoadingDialogController());
                          });
                      model.changeSignature(controller.text.trim(), (user, error) {
                        Navigator.of(context).pop();
                        if (user != null) {
                          ref.read(globalUserInfoProvider.state).state = user;
                          showSnackBar(context, globalLocalizations.edit_profile_edit_success);
                          Navigator.of(context, rootNavigator: true).pop();
                        } else {
                          // showSnackBar(context, msg!);
                          showCommonRequestErrorDialog(ref, context, error!);
                        }
                      });
                    },
              icon: HoohIcon(
                "assets/images/icon_ok.svg",
                width: 24,
                height: 24,
                color: designColors.dark_01.auto(ref),
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              controller: controller,
              focusNode: node,
              maxLength: 200,
              maxLengthEnforcement: MaxLengthEnforcement.none,
              maxLines: 8,
              style: RegisterStyles.inputTextStyle(ref),
              decoration: RegisterStyles.commonInputDecoration(
                globalLocalizations.edit_profile_edit_bio_hint,
                ref,
                errorText: !modelState.error ? null : globalLocalizations.edit_profile_edit_bio_helper,
                helperText: modelState.error ? null : globalLocalizations.edit_profile_edit_bio_helper,
              ).copyWith(contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
              onChanged: (text) {
                model.setErrorState(text.runes.length > 200);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EditWebsiteScreen extends ConsumerStatefulWidget {
  final StateNotifierProvider<EditProfileScreenViewModel, EditProfileScreenModelState> provider = StateNotifierProvider((ref) {
    return EditProfileScreenViewModel(EditProfileScreenModelState.init(ref.read(globalUserInfoProvider)!.id));
  });
  final String website;

  EditWebsiteScreen({
    required this.website,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _EditWebsiteScreenState();
}

class _EditWebsiteScreenState extends ConsumerState<EditWebsiteScreen> {
  FocusNode node = FocusNode();
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.website;
  }

  @override
  Widget build(BuildContext context) {
    EditProfileScreenModelState modelState = ref.watch(widget.provider);
    EditProfileScreenViewModel model = ref.read(widget.provider.notifier);

    return Scaffold(
      appBar: HoohAppBar(
        title: Text(globalLocalizations.edit_profile_edit_website_title),
        actions: [
          IconButton(
              onPressed: modelState.error
                  ? null
                  : () {
                      hideKeyboard();
                      showHoohDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return LoadingDialog(LoadingDialogController());
                          });
                      model.changeWebsite(controller.text.trim(), (user, error) {
                        Navigator.of(context).pop();
                        if (user != null) {
                          ref.read(globalUserInfoProvider.state).state = user;
                          showSnackBar(context, globalLocalizations.edit_profile_edit_success);
                          Navigator.of(context, rootNavigator: true).pop();
                        } else {
                          // showSnackBar(context, msg!);
                          showCommonRequestErrorDialog(ref, context, error!);
                        }
                      });
                    },
              icon: HoohIcon(
                "assets/images/icon_ok.svg",
                width: 24,
                height: 24,
                color: designColors.dark_01.auto(ref),
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              controller: controller,
              focusNode: node,
              maxLength: 200,
              maxLengthEnforcement: MaxLengthEnforcement.none,
              style: RegisterStyles.inputTextStyle(ref),
              decoration: RegisterStyles.commonInputDecoration(
                globalLocalizations.edit_profile_edit_website_hint,
                ref,
                errorText: !modelState.error ? null : globalLocalizations.edit_profile_edit_website_helper,
                helperText: modelState.error ? null : globalLocalizations.edit_profile_edit_website_helper,
              ),
              onChanged: (text) {
                model.setErrorState(text.length > 200);
              },
            ),
          ],
        ),
      ),
    );
  }
}
