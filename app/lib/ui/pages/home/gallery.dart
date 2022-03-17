import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/models/gallery_category.dart';
import 'package:common/models/gallery_image.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tuple/tuple.dart';

final galleryCategoriesProvider = StateProvider((ref) => <GalleryCategoryItem>[]);
final selectedCategoryProvider = StateProvider((ref) {
  return ref.watch(galleryCategoriesProvider.state).state.firstWhere(
        (element) => element.selected,
        orElse: () => GalleryCategoryItem(null, false),
      );
});
final galleryImagesProvider = StateProvider((ref) => <GalleryImage>[]);
final newGalleryImagesProvider = FutureProvider.autoDispose.family<List<GalleryImage>, Tuple2<String, int>>((ref, tuple) async {
  // // Cancel the HTTP request if the user leaves the detail page before
  // // the request completes.
  // final cancelToken = CancelToken();
  // ref.onDispose(cancelToken.cancel);
  var page = ref.watch(galleryImagesPageProvider.state).state;
  var list = await network.getGalleryImageList(tuple.item1, page, tuple.item2);
  // ref.keepAlive();

  return list;
});
final galleryImagesPageProvider = StateProvider((ref) => 1);

class GalleryPage extends ConsumerStatefulWidget {
  const GalleryPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage> {
  @override
  void initState() {
    super.initState();
    network.getGalleryCategoryList().then((value) {
      var list = value.map((e) => GalleryCategoryItem(e, false)).toList();
      if (list.isNotEmpty) {
        list[1].selected = true;
      }
      ref.read(galleryCategoriesProvider.state).state = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build page");
    final ScrollController _controller = ScrollController();
    List<GalleryCategoryItem> categories = ref.watch(galleryCategoriesProvider.state).state;
    List<GalleryImage> images = ref.watch(galleryImagesProvider.state).state;
    String? safeId = ref.watch(selectedCategoryProvider.state).state.galleryCategory?.safeId;
    int width = MediaQuery.of(context).size.width ~/ 3;
    Widget listWidget;
    if (safeId == null) {
      listWidget = Container();
    } else {
      // 之前的做法，先定义refreshIndicator，在里面调用了images
      // var refreshIndicator = RefreshIndicator(
      //   onRefresh: () async {
      //     ref.read(galleryImagesProvider.state).state = [];
      //     ref.read(galleryImagesPageProvider.state).state = 1;
      //     return ref.refresh(newGalleryImagesProvider(Tuple2(safeId, width)));
      //   },
      //   child: GridView.builder(
      //     padding: const EdgeInsets.fromLTRB(16, 0, 10, 0),
      //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //         //横轴元素个数
      //         crossAxisCount: 3,
      //         // //纵轴间距
      //         // mainAxisSpacing: 0.0,
      //         // //横轴间距
      //         // crossAxisSpacing: 0.0,
      //         //子组件宽高长度比例
      //         childAspectRatio: 1.0),
      //     itemCount: images.length,
      //     itemBuilder: (BuildContext context, int index) => GalleryImageView(images[index]),
      //   ),
      // );
      // 但是这里在闭包里又修改了images的值。可能导致了前面的refreshIndicator无法正确刷新状态
      // listWidget = ref.watch(newGalleryImagesProvider(Tuple2(safeId, width))).when(
      //     data: (data) {
      //       images.addAll(data);
      //       return refreshIndicator;
      //     },
      //     error: (error, stack) => Container(
      //           color: Colors.red,
      //         ),
      //     loading: () => isRefresh ? CircularProgressIndicator() : refreshIndicator);
      List<GalleryImage> list = ref.watch(newGalleryImagesProvider(Tuple2(safeId, width))).when(data: (data){
        images.addAll(data);
        return images;
      }, error: (obj,stack){
        return images;
      }, loading: (){
        return images;
      });
      listWidget = RefreshIndicator(
        onRefresh: () async {
          ref.read(galleryImagesProvider.state).state = [];
          ref.read(galleryImagesPageProvider.state).state = 1;
          return ref.refresh(newGalleryImagesProvider(Tuple2(safeId, width)));
        },
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 10, 0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //横轴元素个数
              crossAxisCount: 3,
              // //纵轴间距
              // mainAxisSpacing: 0.0,
              // //横轴间距
              // crossAxisSpacing: 0.0,
              //子组件宽高长度比例
              childAspectRatio: 1.0),
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) => GalleryImageView(list[index]),
        ),
      );
    }

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: const Color(0xFFEAEAEA),
                        ),
                        child: (Row(
                          children: [
                            SvgPicture.asset('assets/images/icon_search.svg', height: 24, width: 24),
                            const SizedBox(width: 10),
                            const Expanded(child: Text('search'))
                          ],
                        )),
                        padding: EdgeInsets.all(10),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        print(index);
                        for (var item in categories) {
                          item.selected = false;
                        }
                        categories[index].selected = true;
                        // 因为categories其实还是原来的list，所以给state赋值无效。所以要构建一个新的list赋值，有3种写法：
                        // #1
                        // List<GalleryCategoryItem> newList = [];
                        // newList.addAll(categories);
                        // ref.read(galleryCategoriesProvider.state).state = newList;

                        // #2 这个叫联什么什么写法，就是两个点，代表要对这个对象进行后面的操作
                        // ref.read(galleryCategoriesProvider.state).state = []..addAll(categories);

                        // #3 dart把#2优化成了3个点的，叫spread，一个意思，语法糖

                        ref.read(galleryImagesProvider.state).state = [];
                        ref.read(galleryImagesPageProvider.state).state = 1;
                        ref.read(galleryCategoriesProvider.state).state = [...categories];

                        // _controller.animateTo(125, duration: Duration(milliseconds: 250), curve: Curves.ease);
                      },
                      child: CategoryItemView(categories[index]),
                    );
                  },
                  itemCount: categories.length,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(child: listWidget)
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          if (safeId != null) {
            ref.read(galleryImagesPageProvider.state).state += 1;
            // ref.refresh(newGalleryImagesProvider(Tuple2(safeId, width)));
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}

class CategoryItemView extends ConsumerWidget {
  final GalleryCategoryItem item;

  const CategoryItemView(
    this.item, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: item.selected ? Colors.yellow : Colors.transparent,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(item.galleryCategory?.name ?? "", style: const TextStyle(fontSize: 12)),
    );
  }
}

class GalleryImageView extends ConsumerWidget {
  final GalleryImage item;

  const GalleryImageView(
    this.item, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: item.imageUrl,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
                // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn)
              ),
            ),
          ),
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        Positioned(
          child: Container(
            width: 44,
            height: 44,
            child: Center(
              child: SvgPicture.asset('assets/images/collection_unselected.svg', height: 27, width: 27),
            ),
          ),
          top: 0,
          right: 0,
        ),
        Positioned(
          child: Container(
            width: 44,
            height: 44,
            child: Center(
              child: SvgPicture.asset('assets/images/image_info.svg', height: 17, width: 17),
            ),
          ),
          bottom: 0,
          right: 0,
        ),
      ],
    );
  }
}

class GalleryCategoryItem {
  final GalleryCategory? galleryCategory;
  bool selected;

  GalleryCategoryItem(this.galleryCategory, this.selected);
}
