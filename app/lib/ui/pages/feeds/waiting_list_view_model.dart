import 'package:app/extensions/extensions.dart';
import 'package:collection/collection.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/post.dart';
import 'package:common/models/template.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'waiting_list_view_model.g.dart';

@CopyWith()
class WaitingListPageModelState {
  final List<Post> posts;
  final PageState pageState;
  final HoohApiErrorResponse? error;
  final DateTime? lastTimestamp;
  final bool infoDialogChecked;

  WaitingListPageModelState({
    required this.posts,
    required this.pageState,
    required this.error,
    required this.lastTimestamp,
    required this.infoDialogChecked,
  });

  factory WaitingListPageModelState.init() => WaitingListPageModelState(
      posts: [],
      pageState: PageState.inited,
      error: null,
      lastTimestamp: null,
      infoDialogChecked: preferences.getBool(Preferences.KEY_VOTE_POST_DIALOG_CHECKED) ?? false);
}

class WaitingListPageViewModel extends StateNotifier<WaitingListPageModelState> {
  WaitingListPageViewModel(WaitingListPageModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    getPosts(null);
  }

  void getPosts(Function(PageState)? callback, {bool isRefresh = true}) {
    if (isRefresh) {
      updateState(state.copyWith(lastTimestamp: null));
      if (state.pageState == PageState.loading) {
        if (callback != null) {
          callback(state.pageState);
        }
        return;
      }
    } else {
      if (![
        PageState.dataLoaded,
      ].contains(state.pageState)) {
        if (callback != null) {
          callback(state.pageState);
        }
        return;
      }
    }
    updateState(state.copyWith(pageState: PageState.loading));
    // if (state.selectedCategory == null) {
    //   if (callback != null) {
    //     callback(state.pageState);
    //   }
    //   return;
    // }

    DateTime date = state.lastTimestamp ?? DateUtil.getCurrentUtcDate();

    network.requestAsync<List<Post>>(network.getWaitingListPosts(date: date), (newData) {
      if (newData.isEmpty) {
        //has data
        if (isRefresh) {
          updateState(state.copyWith(pageState: isRefresh ? PageState.empty : PageState.noMore, posts: []));
        } else {
          updateState(state.copyWith(pageState: isRefresh ? PageState.empty : PageState.noMore));
        }
        debugPrint("${state.pageState}");
      } else {
        //no data
        if (isRefresh) {
          updateState(state.copyWith(
            pageState: PageState.dataLoaded,
            lastTimestamp: newData.last.createdAt,
            posts: newData,
          ));
        } else {
          updateState(state.copyWith(
            pageState: PageState.dataLoaded,
            lastTimestamp: newData.last.createdAt,
            posts: state.posts..addAll(newData),
          ));
        }
      }
      if (callback != null) {
        callback(state.pageState);
      }
    }, (error) {
      updateState(state.copyWith(
        error: error,
        pageState: PageState.inited,
      ));
      if (callback != null) {
        callback(state.pageState);
      }
    });
  }

  void setAgreementChecked(bool checked) {
    updateState(state.copyWith(infoDialogChecked: checked));
  }
}
