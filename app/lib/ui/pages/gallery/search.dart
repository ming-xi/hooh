import 'dart:async';

import 'package:app/extensions/extensions.dart';
import 'package:app/global.dart';
import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/ui/pages/gallery/search_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/template_compose_view.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:blur/blur.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/template.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GallerySearchScreen extends ConsumerStatefulWidget {
  final StateNotifierProviderFamily<SearchPageViewModel, SearchPageModelState, int> imagesProvider =
      StateNotifierProvider.family<SearchPageViewModel, SearchPageModelState, int>((ref, width) => SearchPageViewModel(SearchPageModelState.init(width, true)));

  GallerySearchScreen({
    Key? key,
  }) : super(key: key) {}

  @override
  ConsumerState createState() => _GallerySearchScreenState();
}

class _GallerySearchScreenState extends ConsumerState<GallerySearchScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  TextEditingController controller = TextEditingController();
  FocusNode node = FocusNode();
  int imageWidth = 0;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // safe area height
    double safePadding = MediaQuery.of(context).padding.top;
    // common padding
    double padding = 16.0;
    // search icon
    double iconSize = 24.0;
    double totalHeight = padding * 3 + iconSize;
    totalHeight += padding;
    imageWidth = MediaQuery.of(context).size.width ~/ 3;
    SearchPageModelState modelState = ref.watch(widget.imagesProvider(imageWidth));

    var searchBar = buildSearchBar(context, iconSize, padding);

    Widget listWidget = buildListWidget(modelState, totalHeight + safePadding);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(totalHeight),
        child: Builder(builder: (context) {
          return AppBar(
            toolbarHeight: totalHeight,
            elevation: 0,
            title: searchBar,
            titleSpacing: 0,
            // backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ).frosted(
            blur: 10,
            frostColor: Colors.white,
            frostOpacity: 0.9,
          );
        }),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: listWidget,
      ),
    );
  }

  Widget buildSearchBar(BuildContext context, double iconSize, double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, padding, padding, padding),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(200),
          color: designColors.light_02.auto(ref),
        ),
        child: GestureDetector(
          onTap: () {},
          child: Row(
            children: [
              Container(
                  child: HoohIcon(
                    'assets/images/icon_search.svg',
                    height: iconSize,
                    width: iconSize,
                    color: designColors.dark_01.auto(ref),
                  ),
                  padding: EdgeInsets.fromLTRB(0, padding, padding, padding)),
              Expanded(
                child: TextField(
                  focusNode: node,
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref)),
                    labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    hintText: globalLocalizations.templates_search,
                    border: InputBorder.none,
                  ),
                  onChanged: (String value) async {
                    // debugPrint("onChanged $value");
                    // // 如果不在第一页，重新加载数据的时候滚到顶部
                    // if (scrollController.hasClients) {
                    //   final position = scrollController.position.minScrollExtent;
                    //   scrollController.animateTo(
                    //     position,
                    //     duration: Duration(milliseconds: 10),
                    //     curve: Curves.easeOut,
                    //   );
                    // }
                    var viewModel = ref.read(widget.imagesProvider(imageWidth).notifier);
                    viewModel.updateState(ref.read(widget.imagesProvider(imageWidth)).copyWith(keyword: value));
                    viewModel.search();
                  },
                  // onSubmitted: (String value) async {
                  //   // debugPrint("onSubmitted $value");
                  // },
                  onEditingComplete: () {},
                ),
              ),
              SizedBox(width: padding),
              TextButton(
                style: MainStyles.textButtonStyle(ref),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  globalLocalizations.common_cancel,
                  style: TextStyle(
                    color: designColors.dark_01.auto(ref),
                    fontSize: 16,
                  ),
                ),
              )
            ],
          ),
        ),
        padding: EdgeInsets.fromLTRB(padding, 0, padding, 0),
      ),
    );
  }

  Widget buildListWidget(SearchPageModelState modelState, double totalHeight) {
    Widget listWidget;
    if ([PageState.empty, PageState.inited].contains(modelState.pageState)) {
      listWidget = Container();
    } else {
      // debugPrint("images size=${modelState.images.length}");
      listWidget = SmartRefresher(
        enablePullDown: false,
        enablePullUp: modelState.pageState != PageState.noMore,
        onLoading: () async {
          SearchPageViewModel viewModel = ref.read(widget.imagesProvider(imageWidth).notifier);
          viewModel.search(isRefresh: false);
          Timer(const Duration(milliseconds: 500), () {
            _refreshController.loadComplete();
          });
        },
        controller: _refreshController,
        child: GridView.builder(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(16, totalHeight, 16, 96),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //横轴元素个数
              crossAxisCount: 3,
              //子组件宽高长度比例
              childAspectRatio: 1.0),
          itemCount: modelState.images.length,
          itemBuilder: (BuildContext context, int index) {
            TemplateViewSetting viewSetting = TemplateView.generateViewSetting(TemplateView.SCENE_GALLERY_SEARCH);
            Template template = modelState.images[index];
            return GestureDetector(
              onTap: () {
                // _galleryItemTouched(index);
              },
              child: TemplateView(
                PostImageSetting.withTemplate(template),
                viewSetting: viewSetting,
                template: template,
              ),
            );
          },
        ),
      );
    }
    return listWidget;
  }
}
