import 'package:app/global.dart';
import 'package:app/ui/pages/feeds/waiting_list_view_model.dart';
import 'package:app/ui/pages/home/feeds.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/post_view.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/page_state.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class WaitingListPage extends ConsumerStatefulWidget {
  final StateNotifierProvider<WaitingListPageViewModel, WaitingListPageModelState> provider = StateNotifierProvider((ref) {
    return WaitingListPageViewModel(WaitingListPageModelState.init());
  });

  WaitingListPage({
    Key? key,
  }) : super(key: key) {}

  @override
  ConsumerState createState() => _WaitingListPageState();
}

class _WaitingListPageState extends ConsumerState<WaitingListPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  ScrollController scrollController = ScrollController();
  late void Function() listener;
  bool listVisible = false;

  @override
  void initState() {
    super.initState();
    listener = () {
      if (!scrollController.position.isScrollingNotifier.value) {
        WaitingListPageViewModel model = ref.read(widget.provider.notifier);
        model.setScrollDistance(scrollController.offset);
      } else {
        // print('scroll is started');
      }
    };
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.position.isScrollingNotifier.addListener(listener);
      WaitingListPageModelState modelState = ref.read(widget.provider);
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
    WaitingListPageModelState modelState = ref.watch(widget.provider);
    WaitingListPageViewModel model = ref.read(widget.provider.notifier);
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
              child: ListView.separated(
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
              ),
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

  Widget buildHeaderView(BuildContext context, WaitingListPageViewModel model, WaitingListPageModelState modelState) {
    return Row(
      children: [
        Spacer(),
        buildHeaderButtonView(model, false, !modelState.isTrending),
        buildHeaderButtonView(model, true, modelState.isTrending),
        Spacer(),
      ],
    );
  }

  Widget buildHeaderButtonView(WaitingListPageViewModel model, bool trending, bool selected) {
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

  Widget buildPostView(BuildContext context, int index, WaitingListPageViewModel model, WaitingListPageModelState modelState) {
    return PostView(
      post: modelState.posts[index],
      displayAsVotingPost: true,
      onVote: (post, error) {
        if (error != null) {
          // showCommonRequestErrorDialog(ref, context, error);
          return;
        }
        showSnackBar(context, globalLocalizations.waiting_list_vote_success);
        model.updatePostData(post, index, onPostIntoMainList: () {
          showHoohDialog(
              context: context,
              builder: (popContext) => AlertDialog(
                    title: Text(globalLocalizations.waiting_list_vote_into_main_list_dialog_title),
                    content: Text(globalLocalizations.waiting_list_vote_into_main_list_dialog_content),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(popContext).pop(false);
                          },
                          child: Text(globalLocalizations.common_ok))
                    ],
                  ));
        });
      },
    );
  }
}
