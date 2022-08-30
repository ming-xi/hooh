import 'package:app/global.dart';
import 'package:app/ui/pages/feeds/followed_users_view_model.dart';
import 'package:app/ui/pages/home/feeds.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/home/home_view_model.dart';
import 'package:app/ui/pages/user/register/start.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/post_view.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FollowedUserPostsPage extends ConsumerStatefulWidget {
  final StateNotifierProvider<FollowedUserPostsPageViewModel, FollowedUserPostsPageModelState> provider = StateNotifierProvider((ref) {
    User? user = ref.watch(globalUserInfoProvider);
    debugPrint("provider update");
    return FollowedUserPostsPageViewModel(FollowedUserPostsPageModelState.init(user));
  });

  FollowedUserPostsPage({
    Key? key,
  }) : super(key: key) {}

  @override
  ConsumerState createState() => _FollowedUserPostsPageState();
}

class _FollowedUserPostsPageState extends ConsumerState<FollowedUserPostsPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  ScrollController scrollController = ScrollController();
  late void Function() listener;
  bool listVisible = false;

  @override
  void initState() {
    super.initState();
    listener = () {
      if (!scrollController.position.isScrollingNotifier.value) {
        FollowedUserPostsPageViewModel model = ref.read(widget.provider.notifier);
        model.setScrollDistance(scrollController.offset);
      } else {
        // print('scroll is started');
      }
    };
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (!scrollController.hasClients) {
        setState(() {
          //防止list闪动
          listVisible = true;
        });
        return;
      }
      scrollController.position.isScrollingNotifier.addListener(listener);
      FollowedUserPostsPageModelState modelState = ref.read(widget.provider);
      scrollController.jumpTo(modelState.scrollDistance);
      setState(() {
        //防止list闪动
        listVisible = true;
      });
    });
  }

  // @override
  // void dispose() {
  //   scrollController.position.isScrollingNotifier.removeListener(listener);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    FollowedUserPostsPageModelState modelState = ref.watch(widget.provider);
    FollowedUserPostsPageViewModel model = ref.read(widget.provider.notifier);
    var listView = ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.only(top: FeedsPage.LIST_TOP_PADDING, bottom: FeedsPage.LIST_BOTTOM_PADDING, left: 20, right: 20),
      itemBuilder: (context, index) {
        return Opacity(
            opacity: listVisible ? 1 : 0.0001,
            child: index == 0
                ? buildHeaderView(context, model, modelState)
                : buildPostView(
                    context,
                    index - 1,
                    model,
                    modelState,
                  ));
      },
      itemCount: modelState.posts.length + 1,
      separatorBuilder: (context, index) {
        return SizedBox(
          height: index == 0 ? 16 : 32,
        );
      },
    );
    var notLoginView = buildNotLoginView();
    var noFollowingView = buildNoFollowingView();
    Widget refreshChild;
    switch (modelState.viewState) {
      case FollowedUserPostsPageModelState.STATE_NORMAL:
        {
          refreshChild = listView;
          break;
        }
      case FollowedUserPostsPageModelState.STATE_NOT_LOGIN:
        {
          refreshChild = notLoginView;
          break;
        }
      case FollowedUserPostsPageModelState.STATE_NO_FOLLOWING:
        {
          refreshChild = noFollowingView;
          break;
        }
      default:
        {
          refreshChild = Container();
        }
    }
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: MainStyles.getRefresherHeader(
                ref,
              ),
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
              child: refreshChild,
            ),
          ),
          Positioned(
              bottom: 16,
              right: 20,
              child: SafeArea(
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
              ))),
        ],
      ),
    );
  }

  Widget buildNoFollowingView() {
    return MainStyles.buildEmptyView(
        ref: ref,
        text: globalLocalizations.user_posts_no_following_title,
        buttonText: globalLocalizations.user_posts_no_following_button,
        buttonOnClick: () {
          HomePageViewModel model = ref.read(homePageProvider.notifier);
          model.updateTabIndex(HomeScreen.PAGE_INDEX_FEEDS);
          model.updateFeedsTabIndex(FeedsPage.PAGE_INDEX_MAIN, notifyController: true);
        });
    // return Center(
    //   child: Padding(
    //     padding: const EdgeInsets.all(48.0),
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         HoohIcon(
    //           "assets/images/figure_not_login_face.svg",
    //           width: 64,
    //           color: designColors.dark_03.auto(ref),
    //         ),
    //         SizedBox(
    //           height: 12,
    //         ),
    //         Text(
    //           globalLocalizations.user_posts_no_following_title,
    //           style: TextStyle(
    //             fontSize: 20,
    //             color: designColors.dark_03.auto(ref),
    //             fontWeight: FontWeight.bold,
    //           ),
    //           textAlign: TextAlign.center,
    //         ),
    //         SizedBox(
    //           height: 32,
    //         ),
    //         MainStyles.gradientButton(ref, globalLocalizations.user_posts_no_following_button, () {
    //           HomePageViewModel model = ref.read(homePageProvider.notifier);
    //           model.updateTabIndex(HomeScreen.PAGE_INDEX_FEEDS);
    //           model.updateFeedsTabIndex(FeedsPage.PAGE_INDEX_MAIN, notifyController: true);
    //         })
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget buildNotLoginView() {
    return MainStyles.buildEmptyView(
        ref: ref,
        text: globalLocalizations.user_posts_not_login_title,
        buttonText: globalLocalizations.user_posts_not_login_button,
        buttonOnClick: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
        });
    // return Center(
    //   child: Padding(
    //     padding: const EdgeInsets.all(48.0),
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         HoohIcon(
    //           "assets/images/figure_not_login_face.svg",
    //           width: 64,
    //           color: designColors.dark_03.auto(ref),
    //         ),
    //         SizedBox(
    //           height: 12,
    //         ),
    //         Text(globalLocalizations.user_posts_not_login_title,
    //             textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: designColors.dark_03.auto(ref), fontWeight: FontWeight.bold)),
    //         SizedBox(
    //           height: 80,
    //         ),
    //         MainStyles.gradientButton(ref, globalLocalizations.user_posts_not_login_button, () {
    //           Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
    //         })
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget buildHeaderView(BuildContext context, FollowedUserPostsPageViewModel model, FollowedUserPostsPageModelState modelState) {
    return SizedBox(
      width: 1,
      height: 1,
    );
    // 隐去最新最热切换按钮
    // return Row(
    //   children: [
    //     Spacer(),
    //     buildHeaderButtonView(model, false, !modelState.isTrending),
    //     buildHeaderButtonView(model, true, modelState.isTrending),
    //     Spacer(),
    //   ],
    // );
  }

  Widget buildHeaderButtonView(FollowedUserPostsPageViewModel model, bool trending, bool selected) {
    return SizedBox(
      width: Constants.SECTION_BUTTON_WIDTH,
      height: Constants.SECTION_BUTTON_HEIGHT,
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: !selected ? null : BoxDecoration(color: designColors.feiyu_yellow.auto(ref), borderRadius: BorderRadius.circular(100)),
          child: InkWell(
            onTap: () {
              model.setTrending(trending);
              _refreshController.requestRefresh();
            },
            borderRadius: BorderRadius.circular(100),
            child: Center(
              child: Text(
                trending ? globalLocalizations.common_trending : globalLocalizations.common_recent,
                style: TextStyle(color: selected ? Colors.white : designColors.light_06.auto(ref)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPostView(BuildContext context, int index, FollowedUserPostsPageViewModel model, FollowedUserPostsPageModelState modelState) {
    return PostView(
      post: modelState.posts[index],
      // onShare: (post, error) {
      //   if (error != null) {
      //     showCommonRequestErrorDialog(ref, context, error);
      //     // showSnackBar(context, error.message);
      //     return;
      //   }
      //   showSnackBar(context, "share...");
      // },
      onLike: (post, error) {
        if (error != null) {
          showCommonRequestErrorDialog(ref, context, error);
          // showSnackBar(context, error.message);
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
          // showSnackBar(context, error.message);
          showCommonRequestErrorDialog(ref, context, error);
          return;
        }
        post.author.followed = true;
        model.updatePostData(post, index);
      },
    );
  }
}
