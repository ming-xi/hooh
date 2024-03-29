import 'package:app/global.dart';
import 'package:app/launcher.dart';
import 'package:app/ui/pages/creation/edit_post.dart';
import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/ui/pages/feeds/comment_page.dart';
import 'package:app/ui/pages/feeds/likes_page.dart';
import 'package:app/ui/pages/feeds/post_detail_view_model.dart';
import 'package:app/ui/pages/misc/share.dart';
import 'package:app/ui/pages/user/register/start.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/ui/widgets/comment_compose_view.dart';
import 'package:app/ui/widgets/comment_compose_view_model.dart';
import 'package:app/ui/widgets/empty_views.dart';
import 'package:app/ui/widgets/post_view.dart';
import 'package:app/utils/constants.dart';
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
import 'package:common/utils/ui_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/refresh_indicator.dart' as refresh;
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<PostDetailScreenViewModel, PostDetailScreenModelState> provider;
  late final StateNotifierProvider<CommentComposeWidgetViewModel, CommentComposeWidgetModelState> composerProvider;
  final FocusNode textFieldNode = FocusNode();

  PostDetailScreen({
    required String postId,
    Post? post,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return PostDetailScreenViewModel(PostDetailScreenModelState.init(postId, ref.watch(globalUserInfoProvider), post: post));
    });

    composerProvider = StateNotifierProvider((ref) {
      PostDetailScreenModelState modelState = ref.watch(provider);
      return CommentComposeWidgetViewModel(CommentComposeWidgetModelState.init(
        post: modelState.post!,
      ));
    });
  }

  @override
  ConsumerState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> with TickerProviderStateMixin {
  late TabController tabController;

  final RefreshController _refreshController = RefreshController(initialRefresh: true);
  ScrollController scrollController = ScrollController();
  ScrollController scrollController2 = ScrollController();
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
    PostDetailScreenModelState modelState = ref.watch(widget.provider);
    PostDetailScreenViewModel model = ref.read(widget.provider.notifier);
    if (modelState.error != null && modelState.error!.errorCode == Constants.RESOURCE_NOT_FOUND) {
      return Scaffold(
        appBar: HoohAppBar(title: const Text("")),
        body: ErrorView(
          text: globalLocalizations.error_view_post_not_found,
        ),
      );
    }
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double userBarHeight = 40;
    double tabbarHeight = 44;
    double tagsPaddingTop = 12;
    double tagsPaddingBottom = 20;
    double tagsRunSpacing = 4;
    double statusbarHeight = MediaQuery.of(context).viewPadding.top;

    bool keyboardVisible = ref.watch(globalKeyboardVisibilityProvider);
    List<Widget> widgets = [
      AspectRatio(
        aspectRatio: 1,
        child: modelState.post == null ? Container() : HoohImage(imageUrl: modelState.post!.images[0].imageUrl),
      ),
      Visibility(
        visible: (modelState.post?.tags ?? []).isNotEmpty,
        replacement: const SizedBox(
          height: 16,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 20, top: 12, bottom: 20),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 2,
                  runSpacing: 4,
                  children: (modelState.post?.tags ?? [])
                      // .expand((e) => [e,e,e])
                      .map((e) => TagView(tagName: e))
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
    widgets.add(const SizedBox(
      height: 16,
    ));
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
          User? user = ref.read(globalUserInfoProvider);
          if (user == null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
            return;
          }
          model.onCommentLikePress(comment, newState, (error) {
            // showSnackBar(context, msg);
            showCommonRequestErrorDialog(ref, context, error);
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
        },
        onDeleteComment: (comment) {
          PostDetailScreenViewModel model = ref.read(widget.provider.notifier);
          model.onCommentDeleted(comment);
        },
      ),
      LikesPage(users: modelState.likedUsers)
    ]);
    SliverAppBar sliverAppBar = HooHSliverAppBar(
      title: const Text(""),
      actions: [buildMenuButton(model, modelState)],
      pinned: true,
    );

    return modelState.post == null
        ? Scaffold(
            appBar: HoohAppBar(title: const Text("")),
            body: const Center(
              child: const SizedBox(child: CircularProgressIndicator()),
            ),
          )
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              hideKeyboard();
            },
            child: Scaffold(
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
                      controller: scrollController2,
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
                                  const HoohIcon(
                                    "assets/images/common_ore.svg",
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    sprintf(globalLocalizations.me_wallet_ore_amount, [formatCurrency(modelState.post?.profitInt)]),
                                    style: TextStyle(fontSize: 12, color: designColors.light_06.auto(ref)),
                                  ),
                                  const SizedBox(
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
                      ? const SizedBox(
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
                            onLikePress: (newState, error) {
                              User? user = ref.read(globalUserInfoProvider);
                              if (user == null) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
                                return;
                              }
                              model.onPostLikePress(newState, error);
                            },
                            onFavoritePress: model.onPostFavoritePress,
                            onSharePress: () {
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                      pageBuilder: (context, anim1, anim2) => ShareScreen(
                                            scene: ShareScreen.SCENE_POST_IMAGE,
                                            post: modelState.post,
                                          ),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        return child;
                                      },
                                      opaque: false));
                            },
                            onSendPress: (comment, text, onComplete, onError) {
                              showHoohDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return LoadingDialog(LoadingDialogController());
                                  });
                              model.createComment(comment, text, () {
                                Navigator.of(
                                  context,
                                ).pop();
                                if (onComplete != null) {
                                  onComplete();
                                }
                              }, (error) {
                                Navigator.of(
                                  context,
                                ).pop();
                                if (onError != null) {
                                  onError(error);
                                }
                              });
                              hideKeyboard();
                            },
                          )),
                  Positioned(
                      bottom: 96,
                      right: 20,
                      child: SafeArea(
                          child: SizedBox(
                        width: 40,
                        height: 40,
                        child: FloatingActionButton(
                            backgroundColor: designColors.feiyu_blue.auto(ref),
                            onPressed: () {
                              scrollController2.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.easeOutCubic);
                            },
                            child: HoohIcon(
                              "assets/images/icon_back_to_top.svg",
                              width: 16,
                              color: designColors.light_01.light,
                            )),
                      ))),
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
            ),
          );
  }

  Widget buildMenuButton(PostDetailScreenViewModel model, PostDetailScreenModelState modelState) {
    return PopupMenuButton(
      color: designColors.light_00.auto(ref),
      icon: HoohIcon(
        "assets/images/icon_more.svg",
        width: 24,
        height: 24,
        color: designColors.dark_01.auto(ref),
      ),
      onSelected: (value) {},
      // offset: Offset(0.0, appBarHeight),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(const Radius.circular(8)),
      ),
      itemBuilder: (ctx) {
        TextStyle style = TextStyle(fontSize: 16, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold);
        PostImage currentImage = modelState.post!.images[0];

        bool isAdminMode = FlavorConfig.instance.variables[Launcher.KEY_ADMIN_MODE];
        PopupMenuItem itemDownload = PopupMenuItem(
          onTap: () {
            Future.delayed(const Duration(milliseconds: 250), () {
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
            Future.delayed(const Duration(milliseconds: 250), () {
              User? user = ref.read(globalUserInfoProvider);
              if (user == null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
                return;
              }
              network.requestAsync<Template>(network.getTemplateInfo(templateId!), (template) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditPostScreen(setting: PostImageSetting.withTemplate(template))));
              }, (error) {
                if (error.errorCode == Constants.RESOURCE_NOT_FOUND) {
                  showHoohDialog(
                      context: context,
                      builder: (popContext) => AlertDialog(
                            title: Text(globalLocalizations.error_view_template_not_found),
                          ));
                } else {
                  showCommonRequestErrorDialog(ref, context, error);
                }
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
            Future.delayed(const Duration(milliseconds: 250), () {
              Future<void> request;
              if (newFavorited) {
                request = network.favoriteTemplate(templateId!);
              } else {
                request = network.cancelFavoriteTemplate(templateId!);
              }
              network.requestAsync<void>(request, (_) {
                model.setTemplateFavorited(newFavorited);
                showSnackBar(
                    context, newFavorited ? globalLocalizations.post_detail_favorite_success : globalLocalizations.post_detail_cancel_favorite_success);
              }, (e) {
                if (kDebugMode) {
                  // showSnackBar(context, e.devMessage);
                  showCommonRequestErrorDialog(ref, context, e);
                } else {
                  if (e.errorCode == Constants.RESOURCE_NOT_FOUND) {
                    showHoohDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (popContext) => AlertDialog(
                        content: Text(newFavorited
                            ? globalLocalizations.post_detail_menu_favorite_template_failed_dialog_content
                            : globalLocalizations.post_detail_menu_cancel_favorite_template_failed_dialog_content),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(popContext).pop(true);
                              },
                              child: Text(globalLocalizations.common_ok)),
                        ],
                      ),
                    );
                  } else {
                    showSnackBar(context, globalLocalizations.post_detail_favorite_failed);
                  }
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
            Future.delayed(const Duration(milliseconds: 250), () {
              if (!modelState.post!.visible) {
                showHoohDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (popContext) {
                      return AlertDialog(
                        title: Text(globalLocalizations.post_detail_menu_join_private_post_dialog_title),
                        content: Text(globalLocalizations.post_detail_menu_join_private_post_dialog_content),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(popContext).pop(false);
                              },
                              child: Text(globalLocalizations.common_ok))
                        ],
                      );
                    });
                return;
              }
              network.getFeeInfo().then((response) {
                showHoohDialog(
                  context: context,
                  builder: (popContext) => AlertDialog(
                    title: Text(globalLocalizations.post_detail_join_waiting_list_dialog_title),
                    content: Text(sprintf(globalLocalizations.post_detail_join_waiting_list_dialog_content, [formatCurrency(response.joinWaitingList)])),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(popContext).pop();
                            network.requestAsync<void>(network.editPost(modelState.postId, EditPostRequest(joinWaitingList: true)), (_) {
                              model.setPublishState(Post.PUBLISH_STATE_WAITING_LIST);
                              showSnackBar(context, globalLocalizations.post_detail_join_waiting_list_success);
                            }, (error) {
                              // if (kDebugMode) {
                              //   // showSnackBar(context, e.devMessage);
                              //   showCommonRequestErrorDialog(ref, context, e);
                              // } else {
                              //   showSnackBar(context, globalLocalizations.post_detail_join_waiting_list_failed);
                              // }
                              if (error.errorCode == Constants.INSUFFICIENT_FUNDS) {
                                List<String> split = error.message.split("\n");
                                showNotEnoughOreDialog(ref: ref, context: context, needed: int.tryParse(split[0])!, current: int.tryParse(split[1])!);
                              } else {
                                showCommonRequestErrorDialog(ref, context, error);
                              }
                            });
                          },
                          child: Text(globalLocalizations.common_confirm)),
                      TextButton(
                          onPressed: () {
                            Navigator.of(popContext).pop();
                          },
                          child: Text(globalLocalizations.common_cancel)),
                    ],
                  ),
                );
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
            Future.delayed(const Duration(milliseconds: 250), () {
              showHoohDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (popContext) {
                    return AlertDialog(
                      content: Text(globalLocalizations.post_detail_menu_delete_dialog_title),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(popContext).pop();
                              network.requestAsync<void>(network.deletePost(modelState.postId), (_) {
                                showSnackBar(context, globalLocalizations.post_detail_delete_post_success);
                                Navigator.of(context, rootNavigator: true).pop();
                              }, (e) {
                                if (kDebugMode) {
                                  // showSnackBar(context, e.devMessage);
                                  showCommonRequestErrorDialog(ref, context, e);
                                } else {
                                  showSnackBar(context, globalLocalizations.post_detail_delete_post_failed);
                                }
                              });
                            },
                            child: Text(globalLocalizations.common_delete)),
                        TextButton(
                            onPressed: () {
                              Navigator.of(popContext).pop();
                            },
                            child: Text(globalLocalizations.common_cancel))
                      ],
                    );
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
            Future.delayed(const Duration(milliseconds: 250), () async {
              bool? result = await showHoohDialog<bool>(
                  context: context,
                  barrierDismissible: true,
                  builder: (popContext) {
                    return AlertDialog(
                      title: Text(globalLocalizations.post_detail_make_public_dialog_title),
                      content: Text(globalLocalizations.post_detail_make_public_dialog_content),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(popContext).pop(true);
                            },
                            child: Text(globalLocalizations.common_confirm)),
                        TextButton(
                            onPressed: () {
                              Navigator.of(popContext).pop(false);
                            },
                            child: Text(globalLocalizations.common_cancel))
                      ],
                    );
                  });
              if (result ?? false) {
                network.requestAsync<void>(network.editPost(modelState.postId, EditPostRequest(visible: newVisibility)), (_) {
                  showSnackBar(
                      context, newVisibility ? globalLocalizations.post_detail_set_visible_success : globalLocalizations.post_detail_set_invisible_success);
                  model.setPostVisible(newVisibility);
                }, (e) {
                  if (kDebugMode) {
                    // showSnackBar(context, e.devMessage);
                    showCommonRequestErrorDialog(ref, context, e);
                  } else {
                    showSnackBar(context, globalLocalizations.post_detail_set_visible_failed);
                  }
                });
              }
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
            showSnackBar(context, "copied!");
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
            if (modelState.post!.visible) {
              items.remove(itemChangeVisibility);
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Builder(builder: (context) {
        List<Widget> widgets = buildUserInfo(post);
        widgets.add(const SizedBox(
          width: 8,
        ));
        Widget? followButton = buildFollowButton(post);
        if (followButton != null) {
          widgets.add(followButton);
        } else {
          widgets.add(const SizedBox(
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
        size: 40,
      ),
      const SizedBox(
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
          style: const TextStyle(fontFamily: 'Baloo'),
        ),
        isEnabled: true,
        onPress: () {
          User? user = ref.read(globalUserInfoProvider);
          if (user == null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
            return;
          }
          PostDetailScreenViewModel model = ref.read(widget.provider.notifier);
          showHoohDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return LoadingDialog(LoadingDialogController());
              });
          model.onFollowPress(context, !author.followed!, onSuccess: () {
            Navigator.of(
              context,
            ).pop();
          }, onError: (error) {
            Navigator.of(
              context,
            ).pop();
            // showSnackBar(context, msg);
            showCommonRequestErrorDialog(ref, context, error);
          });
        });
  }

  Widget _buildButton({required Widget text, required bool isEnabled, required Function() onPress}) {
    ButtonStyle style = RegisterStyles.blueButtonStyle(ref, cornerRadius: 14).copyWith(
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        minimumSize: MaterialStateProperty.all(const Size.fromHeight(40)),
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
    // var stack = Stack(
    //   children: [Positioned.fill(child: tabBar), Positioned(child: rightWidget)],
    // );
    return Container(
      decoration: BoxDecoration(color: designColors.bar90_1.auto(ref), border: Border(bottom: BorderSide(color: designColors.light_02.auto(ref), width: 1))),
      child: Material(
          color: designColors.light_00.auto(ref),
          child: Row(
            children: [tabBar, const Spacer(), rightWidget],
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
