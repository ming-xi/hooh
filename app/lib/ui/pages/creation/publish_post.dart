import 'package:app/global.dart';
import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/ui/pages/creation/publish_post_view_model.dart';
import 'package:app/ui/pages/creation/select_topic.dart';
import 'package:app/ui/pages/home/feeds.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/home/home_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/template_compose_view.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sprintf/sprintf.dart';

class PublishPostScreen extends ConsumerStatefulWidget {
  late StateNotifierProvider<PublishPostScreenViewModel, PublishPostScreenModelState> provider;

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
  @override
  Widget build(BuildContext context) {
    PublishPostScreenViewModel model = ref.read(widget.provider.notifier);
    PublishPostScreenModelState modelState = ref.watch(widget.provider);
    TemplateViewSetting viewSetting = TemplateView.generateViewSetting(TemplateView.SCENE_PUBLISH_POST_PREVIEW);
    double screenWidth = MediaQuery.of(context).size.width;
    TextStyle bottomTextStyle = TextStyle(color: designColors.light_06.auto(ref), fontSize: 12, fontWeight: FontWeight.bold);
    return Scaffold(
      appBar: AppBar(
        title: Text(globalLocalizations.common_post),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
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
                          showDialog(
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
                  }, cornerRadius: 22),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: MainStyles.gradientButton(ref, globalLocalizations.publish_post_publish_to_waiting_list, () {
                    publishPost(true);
                  }, cornerRadius: 22),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                    ),
                    Text(
                      globalLocalizations.publish_post_spends_ore_part1,
                      style: bottomTextStyle,
                    ),
                    HoohIcon(
                      "assets/images/common_ore.svg",
                      width: 18,
                      height: 18,
                    ),
                    Text(globalLocalizations.publish_post_spends_ore_part2, style: bottomTextStyle),
                    IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("title"),
                                  content: Text("description"),
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
          )
        ],
      ),
    );
  }

  void publishPost(bool publishToWaitingList) {
    PublishPostScreenModelState modelState = ref.read(widget.provider);
    PublishPostScreenViewModel model = ref.read(widget.provider.notifier);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return LoadingDialog(LoadingDialogController());
        });
    model.publishPost(
        context: context,
        publishToWaitingList: publishToWaitingList,
        onSuccess: (post) {
          // Navigator.popUntil(context, ModalRoute.withName("/home"));
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop();
            Toast.showSnackBar(context, globalLocalizations.publish_post_success);
            if (publishToWaitingList) {
              HomePageViewModel model = ref.read(homePageProvider.notifier);
              model.updateTabIndex(HomeScreen.PAGE_INDEX_FEEDS);
              model.updateFeedsTabIndex(FeedsPage.PAGE_INDEX_WAITING, notifyController: true);
            }
            popToHomeScreen(context);
          });
        },
        onError: (error) {
          Navigator.of(context).pop();
          Toast.showSnackBar(context, sprintf(globalLocalizations.publish_post_failed, [error]));
        });
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
    children.add(Icon(
      Icons.arrow_forward_ios_rounded,
      size: 18,
      color: designColors.light_06.auto(ref),
    ));
    return Material(
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
