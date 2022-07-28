import 'package:app/global.dart';
import 'package:app/ui/pages/creation/edit_post.dart';
import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/ui/pages/creation/recommended_templates_view_model.dart';
import 'package:app/ui/pages/gallery/gallery.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/ui/widgets/template_compose_view.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/template.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RecommendedTemplatesScreen extends ConsumerStatefulWidget {
  late StateNotifierProvider<RecommendedTemplatesScreenViewModel, RecommendedTemplatesScreenModelState> provider;
  final List<String> contents;

  RecommendedTemplatesScreen({
    required this.contents,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return RecommendedTemplatesScreenViewModel(RecommendedTemplatesScreenModelState.init(contents));
    });
  }

  @override
  ConsumerState createState() => _RecommendedTemplatesScreenState();
}

class _RecommendedTemplatesScreenState extends ConsumerState<RecommendedTemplatesScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: true);

  @override
  Widget build(BuildContext context) {
    RecommendedTemplatesScreenModelState modelState = ref.watch(widget.provider);
    RecommendedTemplatesScreenViewModel model = ref.read(widget.provider.notifier);
    int gridColumnCount = 2;
    double padding = 20;
    double spacing = 1;
    double screenWidth = MediaQuery.of(context).size.width;
    double imageSize = (screenWidth - padding * 2 - spacing * (gridColumnCount - 1)) / gridColumnCount;
    double scale = imageSize / screenWidth;
    return Scaffold(
      appBar: HoohAppBar(
        title: Text(globalLocalizations.recommended_templates_title),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: MainStyles.getRefresherHeader(ref),
        onRefresh: () async {
          model.getRecommendedTemplates(onComplete: () {
            _refreshController.refreshCompleted();
          }, onError: (error) {
            // Toast.showSnackBar(context, error.message);
            showCommonRequestErrorDialog(ref, context, error);
            _refreshController.refreshCompleted();
          });
        },
        controller: _refreshController,
        child: GridView.builder(
          padding: EdgeInsets.all(padding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridColumnCount, mainAxisSpacing: spacing, crossAxisSpacing: spacing, childAspectRatio: 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              return buildAddItemWidget();
            } else if (index == modelState.templates.length + 1) {
              return buildSeeMoreWidget();
            } else {
              int templateIndex = index - 1;
              return buildTemplateWidget(modelState, model, templateIndex, scale);
            }
          },
          itemCount: modelState.templates.isEmpty ? 0 : modelState.templates.length + 2,
        ),
      ),
    );
  }

  String getText() {
    return widget.contents[0];
  }

  Widget buildTemplateWidget(RecommendedTemplatesScreenModelState modelState, RecommendedTemplatesScreenViewModel model, int index, double scale) {
    Template template = modelState.templates[index];
    TemplateViewSetting viewSetting = TemplateView.generateViewSetting(TemplateView.SCENE_EDIT_POST_SINGLE_IMAGE_RECOMMENDATION);
    viewSetting.buttons[TemplateView.EDGE_BUTTON_TYPE_FAVORITE]!.onPress = (newState) {
      // debugPrint("newState=$newState index=${index - 1}");
      model.setFavorite(index, newState);
    };
    PostImageSetting imageSetting = modelState.postImageSettings[index];
    return TemplateView(
      imageSetting,
      // PostImageSetting.withTemplate(template, text: getText()),
      template: template,
      viewSetting: viewSetting,
      onPressBody: () {
        // debugPrint("press");
        Navigator.push(context, MaterialPageRoute(builder: (context) => EditPostScreen(setting: imageSetting)));
      },
      scale: scale,
    );
  }

  Widget buildAddItemWidget() {
    return buildSpecialItemWidget(() {
      showSelectLocalImageActionSheet(
          context: context,
          ref: ref,
          adjustTemplateImage: true,
          onSelected: (file) {
            if (file == null) {
              return;
            }
            Color textColor = isImageDarkColor(file.readAsBytesSync()) ? Colors.white : Colors.black;
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return EditPostScreen(setting: PostImageSetting.withLocalFile(file, textColor, text: getText()));
            }));
          });
    }, "assets/images/select_photos.svg", globalLocalizations.recommended_templates_from_local);
  }

  Widget buildSeeMoreWidget() {
    return buildSpecialItemWidget(() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryScreen()));
    }, "assets/images/to_gallery.svg", globalLocalizations.recommended_templates_see_more);
  }

  Widget buildSpecialItemWidget(void Function() onPress, String assetIconPath, String text) {
    return Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: designColors.feiyu_blue.auto(ref),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPress,
        child: Center(
          child: Column(
            children: [
              Spacer(
                flex: 59,
              ),
              HoohIcon(
                assetIconPath,
                width: 36,
                height: 36,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                text,
                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Spacer(
                flex: 42,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
