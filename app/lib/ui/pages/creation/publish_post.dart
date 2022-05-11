import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/ui/pages/creation/publish_post_view_model.dart';
import 'package:app/ui/pages/creation/select_topic.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/template_compose_view.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
        title: Text("Post"),
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
                MainStyles.buildListTile(ref, "Download",
                    tailWidget: Switch(
                        value: modelState.allowDownload,
                        onChanged: (newState) {
                          model.setAllowDownload(newState);
                        }), onPress: () {
                  model.setAllowDownload(!modelState.allowDownload);
                }),
                MainStyles.buildListTile(ref, "Private",
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
                  child: MainStyles.blueButton(ref, "Post to My Homepage only", () {
                    publishPost(false);
                  }, cornerRadius: 22),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: MainStyles.gradientButton(ref, "Post to square queue", () {
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
                      "Spend 5 x ",
                      style: bottomTextStyle,
                    ),
                    HoohIcon(
                      "assets/images/common_ore.svg",
                      width: 18,
                      height: 18,
                    ),
                    Text(" for more exposure", style: bottomTextStyle),
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
          Navigator.of(context).pop();
          Toast.showSnackBar(context, "upload success!");
        },
        onError: (error) {
          Navigator.of(context).pop();
          Toast.showSnackBar(context, "upload failed: " + error);
        });
  }

  Widget buildTags(List<String> tags) {
    PublishPostScreenModelState modelState = ref.read(widget.provider);
    PublishPostScreenViewModel model = ref.read(widget.provider.notifier);
    List<Widget> children = [
      Expanded(
        child: Text(
          tags.isEmpty ? "# Topics" : tags.map((e) => "# $e").join("   "),
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