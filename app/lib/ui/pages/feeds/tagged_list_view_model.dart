import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/post.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'tagged_list_view_model.g.dart';

@CopyWith()
class TaggedListScreenModelState {
  final String tagName;
  final List<Post> posts;
  final int postCount;
  final PageState pageState;
  final HoohApiErrorResponse? error;
  final DateTime? lastTimestamp;
  final bool infoDialogChecked;
  final bool isTrending;
  final double scrollDistance;
  final int page;

  TaggedListScreenModelState({
    required this.tagName,
    required this.posts,
    required this.pageState,
    required this.error,
    required this.lastTimestamp,
    required this.infoDialogChecked,
    this.isTrending = false,
    this.postCount = 0,
    this.scrollDistance = 0,
    this.page = 1,
  });

  factory TaggedListScreenModelState.init(String tagName) => TaggedListScreenModelState(
      posts: [],
      tagName: tagName,
      pageState: PageState.inited,
      error: null,
      lastTimestamp: null,
      infoDialogChecked: preferences.getBool(Preferences.KEY_VOTE_POST_DIALOG_CHECKED) ?? false);
}

class TaggedListScreenViewModel extends StateNotifier<TaggedListScreenModelState> {
  TaggedListScreenViewModel(TaggedListScreenModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    getPosts(null);
    getTagDetail();
  }

  void getTagDetail({Function(HoohApiErrorResponse error)? callback}) {
    network.requestAsync<TagDetailResponse>(
      network.getTagDetail(state.tagName),
      (data) {
        updateState(state.copyWith(postCount: data.postCount, tagName: data.name));
      },
      (error) {
        if (callback != null) {
          callback(error);
        }
      },
    );
  }

  void getPosts(Function(PageState)? callback, {bool isRefresh = true}) {
    if (isRefresh) {
      updateState(state.copyWith(lastTimestamp: null, page: 1));
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

    network.requestAsync<List<Post>>(network.getTaggedPosts(state.tagName, trending: state.isTrending, page: state.page, date: date), (newData) {
      if (newData.isEmpty) {
        //no data
        if (isRefresh) {
          updateState(state.copyWith(pageState: isRefresh ? PageState.empty : PageState.noMore, posts: []));
        } else {
          updateState(state.copyWith(pageState: isRefresh ? PageState.empty : PageState.noMore));
        }
        // debugPrint("${state.pageState}");
      } else {
        //has data
        if (isRefresh) {
          updateState(state.copyWith(
            pageState: PageState.dataLoaded,
            page: state.page + 1,
            lastTimestamp: newData.last.createdAt,
            posts: newData,
          ));
        } else {
          updateState(state.copyWith(
            pageState: PageState.dataLoaded,
            page: state.page + 1,
            lastTimestamp: newData.last.createdAt,
            posts: [...state.posts, ...newData],
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

  void setTrending(bool trending) {
    updateState(state.copyWith(isTrending: trending));
  }

  void setScrollDistance(double distance) {
    updateState(state.copyWith(scrollDistance: distance));
  }

  void updatePostData(Post post, int index) {
    List<Post> list = [...state.posts];
    list[index] = post;
    updateState(state.copyWith(posts: list));
  }
}
