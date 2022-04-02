import 'package:common/models/gallery_category.dart';
import 'package:common/models/gallery_image.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/page_state.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'gallery_view_model.g.dart';

@CopyWith()
class GalleryPageModelState {
  final List<GalleryImage> images;
  final int pageIndex;
  final int imageWidth;
  final PageState imagesPageState;
  final PageState categoriesPageState;
  final HoohApiErrorResponse? error;
  final GalleryCategory? selectedCategory;
  final List<GalleryCategoryItem> categories;

  GalleryPageModelState({
    required this.images,
    required this.pageIndex,
    required this.imageWidth,
    required this.imagesPageState,
    required this.categoriesPageState,
    required this.error,
    required this.selectedCategory,
    required this.categories,
  });

  factory GalleryPageModelState.init(int imageWidth) => GalleryPageModelState(
      images: [],
      pageIndex: 1,
      imageWidth: imageWidth,
      imagesPageState: PageState.inited,
      error: null,
      selectedCategory: null,
      categories: [],
      categoriesPageState: PageState.inited);
}

class GalleryPageViewModel extends StateNotifier<GalleryPageModelState> {
  GalleryPageViewModel(GalleryPageModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    getCategoryList();
  }

  Future<void> getCategoryList() async {
    if (state.categoriesPageState == PageState.loading) {
      return;
    } else {
      if (state.categoriesPageState == PageState.dataLoaded) {
        return;
      }
    }
    state = state.copyWith(categoriesPageState: PageState.loading);
    network.requestAsync<List<GalleryCategory>>(network.getGalleryCategoryList(), (data) {
      var list = data.map((e) => GalleryCategoryItem(e, false)).toList();
      GalleryCategory? selectedCategory;
      if (list.isNotEmpty) {
        list[1].selected = true;
        selectedCategory = list[1].galleryCategory;
      }
      state = state.copyWith(
        imagesPageState: PageState.dataLoaded,
        categories: list,
        selectedCategory: selectedCategory,
      );
      getImageList((succeed) => null);
    }, (error) {
      state = state.copyWith(error: error);
      debugPrint("error");
    });
  }

  Future<void> getImageList(Function(PageState)? callback,{bool isRefresh = true}) async {
    if (isRefresh) {
      state = state.copyWith(pageIndex: 1);
      if (state.imagesPageState == PageState.loading) {
        if (callback != null) {
          callback(state.imagesPageState);
        }
        return;
      }
    } else {
      if (![
        PageState.dataLoaded,
      ].contains(state.imagesPageState)) {
        if (callback != null) {
          callback(state.imagesPageState);
        }
        return;
      }
    }
    state = state.copyWith(imagesPageState: PageState.loading);
    if (state.selectedCategory == null) {
      if (callback != null) {
        callback(state.imagesPageState);
      }
      return;
    }
    network.requestAsync<List<GalleryImage>>(network.getGalleryImageList(state.selectedCategory!.safeId, state.pageIndex, state.imageWidth), (newData) {
      if (newData.isEmpty) {
        state = state.copyWith(imagesPageState: isRefresh ? PageState.empty : PageState.noMore);
        debugPrint("${state.imagesPageState}");
      } else {
        int page;
        List<GalleryImage> list;
        if (isRefresh) {
          page = 1;
          list = newData;
        } else {
          list = state.images..addAll(newData);
        }
        page = state.pageIndex + 1;
        state = state.copyWith(
          imagesPageState: PageState.dataLoaded,
          images: list,
          pageIndex: page,
        );
      }
      if (callback != null) {
        callback(state.imagesPageState);
      }
    }, (error) {
      state = state.copyWith(error: error);
      debugPrint("error");
      if (callback != null) {
        callback(state.imagesPageState);
      }
    });
  }

  Future<void> setGalleryImageFavorite(int itemIndex, bool favorite) async {
    network.requestAsync(network.setGalleryImageFavorite(state.images[itemIndex].safeId, favorite), (data) {
      state.images[itemIndex].favorited = favorite;
      if (state.selectedCategory!.name == "我的常用") {
        debugPrint("我的常用");
        state.images.removeAt(itemIndex);
      }
      state = state.copyWith(images: state.images);
    }, (error) {
      state.images[itemIndex].favorited = !favorite;
      state = state.copyWith(images: state.images);
    });
  }
}

class GalleryCategoryItem {
  final GalleryCategory? galleryCategory;
  bool selected;

  GalleryCategoryItem(this.galleryCategory, this.selected);
}
