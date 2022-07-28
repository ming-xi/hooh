import 'package:app/global.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/ui/pages/feeds/tagged_list_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/post_view.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/page_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

class TaggedListScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<TaggedListScreenViewModel, TaggedListScreenModelState> provider;

  TaggedListScreen({
    required String tagName,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return TaggedListScreenViewModel(TaggedListScreenModelState.init(tagName));
    });
  }

  @override
  ConsumerState createState() => _TaggedListScreenState();
}

class _TaggedListScreenState extends ConsumerState<TaggedListScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  ScrollController scrollController = ScrollController();
  late void Function() listener;
  bool listVisible = false;

  @override
  void initState() {
    super.initState();
    listener = () {
      if (!scrollController.position.isScrollingNotifier.value) {
        TaggedListScreenViewModel model = ref.read(widget.provider.notifier);
        model.setScrollDistance(scrollController.offset);
      } else {
        // print('scroll is started');
      }
    };
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.position.isScrollingNotifier.addListener(listener);
      TaggedListScreenModelState modelState = ref.read(widget.provider);
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
    TaggedListScreenModelState modelState = ref.watch(widget.provider);
    TaggedListScreenViewModel model = ref.read(widget.provider.notifier);
    return Scaffold(
      appBar: HoohAppBar(
        title: Text(
          modelState.tagName,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref)),
        ),
      ),
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
          model.getTagDetail(callback: (error) {
            showCommonRequestErrorDialog(ref, context, error);
          });
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
          controller: scrollController,
          padding: EdgeInsets.only(top: 16, bottom: 36, left: 20, right: 20),
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
        ),
      ),
    );
    // return refresher;
  }

  Widget buildHeaderView(BuildContext context, TaggedListScreenViewModel model, TaggedListScreenModelState modelState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HoohIcon(
              "assets/images/icon_tag.svg",
              width: 36,
              height: 36,
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    modelState.tagName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref)),
                  ),
                  Text(
                    sprintf(globalLocalizations.tagged_posts_count, [globalLocalizations.post(modelState.postCount)]),
                    style: TextStyle(fontSize: 12, color: designColors.light_06.auto(ref)),
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Row(
          children: [
            Spacer(),
            buildHeaderButtonView(model, false, !modelState.isTrending),
            buildHeaderButtonView(model, true, modelState.isTrending),
            Spacer(),
          ],
        ),
      ],
    );
  }

  Widget buildHeaderButtonView(TaggedListScreenViewModel model, bool trending, bool selected) {
    return SizedBox(
      height: 40,
      width: 100,
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

  Widget buildPostView(BuildContext context, int index, TaggedListScreenViewModel model, TaggedListScreenModelState modelState) {
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
  }
}
