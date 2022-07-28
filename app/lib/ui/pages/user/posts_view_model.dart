import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/post.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'posts_view_model.g.dart';

@CopyWith()
class UserPostsScreenModelState {
  final List<Post> posts;
  final PageState pageState;
  final HoohApiErrorResponse? error;
  final DateTime? lastTimestamp;
  final int type;
  final String userId;

  static const TYPE_CREATED = 0;
  static const TYPE_LIKED = 1;
  static const TYPE_FAVORITED = 2;

  UserPostsScreenModelState({
    required this.posts,
    required this.pageState,
    required this.type,
    required this.userId,
    this.error,
    this.lastTimestamp,
  });

  factory UserPostsScreenModelState.init(String id, int type) => UserPostsScreenModelState(
        posts: [],
        type: type,
        userId: id,
        pageState: PageState.inited,
      );
}

class UserPostsScreenViewModel extends StateNotifier<UserPostsScreenModelState> {
  UserPostsScreenViewModel(UserPostsScreenModelState state) : super(state) {
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
    // debugPrint("lastTimestamp=${state.lastTimestamp}");
    Future<List<Post>>? request;
    switch (state.type) {
      case UserPostsScreenModelState.TYPE_CREATED:
        {
          request = network.getUserCreatedPosts(state.userId, date: state.lastTimestamp);
          break;
        }
      case UserPostsScreenModelState.TYPE_LIKED:
        {
          request = network.getUserLikedPosts(state.userId, date: state.lastTimestamp);
          break;
        }
      case UserPostsScreenModelState.TYPE_FAVORITED:
        {
          request = network.getUserFavoritedPosts(state.userId, date: state.lastTimestamp);
          break;
        }
    }
    if (request == null) {
      throw Exception("invalid type:${state.type}");
    }
    network.requestAsync<List<Post>>(request, (newData) {
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
          updateState(state.copyWith(pageState: PageState.dataLoaded, posts: newData, lastTimestamp: newData.last.createdAt));
        } else {
          updateState(state.copyWith(pageState: PageState.dataLoaded, posts: [...state.posts, ...newData], lastTimestamp: newData.last.createdAt));
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

  void updatePostData(Post post, int index) {
    List<Post> list = [...state.posts];
    list[index] = post;
    updateState(state.copyWith(posts: list));
  }
}
