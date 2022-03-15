import 'package:common/models/gallery_category.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final galleryCategoriesProvider = StateProvider((ref) => <GalleryCategoryItem>[]);

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
        list[0].selected = true;
      }
      ref.read(galleryCategoriesProvider.state).state = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<GalleryCategoryItem> categories = ref.watch(galleryCategoriesProvider.state).state;
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
                        ref.read(galleryCategoriesProvider.state).state = [...categories];
                      },
                      child: CategoryItemView(categories[index]),
                    );
                  },
                  itemCount: categories.length,
                  padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                ),
              ),
            ],
          ),
        ),
      ),
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
      child: Text(item.galleryCategory.name ?? "", style: const TextStyle(fontSize: 12)),
    );
  }
}

class GalleryCategoryItem {
  final GalleryCategory galleryCategory;
  bool selected;

  GalleryCategoryItem(this.galleryCategory, this.selected);
}
