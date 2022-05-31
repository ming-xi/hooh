import 'package:common/utils/date_util.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/template.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'search_view_model.g.dart';

@CopyWith()
class SearchPageModelState {
  final List<Template> images;
  final String keyword;
  final DateTime? lastTimestamp;
  final int imageWidth;
  final PageState pageState;
  final bool showFavoriteStatus;
  final HoohApiErrorResponse? error;

  SearchPageModelState(
      {required this.images,
      required this.keyword,
      required this.lastTimestamp,
      required this.imageWidth,
      required this.pageState,
      required this.showFavoriteStatus,
      required this.error});

  factory SearchPageModelState.init(int imageWidth, bool showFavoriteStatus) => SearchPageModelState(
      images: [], keyword: "", lastTimestamp: null, imageWidth: imageWidth, pageState: PageState.inited, showFavoriteStatus: showFavoriteStatus, error: null);
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
      state = state.copyWith(lastTimestamp: null);
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
    DateTime date = state.lastTimestamp ?? DateUtil.getCurrentUtcDate();
    network.requestAsync<List<Template>>(network.searchTemplatesByTag(state.keyword, date), (newData) {
      if (newData.isEmpty) {
        state = state.copyWith(pageState: isRefresh ? PageState.empty : PageState.noMore);
        return;
      }
      List<Template> list;
      if (isRefresh) {
        list = newData;
      } else {
        list = [...state.images, ...newData];
      }
      state = state.copyWith(
        pageState: PageState.dataLoaded,
        images: list,
        lastTimestamp: list.isEmpty ? null : list.last.featuredAt,
      );
    }, (error) {
      state = state.copyWith(error: error);
      // debugPrint("error");
    });
  }
}
