import 'package:app/ui/pages/creation/edit_post.dart';
import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/ui/pages/creation/recommended_templates_view_model.dart';
import 'package:app/ui/widgets/template_compose_view.dart';
import 'package:app/ui/widgets/toast.dart';
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
      appBar: AppBar(
        title: Text("Select Image"),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: MaterialClassicHeader(
          // offset: totalHeight,
          color: designColors.feiyu_blue.auto(ref),
        ),
        onRefresh: () async {
          model.getRecommendedTemplates(onComplete: () {
            _refreshController.refreshCompleted();
          }, onError: (error) {
            Toast.showSnackBar(context, error.message);
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
              return buildTemplateWidget(modelState.templates[templateIndex], scale);
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

  Widget buildTemplateWidget(Template template, double scale) {
    return TemplateView(
      PostImageSetting.withTemplate(template, text: getText()),
      template: template,
      onFavoriteChange: (newState) {},
      onPressBody: () {
        debugPrint("press");
        Navigator.push(context, MaterialPageRoute(builder: (context) => EditPostScreen(setting: PostImageSetting.withTemplate(template, text: getText()))));
      },
      scale: scale,
    );
  }

  Widget buildAddItemWidget() {
    return buildSpecialItemWidget(() {}, "assets/images/select_photos.svg", "Select photos");
  }

  Widget buildSeeMoreWidget() {
    return buildSpecialItemWidget(() {}, "assets/images/to_gallery.svg", "To gallery");
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
