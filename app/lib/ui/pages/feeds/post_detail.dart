import 'package:app/global.dart';
import 'package:app/ui/pages/feeds/comment_page.dart';
import 'package:app/ui/pages/feeds/likes_page.dart';
import 'package:app/ui/pages/feeds/post_detail_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/comment_compose_view.dart';
import 'package:app/ui/widgets/comment_compose_view_model.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/post.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/refresh_indicator.dart' as refresh;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<PostDetailScreenViewModel, PostDetailScreenModelState> provider;
  final FocusNode textFieldNode = FocusNode();

  PostDetailScreen({
    required String postId,
    Post? post,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return PostDetailScreenViewModel(PostDetailScreenModelState.init(postId, post: post));
    });
  }

  @override
  ConsumerState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> with TickerProviderStateMixin {
  late TabController tabController;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  ScrollController scrollController = ScrollController();
  GlobalKey columnKey = GlobalKey();
  double headerHeight = 100;
  bool scrollable = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      PostDetailScreenViewModel model = ref.read(widget.provider.notifier);
      model.changeTab(tabController.index);
    });
    scrollController.addListener(() {
      final keyContext = columnKey.currentContext;
      if (keyContext != null) {
        final RenderBox box = keyContext.findRenderObject() as RenderBox;
        // debugPrint("offset=${scrollController.offset} box.size.height=${box.size.height}");
        headerHeight = box.size.height;
        bool newState = scrollController.offset > headerHeight;
        if (newState != scrollable) {
          setState(() {
            scrollable = newState;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double userBarHeight = 40;
    double tabbarHeight = 44;
    double tagsPaddingTop = 12;
    double tagsPaddingBottom = 20;
    double tagsRunSpacing = 4;
    double statusbarHeight = MediaQuery.of(context).viewPadding.top;

    bool keyboardVisible = ref.watch(globalKeyboardInfoProvider);
    debugPrint("keyboardVisible=$keyboardVisible");
    PostDetailScreenModelState modelState = ref.watch(widget.provider);
    PostDetailScreenViewModel model = ref.read(widget.provider.notifier);
    StateNotifierProvider<CommentComposeWidgetViewModel, CommentComposeWidgetModelState> composerProvider = StateNotifierProvider((ref) {
      return CommentComposeWidgetViewModel(CommentComposeWidgetModelState.init(post: modelState.post!));
    });
    List<Widget> widgets = [
      AspectRatio(
        aspectRatio: 1,
        child: modelState.post == null ? Container() : HoohImage(imageUrl: modelState.post!.images[0].imageUrl),
      ),
      Visibility(
        visible: (modelState.post?.tags ?? []).isNotEmpty,
        replacement: SizedBox(
          height: 16,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 20),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: (modelState.post?.tags ?? [])
                      // .expand((e) => [e,e,e])
                      .map((e) => TextButton(
                            onPressed: () {
                              Toast.showSnackBar(context, "to topic: $e");
                            },
                            style: TextButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                minimumSize: Size(48, 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            child: Text(
                              "# $e",
                              style: TextStyle(fontSize: 14, color: designColors.blue_dark.auto(ref)),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
    if (modelState.post != null) {
      widgets.add(buildUserInfoRow(modelState.post!));
    }
    // widgets.add(SizedBox(
    //   height: tabbarHeight,
    // ));
    // widgets.add(
    //   TabBar(
    //     controller: tabController,
    //     tabs: [
    //       Tab(
    //         icon: Text(
    //           "Comments ${modelState.post?.commentCount ?? ""}",
    //           style: TextStyle(color: modelState.selectedTab == 0 ? designColors.dark_01.auto(ref) : designColors.dark_03.auto(ref)),
    //         ),
    //       ),
    //       Tab(
    //         icon: Text(
    //           "Likes ${modelState.post?.likeCount ?? ""}",
    //           style: TextStyle(color: modelState.selectedTab == 0 ? designColors.dark_01.auto(ref) : designColors.dark_03.auto(ref)),
    //         ),
    //       ),
    //     ],
    //     // indicatorColor: designColors.dark_01.auto(ref),
    //     // indicatorSize: TabBarIndicatorSize.label,
    //   ),
    // );

    Widget column = Column(
      key: columnKey,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
    var commentTabText = sprintf(globalLocalizations.post_detail_comment_count, [formatAmount(modelState.post?.commentCount ?? 0)]);
    var likeTabText = sprintf(globalLocalizations.post_detail_like_count, [formatAmount(modelState.post?.likeCount ?? 0)]);

    // debugPrint("commentTabText=$commentTabText likeTabText=$likeTabText");
    // debugPrint("modelState.selectedTab=${modelState.selectedTab}");
    TabBar tabBar = TabBar(
      controller: tabController,
      isScrollable: true,
      tabs: [
        Tab(
          icon: Text(
            commentTabText,
            style: TextStyle(
                color: modelState.selectedTab == 0 ? designColors.dark_01.auto(ref) : designColors.light_06.auto(ref),
                fontWeight: modelState.selectedTab == 0 ? FontWeight.bold : FontWeight.normal),
          ),
        ),
        Tab(
          icon: Text(
            likeTabText,
            style: TextStyle(
                color: modelState.selectedTab == 1 ? designColors.dark_01.auto(ref) : designColors.light_06.auto(ref),
                fontWeight: modelState.selectedTab == 1 ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ],
      // indicatorColor: designColors.dark_01.auto(ref),
      // indicatorSize: TabBarIndicatorSize.label,
    );

    TabBarView tabBarView = TabBarView(controller: tabController, children: [
      CommentPage(
          scrollable: scrollable,
          comments: modelState.comments,
          onLikeClick: (comment, newState) {},
          onLoadMore: () {
            model.getComments((state) {
              // debugPrint("refresh state=$state");
              _refreshController.refreshCompleted();
            }, isRefresh: false);
          },
          noMore: modelState.commentState == PageState.noMore,
          onReplyClick: (comment) {
            CommentComposeWidgetViewModel composerModel = ref.read(composerProvider.notifier);
            composerModel.setRepliedComment(comment);
            showKeyboard(ref, widget.textFieldNode);
          }),
      LikesPage(users: modelState.likedUsers)
    ]);
    SliverAppBar sliverAppBar = SliverAppBar(
      title: Text(""),
      pinned: true,
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: refresh.RefreshIndicator(
            notificationPredicate: (notification) {
              return notification.depth == 2;
            },
            onRefresh: () async {
              model.onRefresh((state) {
                // debugPrint("refresh state=$state");
                _refreshController.refreshCompleted();
              });
            },
            child: NestedScrollView(
              headerSliverBuilder: (a, b) => [
                sliverAppBar,
                SliverToBoxAdapter(
                  child: column,
                ),
                SliverPersistentHeader(
                  delegate: _SliverTabBarDelegate(tabBar, ref),
                  pinned: true,
                ),
              ],
              body: tabBarView,
            ),
          )

              // CustomScrollView(
              //   controller: scrollController,
              //   slivers: [
              //     // SliverPersistentHeader(
              //     //   delegate: SectionHeaderDelegate("Section B"),
              //     //   pinned: true,
              //     // ),
              //     sliverAppBar,
              //
              //     SliverToBoxAdapter(
              //       child: column,
              //     ),
              //     SliverPersistentHeader(
              //       delegate: _SliverTabBarDelegate(tabBar, ref),
              //       pinned: true,
              //     ),
              //     // SliverFillRemaining(
              //     //   child: tabBarView,
              //     // ),
              //     SliverPersistentHeader(
              //       delegate: _SliverTabViewDelegate(tabBarView, screenHeight - statusbarHeight - sliverAppBar.toolbarHeight - tabbarHeight),
              //       // pinned: true,
              //     ),
              //   ],
              // ),
              ),
          modelState.post == null
              ? SizedBox(
                  height: 1,
                  width: 1,
                )
              : Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CommentComposeView(
                    provider: composerProvider,
                    textFieldNode: widget.textFieldNode,
                    onLikePress: model.onPostLikePress,
                    onFavoritePress: model.onPostFavoritePress,
                    onSharePress: model.onPostSharePress,
                    onSendPress: (comment, text, onComplete, onError) {
                      model.createComment(comment, text, onComplete, onError);
                      hideKeyboard();
                    },
                  ))
        ],
      ),

      // body: TabBarView(controller: tabController, children: [
      //   Container(
      //     color: Colors.red,
      //   ),
      //   Container(
      //     color: Colors.blue,
      //   ),
      // ]),
    );
  }

  Widget buildUserInfoRow(Post post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Builder(builder: (context) {
        List<Widget> widgets = buildUserInfo(post);
        widgets.add(SizedBox(
          width: 8,
        ));
        Widget? followButton = buildFollowButton(post);
        if (followButton != null) {
          widgets.add(followButton);
        } else {
          widgets.add(SizedBox(
            height: 40,
          ));
        }
        return Row(
          children: widgets,
        );
      }),
    );
  }

  List<Widget> buildUserInfo(Post post) {
    User author = post.author;
    return [
      AvatarView.fromUser(
        author,
        size: 32,
      ),
      SizedBox(
        width: 8,
      ),
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              author.name,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: designColors.dark_00.auto(ref)),
            ),
            Text(
              DateUtil.getZonedDateString(post.createdAt),
              style: TextStyle(fontSize: 10, color: designColors.light_06.auto(ref)),
            ),
          ],
        ),
      ),
    ];
  }

  Widget? buildFollowButton(Post post) {
    User? user = ref.watch(globalUserInfoProvider.state).state;
    User author = post.author;
    if ((author.followed ?? false) || (user?.id == author.id)) {
      return null;
    }
    return _buildButton(
        text: Text(
          globalLocalizations.common_follow,
          style: TextStyle(fontFamily: 'Linotte'),
        ),
        isEnabled: (post.myVoteCount ?? 0) == 0,
        onPress: () {
          // onFollowPress(post);
        });
  }

  Widget _buildButton({required Widget text, required bool isEnabled, required Function() onPress}) {
    ButtonStyle style = RegisterStyles.blueButtonStyle(ref, cornerRadius: 14).copyWith(
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        minimumSize: MaterialStateProperty.all(Size.fromHeight(40)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap);
    if (!isEnabled) {
      style = style.copyWith(backgroundColor: MaterialStateProperty.all(designColors.dark_03.auto(ref)));
    }
    return SizedBox(
      width: 120,
      child: TextButton(
        onPressed: onPress,
        child: text,
        style: style,
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final WidgetRef ref;

  _SliverTabBarDelegate(this.tabBar, this.ref);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // debugPrint("build");
    return Container(
      decoration: BoxDecoration(color: designColors.bar90_1.auto(ref), border: Border(bottom: BorderSide(color: designColors.light_02.auto(ref), width: 1))),
      child: Material(child: tabBar),
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return this != oldDelegate;
  }
}

class _SliverTabViewDelegate extends SliverPersistentHeaderDelegate {
  final TabBarView tabBarView;
  final double maxHeight;

  _SliverTabViewDelegate(this.tabBarView, this.maxHeight);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // debugPrint("build");
    return Material(child: tabBarView);
  }

  @override
  // double get maxExtent => tabBarView.preferredSize.height;
  double get maxExtent => maxHeight;

  @override
  // double get minExtent => tabBarView.preferredSize.height;
  double get minExtent => 0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return this != oldDelegate;
  }
}
