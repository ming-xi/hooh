import 'dart:async';
import 'dart:io';

import 'package:app/ui/pages/creation/crop_and_scale.dart';
import 'package:app/ui/pages/gallery/search.dart';
import 'package:app/ui/pages/test.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/models/gallery_category.dart';
import 'package:common/models/gallery_image.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

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
    int imageWidth = MediaQuery.of(context).size.width ~/ 3;

    double safePadding = MediaQuery.of(context).padding.top;
    debugPrint("safePadding=$safePadding");
    double padding = 16.0;
    double iconSize = 24.0;
    double listHeight = 40.0;
    double totalHeight = padding * 4 + iconSize + listHeight;
    totalHeight += padding;
    var searchBar = buildSearchBar(context, iconSize, padding);
    var categoryBar = buildCategoryBar(padding, listHeight, _controller, categories);
    Widget listWidget = buildListWidget(safeId, imageWidth, images, totalHeight + safePadding);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(totalHeight),
        child: Builder(builder: (context) {
          return AppBar(
                  toolbarHeight: padding * 5 + iconSize,
                  elevation: 0,
                  title: searchBar,
                  titleSpacing: 0,
                  bottom: PreferredSize(preferredSize: Size.fromHeight(listHeight), child: categoryBar),
                  backgroundColor: Colors.transparent,
                  systemOverlayStyle: SystemUiOverlayStyle.dark)
              .frosted(
            blur: 10,
            frostColor: Colors.white,
            frostOpacity: 0.9,
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TestPage()));
        },
        child: Icon(Icons.add),
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

  Widget buildListWidget(String? safeId, int width, List<GalleryImage> images, double totalHeight) {
    Widget listWidget;
    if (safeId == null) {
      listWidget = Container();
    } else {
      List<GalleryImage> list = ref.watch(newGalleryImagesProvider(Tuple2(safeId, width))).when(data: (data) {
        images.addAll(data);
        return images;
      }, error: (obj, stack) {
        return images;
      }, loading: () {
        return images;
      });
      listWidget = SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const ClassicHeader(),
        onRefresh: () async {
          ref.read(galleryImagesProvider.state).state = [];
          ref.read(galleryImagesPageProvider.state).state = 1;
          ref.refresh(newGalleryImagesProvider(Tuple2(safeId, width)));
          Timer(const Duration(milliseconds: 500), () {
            _refreshController.refreshCompleted();
          });
        },
        onLoading: () async {
          ref.read(galleryImagesPageProvider.state).state += 1;
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
          itemCount: list.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return GestureDetector(
                child: const AddLocalImageView(),
                onTap: () {
                  _galleryItemTouched(index);
                },
              );
            } else {
              return GestureDetector(
                onTap: () {
                  _galleryItemTouched(index);
                },
                child: GalleryImageView(list[index - 1], (newState) {
                  list[index - 1].favorited = newState;
                  debugPrint(list[index - 1].safeId);
                  ref.read(galleryImagesProvider.state).state = [...list];
                  network.requestAsync(network.setGalleryImageFavorited(list[index - 1].safeId, newState), (data) {
                    var categoryName = ref.read(selectedCategoryProvider.state).state.galleryCategory?.name;
                    if (categoryName == "我的常用") {
                      debugPrint("我的常用");
                      list.removeAt(index - 1);
                      ref.read(galleryImagesProvider.state).state = [...list];
                    }
                  }, (error) {
                    list[index - 1].favorited = !newState;
                    ref.read(galleryImagesProvider.state).state = [...list];
                  });
                }),
              );
            }
          },
        ),
      );
    }
    return listWidget;
  }

  Widget buildCategoryBar(double padding, double listHeight, ScrollController _controller, List<GalleryCategoryItem> categories) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: SizedBox(
        height: listHeight,
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget buildSearchBar(BuildContext context, double iconSize, double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, padding * 2, padding, padding),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(200),
          color: const Color(0xFFEAEAEA),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) {
              return GallerySearchScreen();
            }, transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return child;
            }));
          },
          child: Row(
            children: [
              SvgPicture.asset('assets/images/icon_search.svg', height: iconSize, width: iconSize),
              SizedBox(width: padding),
              const Expanded(
                  child: Text(
                'search',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF707070)),
              ))
            ],
          ),
        ),
        padding: EdgeInsets.all(padding),
      ),
    );
  }

  Future<void> _galleryItemTouched(int index) async {
    if (index == 0) {
      debugPrint("插入图片");
      // FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, allowCompression: false);
      // if (result != null) {
      //   File file = File(result.files.single.path!);
      //
      // }

      _showLocalOptionActionSheet();
    } else {
      debugPrint("进入做图");
    }
  }

  Future<void> _showLocalOptionActionSheet() async {
    CupertinoActionSheet actionSheet = CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: const Text('Camera'),
          onPressed: () {
            debugPrint("camera");
            Navigator.pop(context);
            openImagePicker(ImageSource.camera);
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('Gallery'),
          onPressed: () {
            debugPrint("gallery");
            Navigator.pop(context);
            openImagePicker(ImageSource.gallery);
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancel'),
        onPressed: () {
          debugPrint("cancel");
          Navigator.pop(context);
        },
      ),
    );

    /// To display an actionSheet
    showCupertinoModalPopup(context: context, builder: (BuildContext context) => actionSheet);
  }

  /// Open image picker
  void openImagePicker(source) async {
    // showLoader();
    final XFile? pickedFile = await ImagePicker().pickImage(source: source, maxWidth: 1920, maxHeight: 1920);
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: const IOSUiSettings());
    if (croppedFile != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ScaleScreen(croppedFile)));
    }
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

