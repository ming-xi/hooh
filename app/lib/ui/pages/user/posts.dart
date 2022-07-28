import 'package:app/global.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/ui/pages/user/posts_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/empty_views.dart';
import 'package:app/ui/widgets/post_view.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/page_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserPostsScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<UserPostsScreenViewModel, UserPostsScreenModelState> provider;
  final String title;
  final int type;

  UserPostsScreen({
    required this.title,
    required this.type,
    required String userId,
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
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    UserPostsScreenModelState modelState = ref.watch(widget.provider);
    UserPostsScreenViewModel model = ref.read(widget.provider.notifier);
    String emptyViewText;
    switch (widget.type) {
      case UserPostsScreenModelState.TYPE_CREATED:
        {
          emptyViewText = globalLocalizations.empty_view_no_created_posts;
          break;
        }
      case UserPostsScreenModelState.TYPE_LIKED:
        {
          emptyViewText = globalLocalizations.empty_view_no_liked_posts;
          break;
        }
      case UserPostsScreenModelState.TYPE_FAVORITED:
        {
          emptyViewText = globalLocalizations.empty_view_no_favorites;
          break;
        }
      default:
        {
          emptyViewText = "";
        }
    }
    return Scaffold(
      appBar: HoohAppBar(title: Text(widget.title)),
      floatingActionButton: SafeArea(
          child: SizedBox(
        width: 40,
        height: 40,
        child: FloatingActionButton(
            backgroundColor: designColors.feiyu_blue.auto(ref),
            onPressed: () {
              scrollController.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.easeOutCubic);
            },
            child: HoohIcon(
              "assets/images/icon_back_to_top.svg",
              width: 16,
              color: designColors.light_01.light,
            )),
      )),
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
        child: modelState.posts.isEmpty
            ? EmptyView(text: emptyViewText)
            : ListView.separated(
          controller: scrollController,
                separatorBuilder: (context, index) => SizedBox(
                  height: 32,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemBuilder: (context, index) {
                  return PostView(
                    post: modelState.posts[index],
                    // onShare: (post, error) {
                    //   Toast.showSnackBar(context, "share...");
                    // },
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
