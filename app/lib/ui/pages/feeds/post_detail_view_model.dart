import 'package:app/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/post.dart';
import 'package:common/models/post_comment.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'post_detail_view_model.g.dart';

@CopyWith()
class PostDetailScreenModelState {
  final String postId;
  final Post? post;
  final int selectedTab;
  final List<PostComment> comments;
  final List<User> likedUsers;
  final PageState postState;
  final PageState commentState;
  final PageState likeState;
  final HoohApiErrorResponse? error;
  final DateTime? lastTimestamp;

  PostDetailScreenModelState({
    required this.postId,
    this.post,
    required this.selectedTab,
    required this.comments,
    required this.likedUsers,
    required this.postState,
    required this.commentState,
    required this.likeState,
    required this.error,
    required this.lastTimestamp,
  });

  factory PostDetailScreenModelState.init(String id, {Post? post, int initTab = 0}) => PostDetailScreenModelState(
      postId: id,
      post: post,
      selectedTab: initTab,
      comments: [],
      likedUsers: [],
      postState: PageState.inited,
      commentState: PageState.inited,
      likeState: PageState.inited,
      error: null,
      lastTimestamp: null);
}

class PostDetailScreenViewModel extends StateNotifier<PostDetailScreenModelState> {
  PostDetailScreenViewModel(PostDetailScreenModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    getPostInfo(null);
    getLikes(null);
    getComments(null);
  }

  void getPostInfo(Function(PageState)? callback) {
    if (state.postState == PageState.loading) {
      if (callback != null) {
        callback(state.postState);
      }
      return;
    }
    updateState(state.copyWith(postState: PageState.loading));
    network.requestAsync<Post>(network.getPostInfo(state.postId), (newData) {
      updateState(state.copyWith(post: newData, postState: PageState.dataLoaded));
      if (callback != null) {
        callback(state.postState);
      }
    }, (error) {
      updateState(state.copyWith(
        error: error,
        postState: PageState.inited,
      ));
      if (callback != null) {
        callback(state.postState);
      }
    });
  }

  void getComments(Function(PageState)? callback) {
    if (state.commentState == PageState.loading) {
      if (callback != null) {
        callback(state.commentState);
      }
      return;
    }

    updateState(state.copyWith(commentState: PageState.loading));
    DateTime date = state.lastTimestamp ?? DateUtil.getCurrentUtcDate();
    network.requestAsync<List<PostComment>>(
        network.getPostComments(
          state.postId,
          date: date,
        ), (newData) {
      if (newData.isEmpty) {
        //no data
        updateState(state.copyWith(commentState: state.lastTimestamp == null ? PageState.empty : PageState.noMore));
      } else {
        //has data
        updateState(state.copyWith(
          commentState: PageState.dataLoaded,
          lastTimestamp: newData.last.createdAt,
          comments: [...state.comments, ...newData],
        ));
      }
      if (callback != null) {
        callback(state.commentState);
      }
    }, (error) {
      updateState(state.copyWith(
        error: error,
        commentState: PageState.inited,
      ));
      if (callback != null) {
        callback(state.commentState);
      }
    });
  }

  void getLikes(Function(PageState)? callback) {
    if (state.likeState == PageState.loading) {
      if (callback != null) {
        callback(state.likeState);
      }
      return;
    }
    updateState(state.copyWith(likeState: PageState.loading));
    network.requestAsync<List<User>>(
        network.getPostLikes(
          state.postId,
        ), (newData) {
      if (newData.isEmpty) {
        //no data
        updateState(state.copyWith(likeState: PageState.empty));
      } else {
        //has data
        updateState(state.copyWith(
          likeState: PageState.dataLoaded,
          likedUsers: [...state.likedUsers, ...newData],
        ));
      }
      if (callback != null) {
        callback(state.likeState);
      }
    }, (error) {
      updateState(state.copyWith(
        error: error,
        likeState: PageState.inited,
      ));
      if (callback != null) {
        callback(state.likeState);
      }
    });
  }

  void changeTab(int newTab) {
    updateState(state.copyWith(selectedTab: newTab));
  }
}