class AddLocalImageView extends ConsumerStatefulWidget {
  const AddLocalImageView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AddLocalImageViewState();
}

class _AddLocalImageViewState extends ConsumerState<AddLocalImageView> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0167F9),
      )),
      Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.add,
            color: Colors.white,
            size: 36,
          ),
          Text(
            "Insert picture",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          )
        ],
      )),
    ]);
  }
}

class GalleryImageView extends ConsumerStatefulWidget {
  final GalleryImage item;
  final Function(bool) callback;

  const GalleryImageView(
    this.item,
    this.callback, {
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _GalleryImageViewState();
}

class _GalleryImageViewState extends ConsumerState<GalleryImageView> {
  StateProvider<bool> visibleProvider = StateProvider(
    (ref) => false,
  );

  @override
  Widget build(BuildContext context) {
    var visible = ref.watch(visibleProvider.state).state;

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: widget.item.imageUrl,
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
          placeholder: (context, url) => const Center(child: const CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        // 显示作者名字
        buildUploaderWidget(visible, widget.item),
        // 收藏按钮
        Positioned(
          child: Container(
            width: 44,
            height: 44,
            child: GestureDetector(
              child: (Center(
                child: SvgPicture.asset(widget.item.favorited ? 'assets/images/collection_selected.svg' : 'assets/images/collection_unselected.svg',
                    height: 27, width: 27),
              )),
              onTap: () {
                widget.callback(!widget.item.favorited);
              },
            ),
          ),
          top: 0,
          right: 0,
        ),
        // 图片作者信息
        Positioned(
          child: GestureDetector(
            child: Container(
              width: 44,
              height: 44,
              child: Center(
                child: SvgPicture.asset('assets/images/image_info.svg', height: 17, width: 17),
              ),
            ),
            onTapDown: (details) {
              ref.read(visibleProvider.state).state = true;
            },
            onTapUp: (details) {
              ref.read(visibleProvider.state).state = false;
            },
          ),
          bottom: 0,
          right: 0,
        ),
      ],
    );
  }

  Widget buildUploaderWidget(bool visible, GalleryImage item) {
    return Visibility(
      visible: visible,
      child: Stack(
        children: [
          Container(
              decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withAlpha(40),
          )),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Text(
                  '图片由 @${item.uploaderName} 作者上传',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class GalleryCategoryItem {
  final GalleryCategory? galleryCategory;
  bool selected;

  GalleryCategoryItem(this.galleryCategory, this.selected);
}
