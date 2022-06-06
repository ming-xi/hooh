import 'dart:math';

import 'package:app/extensions/extensions.dart';
import 'package:app/ui/widgets/comment_view.dart';
import 'package:app/utils/constants.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/requests.dart';
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
    onRefresh(null);
  }

  void onRefresh(Function(PageState)? callback) {
    getPostInfo(callback);
    getLikes(callback);
    getComments(callback);
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

  void getComments(Function(PageState)? callback, {bool isRefresh = true}) {
    if (isRefresh) {
      updateState(state.copyWith(lastTimestamp: null));
      if (state.commentState == PageState.loading) {
        if (callback != null) {
          callback(state.commentState);
        }
        return;
      }
    } else {
      if (![
        PageState.dataLoaded,
      ].contains(state.commentState)) {
        if (callback != null) {
          callback(state.commentState);
        }
        return;
      }
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
        if (isRefresh) {
          updateState(state.copyWith(commentState: PageState.empty, comments: []));
        } else {
          updateState(state.copyWith(commentState: PageState.noMore));
        }
      } else {
        //has data
        if (isRefresh) {
          updateState(state.copyWith(
            commentState: PageState.dataLoaded,
            lastTimestamp: newData.last.createdAt,
            comments: [...newData],
          ));
        } else {
          updateState(state.copyWith(
            commentState: PageState.dataLoaded,
            lastTimestamp: newData.last.createdAt,
            comments: [...state.comments, ...newData],
          ));
        }
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
          likedUsers: [...newData],
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

  void onPostLikePress(bool newState, void Function(String msg)? onError) {
    if (state.post == null) {
      return;
    }
    Future<void> request = state.post!.liked ? network.cancelLikePost(state.post!.id) : network.likePost(state.post!.id);
    network.requestAsync<void>(request, (data) {
      // to create a new object
      updateState(state.copyWith(post: Post.fromJson((state.post!..liked = newState).toJson())));
    }, (error) {
      if (onError != null) {
        onError(error.message);
      }
    });
  }

  void onCommentLikePress(PostComment comment, bool newState, void Function(String msg)? onError) {
    Future<void> request = newState ? network.likePostComment(comment.id) : network.cancelLikePostComment(comment.id);
    network.requestAsync<void>(request, (data) {
      comment.liked = newState;
      if (newState) {
        comment.likeCount = comment.likeCount + 1;
      } else {
        comment.likeCount = max(comment.likeCount - 1, 0);
      }
      updateState(state.copyWith(comments: [...state.comments]));
    }, (error) {
      if (onError != null) {
        onError(error.message);
      }
    });
  }

  void onPostFavoritePress(bool newState, void Function(String msg)? onError) {
    // if (state.post==null) {
    //   return;
    // }
    // Future<void> request = state.post!.favorited ? network.cancelLikePost(state.post!.id) : network.likePost(state.post!.id);
    // network.requestAsync<void>(request, (data) {
    //   updateState(state.copyWith(post: state.post!..liked=newState));
    // }, (error) {
    //   if (onError!=null) {
    //     onError(error.message);
    //   }
    // });
  }

  void onPostSharePress() {}

  void createComment(PostComment? repliedComment, String text, void Function()? onComplete, void Function(String msg)? onError) {
    Future<PostComment> request;
    // CreatePostCommentRequest createPostCommentRequest = CreatePostCommentRequest([], getEscapedString(text));
    CreatePostCommentRequest createPostCommentRequest = prepareCommentRequest(text);
    if (repliedComment != null) {
      request = network.replyComment(repliedComment.id, createPostCommentRequest);
    } else {
      request = network.createPostComment(state.postId, createPostCommentRequest);
    }
    network.requestAsync<PostComment>(request, (data) {
      updateState(state.copyWith(comments: [data, ...state.comments], post: Post.fromJson((state.post!..commentCount += 1).toJson())));
      if (onComplete != null) {
        onComplete();
      }
    }, (error) {
      if (onError != null) {
        onError(error.message);
      }
    });
  }

  String getEscapedString(String text) {
    return text.replaceAll(CommentView.SUBSTITUTE, CommentView.SUBSTITUTE_REGEX);
  }

  CreatePostCommentRequest prepareCommentRequest(String text) {
    CreatePostCommentRequest request;
    String content = text.replaceAll(CommentView.SUBSTITUTE, CommentView.SUBSTITUTE_REGEX);
    List<RegExpMatch> allMatches = RegExp(Constants.URL_REGEX).allMatches(content).toList();
    List<Substitute> substitutes = [];
    for (int i = allMatches.length - 1; i >= 0; i--) {
      RegExpMatch match = allMatches[i];
      int start = match.start;
      int end = match.end;
      String text = content.substring(start, end);
      content = content.replaceRange(start, end, CommentView.SUBSTITUTE);
      substitutes.add(Substitute(text, text, Substitute.TYPE_URL));
    }
    request = CreatePostCommentRequest(substitutes, content);
    return request;
  }
}
