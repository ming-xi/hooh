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
                height: 80,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return CategoryItemView(categories[index]);
                  },
                  itemCount: categories.length,
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: item.selected ? Colors.yellow : Colors.transparent,
      child: Text(item.galleryCategory.name ?? ""),
    );
  }
}

class GalleryCategoryItem {
  final GalleryCategory galleryCategory;
  bool selected;

  GalleryCategoryItem(this.galleryCategory, this.selected);
}
