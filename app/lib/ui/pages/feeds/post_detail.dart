import 'package:app/global.dart';
import 'package:app/launcher.dart';
import 'package:app/ui/pages/creation/edit_post.dart';
import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/ui/pages/feeds/comment_page.dart';
import 'package:app/ui/pages/feeds/likes_page.dart';
import 'package:app/ui/pages/feeds/post_detail_view_model.dart';
import 'package:app/ui/pages/user/register/start.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/comment_compose_view.dart';
import 'package:app/ui/widgets/comment_compose_view_model.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/file_utils.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/network/requests.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/post.dart';
import 'package:common/models/template.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/refresh_indicator.dart' as refresh;
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<PostDetailScreenViewModel, PostDetailScreenModelState> provider;
  late StateNotifierProvider<CommentComposeWidgetViewModel, CommentComposeWidgetModelState> composerProvider;
  final FocusNode textFieldNode = FocusNode();

  PostDetailScreen({
    required String postId,
    Post? post,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return PostDetailScreenViewModel(PostDetailScreenModelState.init(postId, post: post));
    });

    composerProvider = StateNotifierProvider((ref) {
      PostDetailScreenModelState modelState = ref.watch(provider);
      return CommentComposeWidgetViewModel(CommentComposeWidgetModelState.init(post: modelState.post!));
    });
  }

  @override
  ConsumerState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> with TickerProviderStateMixin {
  late TabController tabController;

  final RefreshController _refreshController = RefreshController(initialRefresh: true);
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
                fontSize: 12,
                color: modelState.selectedTab == 0 ? designColors.dark_01.auto(ref) : designColors.light_06.auto(ref),
                fontWeight: modelState.selectedTab == 0 ? FontWeight.bold : FontWeight.normal),
          ),
        ),
        Tab(
          icon: Text(
            likeTabText,
            style: TextStyle(
                fontSize: 12,
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
          onLikeClick: (comment, newState) {
            model.onCommentLikePress(comment, newState, (msg) {
              Toast.showSnackBar(context, msg);
            });
          },
          onLoadMore: () {
            model.getComments((state) {
              // debugPrint("refresh state=$state");
              _refreshController.refreshCompleted();
            }, isRefresh: false);
          },
          noMore: modelState.commentState == PageState.noMore,
          onReplyClick: (comment) {
            CommentComposeWidgetViewModel composerModel = ref.read(widget.composerProvider.notifier);
            composerModel.setRepliedComment(comment);
            showKeyboard(ref, widget.textFieldNode);
          }),
      LikesPage(users: modelState.likedUsers)
    ]);
    SliverAppBar sliverAppBar = SliverAppBar(
      title: Text(""),
      actions: [buildMenuButton(model, modelState)],
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
                  delegate: _SliverTabBarDelegate(
                      tabBar,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          HoohIcon(
                            "assets/images/common_ore.svg",
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            sprintf(globalLocalizations.me_wallet_ore_amount, [formatCurrency(modelState.post?.profitInt)]),
                            style: TextStyle(fontSize: 12, color: designColors.light_06.auto(ref)),
                          ),
                          SizedBox(
                            width: 48,
                          )
                        ],
                      ),
                      ref),
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
                    provider: widget.composerProvider,
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

  Widget buildMenuButton(PostDetailScreenViewModel model, PostDetailScreenModelState modelState) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_horiz_rounded,
        color: designColors.dark_01.auto(ref),
      ),
      onSelected: (value) {},
      // offset: Offset(0.0, appBarHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      itemBuilder: (ctx) {
        TextStyle style = TextStyle(fontSize: 16, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold);
        PostImage currentImage = modelState.post!.images[0];

        bool isAdminMode = FlavorConfig.instance.variables[Launcher.KEY_ADMIN_MODE];
        PopupMenuItem itemDownload = PopupMenuItem(
          onTap: () {
            Future.delayed(Duration(milliseconds: 250), () {
              FileUtil.saveNetworkImageToGallery(context, currentImage.imageUrl);
            });
          },
          child: Text(
            globalLocalizations.post_detail_menu_download,
            style: style,
          ),
        );
        String? templateId = currentImage.templateId;
        PopupMenuItem itemUseTemplate = PopupMenuItem(
          onTap: () {
            Future.delayed(Duration(milliseconds: 250), () {
              User? user = ref.read(globalUserInfoProvider);
              if (user == null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
                return;
              }
              network.requestAsync<Template>(network.getTemplateInfo(templateId!), (template) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditPostScreen(setting: PostImageSetting.withTemplate(template))));
              }, (e) {
                Toast.showSnackBar(context, e.devMessage);
              });
            });
          },
          child: Text(
            globalLocalizations.post_detail_menu_use_template,
            style: style,
          ),
        );
        bool newFavorited = !currentImage.templateFavorited!;
        PopupMenuItem itemChangeTemplateFavoriteStatus = PopupMenuItem(
          onTap: () {
            Future.delayed(Duration(milliseconds: 250), () {
              Future<void> request;
              if (newFavorited) {
                request = network.favoriteTemplate(templateId!);
              } else {
                request = network.cancelFavoriteTemplate(templateId!);
              }
              network.requestAsync<void>(request, (_) {
                model.setTemplateFavorited(newFavorited);
                Toast.showSnackBar(
                    context, newFavorited ? globalLocalizations.post_detail_favorite_success : globalLocalizations.post_detail_cancel_favorite_success);
              }, (e) {
                if (kDebugMode) {
                  Toast.showSnackBar(context, e.devMessage);
                } else {
                  Toast.showSnackBar(context, globalLocalizations.post_detail_favorite_failed);
                }
              });
            });
          },
          child: Text(
            newFavorited ? globalLocalizations.post_detail_menu_favorite_template : globalLocalizations.post_detail_menu_cancel_favorite_template,
            style: style,
          ),
        );
        PopupMenuItem itemIntoWaitingList = PopupMenuItem(
          onTap: () {
            Future.delayed(Duration(milliseconds: 250), () {
              network.requestAsync<void>(network.editPost(modelState.postId, EditPostRequest(joinWaitingList: true)), (_) {
                model.setPublishState(Post.PUBLISH_STATE_WAITING_LIST);
                Toast.showSnackBar(context, globalLocalizations.post_detail_join_waiting_list_success);
              }, (e) {
                if (kDebugMode) {
                  Toast.showSnackBar(context, e.devMessage);
                } else {
                  Toast.showSnackBar(context, globalLocalizations.post_detail_join_waiting_list_failed);
                }
              });
            });
          },
          child: Text(
            globalLocalizations.post_detail_menu_into_waiting_list,
            style: style,
          ),
        );
        PopupMenuItem itemReport = PopupMenuItem(
          onTap: () {},
          child: Text(
            globalLocalizations.post_detail_menu_report,
            style: style,
          ),
        );
        PopupMenuItem itemDelete = PopupMenuItem(
          onTap: () {
            Future.delayed(Duration(milliseconds: 250), () {
              network.requestAsync<void>(network.deletePost(modelState.postId), (_) {
                Toast.showSnackBar(context, globalLocalizations.post_detail_delete_post_success);
                Navigator.of(context, rootNavigator: true).pop();
              }, (e) {
                if (kDebugMode) {
                  Toast.showSnackBar(context, e.devMessage);
                } else {
                  Toast.showSnackBar(context, globalLocalizations.post_detail_delete_post_failed);
                }
              });
            });
          },
          child: Text(
            globalLocalizations.post_detail_menu_delete,
            style: style,
          ),
        );
        bool newVisibility = !modelState.post!.visible;
        PopupMenuItem itemChangeVisibility = PopupMenuItem(
          onTap: () {
            Future.delayed(Duration(milliseconds: 250), () {
              network.requestAsync<void>(network.editPost(modelState.postId, EditPostRequest(visible: newVisibility)), (_) {
                Toast.showSnackBar(
                    context, newVisibility ? globalLocalizations.post_detail_set_visible_success : globalLocalizations.post_detail_set_invisible_success);
                model.setPostVisible(newVisibility);
              }, (e) {
                if (kDebugMode) {
                  Toast.showSnackBar(context, e.devMessage);
                } else {
                  Toast.showSnackBar(context, globalLocalizations.post_detail_set_visible_failed);
                }
              });
            });
          },
          child: Text(
            newVisibility ? globalLocalizations.post_detail_menu_make_public : globalLocalizations.post_detail_menu_make_private,
            style: style,
          ),
        );

        PopupMenuItem itemCopyId = PopupMenuItem(
          onTap: () {
            FileUtil.copyToClipboard(modelState.postId);
            Toast.showSnackBar(context, "copied!");
          },
          child: Text(
            "Copy ID",
            style: style,
          ),
        );
        List<PopupMenuItem> items = [];
        if (modelState.post != null) {
          User? user = ref.watch(globalUserInfoProvider);
          if (modelState.post!.author.id == user?.id) {
            items = [
              itemDownload,
              itemUseTemplate,
              itemChangeTemplateFavoriteStatus,
              itemChangeVisibility,
              itemDelete,
            ];
            if (modelState.post!.publishState == Post.PUBLISH_STATE_NORMAL) {
              items.add(itemIntoWaitingList);
            }
          } else {
            items = [
              itemUseTemplate,
              itemChangeTemplateFavoriteStatus,
              itemReport,
            ];
          }
          if (isAdminMode) {
            items.add(itemCopyId);
          }
          if (user == null) {
            // items.remove(itemUseTemplate);
            items.remove(itemChangeTemplateFavoriteStatus);
            items.remove(itemReport);
          }
          if (templateId == null) {
            items.remove(itemUseTemplate);
            items.remove(itemChangeTemplateFavoriteStatus);
          }
        }
        return items;
      },
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
        isEnabled: true,
        onPress: () {
          User? user = ref.read(globalUserInfoProvider);
          if (user == null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
            return;
          }
          PostDetailScreenViewModel model = ref.read(widget.provider.notifier);
          model.onFollowPress(!author.followed!, (msg) {
            Toast.showSnackBar(context, msg);
          });
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
  final Widget rightWidget;
  final WidgetRef ref;

  _SliverTabBarDelegate(this.tabBar, this.rightWidget, this.ref);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // debugPrint("build");
    var stack = Stack(
      children: [Positioned.fill(child: tabBar), Positioned(child: rightWidget)],
    );
    return Container(
      decoration: BoxDecoration(color: designColors.bar90_1.auto(ref), border: Border(bottom: BorderSide(color: designColors.light_02.auto(ref), width: 1))),
      child: Material(
          child: Row(
        children: [tabBar, Spacer(), rightWidget],
      )),
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
