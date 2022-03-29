import 'dart:async';

import 'package:app/ui/pages/gallery/search_view_model.dart';
import 'package:app/ui/pages/home/gallery.dart';
import 'package:blur/blur.dart';
import 'package:common/models/gallery_image.dart';
import 'package:common/models/page_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
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
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ).frosted(
            blur: 10,
            frostColor: Colors.white,
            frostOpacity: 0.9,
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Text(modelState.pageIndex.toString()),
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          bottom: false,
          child: listWidget,
        ),
      ),
    );
  }

  Widget buildSearchBar(BuildContext context, double iconSize, double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, padding, padding, padding),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(200),
          color: const Color(0xFFEAEAEA),
        ),
        child: GestureDetector(
          onTap: () {},
          child: Row(
            children: [
              Container(
                  child: SvgPicture.asset('assets/images/icon_search.svg', height: iconSize, width: iconSize),
                  padding: EdgeInsets.fromLTRB(0, padding, padding, padding)),
              Expanded(
                child: TextField(
                  focusNode: node,
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    hintText: 'search',
                    border: InputBorder.none,
                  ),
                  onChanged: (String value) async {
                    debugPrint("onChanged $value");
                    var viewModel = ref.read(widget.imagesProvider(imageWidth).notifier);
                    viewModel.updateState(ref.read(widget.imagesProvider(imageWidth)).copyWith(keyword: value, pageIndex: 1));
                    viewModel.search();
                  },
                  onSubmitted: (String value) async {
                    debugPrint("onSubmitted $value");
                  },
                ),
              ),
              SizedBox(width: padding),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                style: const ButtonStyle(
                  splashFactory: NoSplash.splashFactory,
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
      debugPrint("images size=${modelState.images.length}");
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
          padding: EdgeInsets.fromLTRB(16, totalHeight, 16, 96),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //横轴元素个数
              crossAxisCount: 3,
              //子组件宽高长度比例
              childAspectRatio: 1.0),
          itemCount: modelState.images.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                // _galleryItemTouched(index);
              },
              child: GalleryImageView(modelState.images[index], (newState) {}),
            );
          },
        ),
      );
    }
    return listWidget;
  }
}
