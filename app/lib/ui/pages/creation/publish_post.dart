import 'package:app/global.dart';
import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/ui/pages/creation/publish_post_view_model.dart';
import 'package:app/ui/pages/creation/select_topic.dart';
import 'package:app/ui/pages/home/feeds.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/home/home_view_model.dart';
import 'package:app/ui/pages/home/input.dart';
import 'package:app/ui/pages/home/input_view_model.dart';
import 'package:app/ui/pages/user/register/start.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/ui/widgets/template_compose_view.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sprintf/sprintf.dart';

class PublishPostScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<PublishPostScreenViewModel, PublishPostScreenModelState> provider;

  PublishPostScreen({
    required PostImageSetting setting,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return PublishPostScreenViewModel(PublishPostScreenModelState.init(setting));
    });
  }

  @override
  ConsumerState createState() => _PublishPostScreenState();
}

class _PublishPostScreenState extends ConsumerState<PublishPostScreen> {
  String? joinWaitingListFee;

  @override
  void initState() {
    super.initState();
    network.getFeeInfo().then((response) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          joinWaitingListFee = formatCurrency(response.joinWaitingList);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    PublishPostScreenViewModel model = ref.read(widget.provider.notifier);
    PublishPostScreenModelState modelState = ref.watch(widget.provider);
    TemplateViewSetting viewSetting = TemplateView.generateViewSetting(TemplateView.SCENE_PUBLISH_POST_PREVIEW);
    double screenWidth = MediaQuery.of(context).size.width;
    TextStyle bottomTextStyle = TextStyle(color: designColors.light_06.auto(ref), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Linotte');
    return Scaffold(
      appBar: HoohAppBar(
        title: Text(globalLocalizations.common_post),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: SizedBox.square(
                          dimension: 128,
                          child: TemplateView(modelState.setting, viewSetting: viewSetting, scale: 128 / screenWidth, radius: 20, onPressBody: () {
                            showHoohDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: EdgeInsets.zero,
                                      child: SizedBox.square(
                                        dimension: screenWidth,
                                        child: TemplateView(
                                          modelState.setting,
                                          viewSetting: viewSetting,
                                          radius: 0,
                                        ),
                                      ));
                                });
                          }),
                        ),
                      ),
                    ],
                  ),
                  MainStyles.buildListDivider(ref),
                  buildTags(modelState.tags),
                  MainStyles.buildListDivider(ref),
                  MainStyles.buildListTile(ref, globalLocalizations.publish_post_download,
                      tailWidget: Switch(
                          value: modelState.allowDownload,
                          onChanged: (newState) {
                            model.setAllowDownload(newState);
                          }), onPress: () {
                        model.setAllowDownload(!modelState.allowDownload);
                      }),
                  MainStyles.buildListTile(ref, globalLocalizations.publish_post_private,
                      tailWidget: Switch(
                          value: modelState.isPrivate,
                          onChanged: (newState) {
                            model.setIsPrivate(newState);
                          }), onPress: () {
                        model.setIsPrivate(!modelState.isPrivate);
                      }),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: MainStyles.blueButton(ref, globalLocalizations.publish_post_publish_to_homepage, () {
                      publishPost(false);
                    }),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: MainStyles.gradientButton(
                        ref,
                        globalLocalizations.publish_post_publish_to_waiting_list,
                        modelState.isPrivate
                            ? null
                            : () {
                                if (!(preferences.getBool(Preferences.KEY_ADD_TO_VOTE_LIST_DIALOG_CHECKED) ?? false)) {
                                  showWaitingListHintDialog();
                                  // return;
                                } else {
                                  publishPost(true);
                                }
                              }),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  joinWaitingListFee == null
                      ? SizedBox(
                          height: 24,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 24,
                            ),
                            HoohLocalizedRichText(
                                text: sprintf(globalLocalizations.publish_post_spends_ore, [joinWaitingListFee]),
                                keys: [
                                  HoohLocalizedWidgetKey(
                                    key: globalLocalizations.publish_post_spends_ore_placeholder,
                                    widget: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: HoohIcon(
                                        "assets/images/common_ore.svg",
                                        width: 18,
                                        height: 18,
                                      ),
                                    ),
                                  )
                                ],
                                defaultTextStyle: bottomTextStyle),
                            IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(minHeight: 24, minWidth: 24),
                                splashRadius: 24,
                                onPressed: () {
                                  showHoohDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(globalLocalizations.publish_post_spends_ore_dialog_title),
                                          content: Text(globalLocalizations.publish_post_spends_ore_dialog_content),
                                        );
                                      });
                                },
                                icon: Icon(
                                  Icons.info_rounded,
                                  size: 18,
                                  color: designColors.dark_03.auto(ref),
                                )),
                          ],
                        ),
                  SizedBox(
                    height: 24,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showHoohDialogWithCheckBox({
    required String title,
    required String content,
    required bool Function(WidgetRef ref) checked,
    required String checkBoxText,
    required String okText,
    required Function(bool?) onCheckBoxChanged,
    required Function() onOkClick,
  }) {
    showHoohDialog(
        context: context,
        barrierDismissible: false,
        builder: (popContext) {
          double screenHeight = MediaQuery.of(context).size.height;
          double screenWidth = MediaQuery.of(context).size.width;
          return Consumer(builder: (consumerContext, ref, child) {
            return AlertDialog(
              insetPadding: EdgeInsets.all(20),
              title: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              titlePadding: EdgeInsets.only(top: 24, left: 24, right: 24),
              contentPadding: EdgeInsets.all(16),
              content: SizedBox(
                width: screenWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        height: screenHeight / 4,
                        child: Scrollbar(
                          child: CustomScrollView(
                            slivers: [
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Text(
                                  content,
                                  style: TextStyle(fontSize: 16, color: designColors.light_06.auto(ref)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 4,
                        ),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: checked(ref),
                            onChanged: onCheckBoxChanged,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          checkBoxText,
                          style: TextStyle(color: designColors.dark_01.auto(ref), fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: MainStyles.outlinedTextButton(ref, globalLocalizations.common_cancel, () {
                            Navigator.pop(context);
                          }),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: MainStyles.gradientButton(ref, okText, onOkClick),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  void showWaitingListHintDialog() {
    PublishPostScreenModelState modelState = ref.watch(widget.provider);
    PublishPostScreenViewModel model = ref.read(widget.provider.notifier);
    if (joinWaitingListFee != null) {
      _showHoohDialogWithCheckBox(
          title: globalLocalizations.publish_post_hint_dialog_title,
          content: sprintf(globalLocalizations.publish_post_hint_dialog_content, [joinWaitingListFee]),
          checked: (ref) {
            PublishPostScreenModelState modelState = ref.watch(widget.provider);
            return modelState.hintChecked;
          },
          checkBoxText: globalLocalizations.templates_don_t_prompt_next_time,
          okText: globalLocalizations.common_confirm,
          onCheckBoxChanged: (value) {
            debugPrint("onChanged value=$value");
            model.setHintChecked(value!);
          },
          onOkClick: () {
            debugPrint("put modelState.hintChecked=${modelState.hintChecked}");
            preferences.putBool(Preferences.KEY_ADD_TO_VOTE_LIST_DIALOG_CHECKED, ref.read(widget.provider).hintChecked);
            Navigator.pop(context);
            User? user = ref.read(globalUserInfoProvider);
            if (user == null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
              return;
            }
            publishPost(true);
          });
    }
  }

  void publishPost(bool publishToWaitingList) {
    PublishPostScreenModelState modelState = ref.read(widget.provider);
    PublishPostScreenViewModel model = ref.read(widget.provider.notifier);
    User user = ref.read(globalUserInfoProvider)!;
    showHoohDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return LoadingDialog(LoadingDialogController());
        });
    model.publishPost(
        context: context,
        currentUser: user,
        publishToWaitingList: publishToWaitingList,
        onSuccess: (post) {
          // Navigator.popUntil(context, ModalRoute.withName("/home"));
          clearDraft();
          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(context).pop();
            showSnackBar(context, globalLocalizations.publish_post_success);
            HomePageViewModel model = ref.read(homePageProvider.notifier);
            model.updateTabIndex(HomeScreen.PAGE_INDEX_FEEDS);
            if (publishToWaitingList) {
              model.updateFeedsTabIndex(FeedsPage.PAGE_INDEX_WAITING, notifyController: true);
            } else {
              model.updateFeedsTabIndex(FeedsPage.PAGE_INDEX_MAIN, notifyController: true);
            }
            popToHomeScreen(context);
          });
        },
        onError: (error) {
          Navigator.of(context).pop();
          // if (error is HoohApiErrorResponse && error.errorCode == Constants.INSUFFICIENT_FUNDS) {
          //
          // } else {
          // }
          //   showSnackBar(context, sprintf(globalLocalizations.publish_post_failed, [globalLocalizations.error_network_error]));
          // showCommonRequestErrorDialog(ref, context, error);
          if (error.errorCode == Constants.INSUFFICIENT_FUNDS) {
            List<String> split = error.message.split("\n");
            showNotEnoughOreDialog(ref: ref, context: context, isPublishingPost: true, needed: int.tryParse(split[0])!, current: int.tryParse(split[1])!);
          } else {
            showCommonRequestErrorDialog(ref, context, error);
          }
        });
  }

  void clearDraft() {
    InputPageViewModel model = ref.read(globalInputPageProvider.notifier);
    model.updateInputText("", needRefresh: true);
    preferences.remove(Preferences.KEY_USER_DRAFT);
  }

  Widget buildTags(List<String> tags) {
    PublishPostScreenModelState modelState = ref.read(widget.provider);
    PublishPostScreenViewModel model = ref.read(widget.provider.notifier);
    List<Widget> children = [
      Expanded(
        child: Text(
          tags.isEmpty ? globalLocalizations.publish_post_topics : tags.map((e) => "# $e").join("   "),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14, color: tags.isEmpty ? designColors.light_06.auto(ref) : designColors.feiyu_blue.auto(ref)),
        ),
      ),
    ];
    children.add(HoohIcon(
      "assets/images/icon_arrow_next_ios.svg",
      width: 24,
      height: 24,
      color: designColors.light_06.auto(ref),
    ));
    return Material(
      color: designColors.light_00.auto(ref),
      child: Ink(
        height: 48,
        // color: designColors.light_02.auto(ref),
        child: InkWell(
          onTap: () async {
            List<String>? tags = await Navigator.of(context).push<List<String>>(PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) {
              return SelectTopicScreen(
                selectedTags: modelState.tags,
              );
            }, transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween = Tween(begin: begin, end: end);
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: curve,
              );

              return SlideTransition(
                position: tween.animate(curvedAnimation),
                child: child,
              );
            }));
            if (tags != null) {
              model.setTags(tags);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
