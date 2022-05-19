import 'package:app/global.dart';
import 'package:app/ui/pages/feeds/comment_page.dart';
import 'package:app/ui/pages/feeds/post_detail_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/comment_compose_view.dart';
import 'package:app/ui/widgets/comment_compose_view_model.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/post.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<PostDetailScreenViewModel, PostDetailScreenModelState> provider;

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

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      PostDetailScreenViewModel model = ref.read(widget.provider.notifier);
      model.changeTab(tabController.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double userBarHeight = 40;
    double tabbarHeight = 44;
    double tagsPaddingTop = 12;
    double tagsPaddingBottom = 20;
    double tagsRunSpacing = 4;
    double statusbarHeight = MediaQuery.of(context).viewPadding.top;
    PostDetailScreenModelState modelState = ref.watch(widget.provider);
    PostDetailScreenViewModel model = ref.read(widget.provider.notifier);
    List<Widget> widgets = [
      AspectRatio(
        aspectRatio: 1,
        child: modelState.post == null ? Container() : HoohImage(imageUrl: modelState.post!.images[0].imageUrl),
      ),
      Visibility(
        visible: (modelState.post?.tags ?? []).isNotEmpty,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 20),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: (modelState.post?.tags ?? [])
                      // .expand((e) => [e,e,e])
                      .map((e) => Text(
                            "# $e",
                            style: TextStyle(fontSize: 14, color: designColors.blue_dark.auto(ref)),
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
    var column = Column(
      mainAxisSize: MainAxisSize.max,
      children: widgets,
    );
    var commentTabText = "Comments ${formatAmount(modelState.post?.commentCount ?? 0)}";
    var likeTabText = "Likes ${formatAmount(modelState.post?.likeCount ?? 0)}";
    debugPrint("commentTabText=$commentTabText likeTabText=$likeTabText");
    debugPrint("modelState.selectedTab=${modelState.selectedTab}");
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
    return Scaffold(
      // appBar: AppBar(
      //
      //   title: Text("Post Detail"),
      //   bottom: PreferredSize(
      //     preferredSize: Size.fromHeight(screenWidth + userBarHeight),
      //     child: Column(
      //       mainAxisSize: MainAxisSize.max,
      //       children: widgets,
      //     ),
      //   ),
      // ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                // SliverPersistentHeader(
                //   delegate: SectionHeaderDelegate("Section B"),
                //   pinned: true,
                // ),
                SliverAppBar(
                  title: Text(""),
                  // flexibleSpace: FlexibleSpaceBar(
                  // expandedTitleScale: 1,
                  // background: column,
                  // title: Text(""),
                  // titlePadding: EdgeInsets.zero,
                  // title: SizedBox(
                  //   width: screenWidth,
                  //     height: tabbarHeight,
                  //     child: Padding(
                  //       padding: EdgeInsets.only(left: tabbarHeight),
                  //       child: Container(
                  //         child: tabBar,
                  //         color: designColors.light_01.auto(ref),
                  //       ),
                  //     )),
                  // ),
                  // expandedHeight: screenWidth + userBarHeight + statusbarHeight + 1,
                  pinned: true,
                  // bottom:  PreferredSize(
                  //       preferredSize: Size.fromHeight(screenWidth + userBarHeight),
                  //       child: column,
                  //     ),
                ),

                SliverToBoxAdapter(
                  child: column,
                ),
                SliverPersistentHeader(
                  delegate: _SliverTabBarDelegate(tabBar, ref),
                  pinned: true,
                ),
                SliverFillRemaining(
                  child: TabBarView(controller: tabController, children: [
                    CommentPage(comments: modelState.comments, onLikeClick: (comment, newState) {}, onReplyClick: (comment) {}),
                    Container(
                      color: Colors.blue,
                    ),
                  ]),
                )
              ],
            ),
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
                  child: CommentComposeView(provider: StateNotifierProvider((ref) {
                    return CommentComposeWidgetViewModel(CommentComposeWidgetModelState.init(modelState.post!));
                  })))
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
      HoohImage(
        imageUrl: author.avatarUrl!,
        cornerRadius: 100,
        width: 32,
        height: 32,
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
          "Follow",
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
    debugPrint("build");
    return Container(
      decoration: BoxDecoration(color: designColors.bar90_1.auto(ref), border: Border(bottom: BorderSide(color: designColors.light_02.auto(ref), width: 1))),
      child: tabBar,
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
