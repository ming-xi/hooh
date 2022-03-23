import 'dart:async';

import 'package:app/ui/pages/home/gallery.dart';
import 'package:blur/blur.dart';
import 'package:common/models/gallery_image.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GallerySearchScreen extends ConsumerStatefulWidget {
  late final StateProvider galleryImagesProvider;
  late final AutoDisposeFutureProviderFamily<List<GalleryImage>, int> newGalleryImagesProvider;
  late final StateProvider galleryImagesPageProvider;
  late final StateProvider keyProvider;

  GallerySearchScreen({
    Key? key,
  }) : super(key: key) {
    galleryImagesProvider = StateProvider((ref) => <GalleryImage>[]);
    newGalleryImagesProvider = FutureProvider.autoDispose.family<List<GalleryImage>, int>((ref, width) async {
      var page = ref.watch(galleryImagesPageProvider.state).state;
      var key = ref.watch(keyProvider.state).state;
      var list = await network.searchGalleryImageList(key, page, width, true);
      debugPrint("page = $page, key = $key");
      return list;
    });
    galleryImagesPageProvider = StateProvider((ref) => 1);
    keyProvider = StateProvider((ref) => "");
  }

  @override
  ConsumerState createState() => _GallerySearchScreenState();
}

class _GallerySearchScreenState extends ConsumerState<GallerySearchScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    double safePadding = MediaQuery.of(context).padding.top;
    double padding = 16.0;
    double iconSize = 24.0;
    double totalHeight = padding * 3 + iconSize;
    totalHeight += padding;
    int imageWidth = MediaQuery.of(context).size.width ~/ 3;
    List<GalleryImage> images = ref.watch(widget.galleryImagesProvider.state).state;
    String? key = ref.watch(widget.keyProvider.state).state;

    var searchBar = buildSearchBar(context, iconSize, padding);
    Widget listWidget = buildListWidget(key, imageWidth, images, totalHeight + safePadding);

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
                  // autofocus: true,
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    hintText: 'search',
                    border: InputBorder.none,
                  ),
                  onChanged: (String value) async {
                    debugPrint("onChanged $value");
                    ref.read(widget.galleryImagesPageProvider.state).state = 1;
                    ref.read(widget.keyProvider.state).state = value;
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

  Widget buildListWidget(String? key, int width, List<GalleryImage> images, double totalHeight) {
    Widget listWidget;
    if (key?.length == 0) {
      listWidget = Container();
    } else {
      List<GalleryImage> list = ref.watch(widget.newGalleryImagesProvider(width)).when(data: (data) {
        images.addAll(data);
        return images;
      }, error: (obj, stack) {
        return images;
      }, loading: () {
        return images;
      });
      listWidget = SmartRefresher(
        // enablePullDown: true,
        enablePullUp: true,
        // header: const ClassicHeader(),
        // onRefresh: () async {
        //   ref.read(galleryImagesProvider.state).state = [];
        //   ref.read(galleryImagesPageProvider.state).state = 1;
        //   ref.refresh(newGalleryImagesProvider(Tuple2(safeId, width)));
        //   Timer(const Duration(milliseconds: 500), () {
        //     _refreshController.refreshCompleted();
        //   });
        // },
        onLoading: () async {
          ref.read(widget.galleryImagesPageProvider.state).state += 1;
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
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {

              return GestureDetector(
                onTap: () {
                  // _galleryItemTouched(index);
                },
                child: GalleryImageView(list[index], (newState) {
                  list[index].favorited = newState;
                  debugPrint(list[index].safeId);
                  ref.read(galleryImagesProvider.state).state = [...list];
                  network.requestAsync(network.setGalleryImageFavorited(list[index].safeId, newState), (data) {
                    var categoryName = ref.read(selectedCategoryProvider.state).state.galleryCategory?.name;
                    if (categoryName == "我的常用") {
                      debugPrint("我的常用");
                      list.removeAt(index);
                      ref.read(galleryImagesProvider.state).state = [...list];
                    }
                  }, (error) {
                    list[index].favorited = !newState;
                    ref.read(galleryImagesProvider.state).state = [...list];
                  });
                }),
              );

          },
        ),
      );
    }
    return listWidget;
  }
}
