import 'package:app/global.dart';
import 'package:app/ui/pages/me/notifications_view_model.dart';
import 'package:app/ui/pages/user/posts_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/post_view.dart';
import 'package:app/ui/widgets/system_notification_view.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/page_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserPostsScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<UserPostsScreenViewModel, UserPostsScreenModelState> provider;

  UserPostsScreen({
    required String userId,
    required int type,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return UserPostsScreenViewModel(UserPostsScreenModelState.init(userId, type));
    });
  }

  @override
  ConsumerState createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends ConsumerState<UserPostsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    UserPostsScreenModelState modelState = ref.watch(widget.provider);
    UserPostsScreenViewModel model = ref.read(widget.provider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(globalLocalizations.user_profile_posts)),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: MainStyles.getRefresherHeader(ref),
        onRefresh: () async {
          model.getPosts((state) {
            // debugPrint("refresh state=$state");
            _refreshController.refreshCompleted();
            _refreshController.resetNoData();
          });
        },
        onLoading: () async {
          model.getPosts((state) {
            if (state == PageState.noMore) {
              _refreshController.loadNoData();
              // debugPrint("load no more state=$state");
            } else {
              _refreshController.loadComplete();
              // debugPrint("load complete state=$state");
            }
          }, isRefresh: false);
        },
        controller: _refreshController,
        child: ListView.separated(
          separatorBuilder: (context, index) => SizedBox(
            height: 32,
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemBuilder: (context, index) {
            return PostView(
              post: modelState.posts[index],
              onShare: (post, error) {
                Toast.showSnackBar(context, "share...");
              },
              onLike: (post, error) {
                if (error != null) {
                  // Toast.showSnackBar(context, error.message);
                  showCommonRequestErrorDialog(ref, context, error);
                  return;
                }
                if (post.liked) {
                  post.likeCount -= 1;
                } else {
                  post.likeCount += 1;
                }
                post.liked = !post.liked;
                model.updatePostData(post, index);
              },
              onFollow: (post, error) {
                if (error != null) {
                  // Toast.showSnackBar(context, error.message);
                  showCommonRequestErrorDialog(ref, context, error);
                  return;
                }
                post.author.followed = true;
                model.updatePostData(post, index);
              },
            );
          },
          itemCount: modelState.posts.length,
        ),
      ),
    );
  }
}
