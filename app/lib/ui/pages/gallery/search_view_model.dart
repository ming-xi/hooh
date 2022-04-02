import 'package:common/models/gallery_image.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/page_state.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'search_view_model.g.dart';

@CopyWith()
class SearchPageModelState {
  final List<GalleryImage> images;
  final String keyword;
  final int pageIndex;
  final int imageWidth;
  final PageState pageState;
  final bool showFavoriteStatus;
  final HoohApiErrorResponse? error;

  SearchPageModelState(
      {required this.images,
      required this.keyword,
      required this.pageIndex,
      required this.imageWidth,
      required this.pageState,
      required this.showFavoriteStatus,
      required this.error});

  factory SearchPageModelState.init(int imageWidth, bool showFavoriteStatus) => SearchPageModelState(
      images: [], keyword: "", pageIndex: 1, imageWidth: imageWidth, pageState: PageState.inited, showFavoriteStatus: showFavoriteStatus, error: null);
}

class SearchPageViewModel extends StateNotifier<SearchPageModelState> {
  SearchPageViewModel(SearchPageModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    // search(isRefresh: true);
  }

  // 改为extension实现
  // void updateState(SearchPageModelState s) {
  //   state = s;
  // }

  Future<void> search({bool isRefresh = true}) async {
    if (isRefresh) {
      state = state.copyWith(pageIndex: 1);
      if (![
        PageState.inited,
        PageState.dataLoaded,
        PageState.empty,
        PageState.noMore,
      ].contains(state.pageState)) {
        return;
      }
    } else {
      if (![
        PageState.dataLoaded,
      ].contains(state.pageState)) {
        return;
      }
    }
    state = state.copyWith(pageState: PageState.loading);
    network.requestAsync<List<GalleryImage>>(network.searchGalleryImageList(state.keyword, state.pageIndex, state.imageWidth, state.showFavoriteStatus),
        (newData) {
      if (newData.isEmpty) {
        state = state.copyWith(pageState: isRefresh ? PageState.empty : PageState.noMore);
        return;
      }
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
        pageState: PageState.dataLoaded,
        images: list,
        pageIndex: page,
      );
    }, (error) {
      state = state.copyWith(error: error);
      debugPrint("error");
    });
  }
}

