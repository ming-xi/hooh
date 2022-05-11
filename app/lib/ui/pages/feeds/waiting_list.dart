import 'package:app/ui/pages/feeds/waiting_list_view_model.dart';
import 'package:app/ui/widgets/post_view.dart';
import 'package:app/utils/design_colors.dart';
import 'package:common/models/page_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class WaitingListPage extends ConsumerStatefulWidget {
  final StateNotifierProvider<WaitingListPageViewModel, WaitingListPageModelState> provider = StateNotifierProvider((ref) {
    return WaitingListPageViewModel(WaitingListPageModelState.init());
  });

  WaitingListPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _WaitingListPageState();
}

class _WaitingListPageState extends ConsumerState<WaitingListPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WaitingListPageModelState modelState = ref.watch(widget.provider);
    WaitingListPageViewModel model = ref.read(widget.provider.notifier);
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: MaterialClassicHeader(
        // offset: totalHeight,
        color: designColors.feiyu_blue.auto(ref),
      ),
      onRefresh: () async {
        model.getPosts((state) {
          debugPrint("refresh state=$state");
          _refreshController.refreshCompleted();
        });
      },
      onLoading: () async {
        model.getPosts((state) {
          if (state == PageState.noMore) {
            _refreshController.loadNoData();
            debugPrint("load no more state=$state");
          } else {
            _refreshController.loadComplete();
            debugPrint("load complete state=$state");
          }
        }, isRefresh: false);
      },
      controller: _refreshController,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        itemBuilder: (context, index) {
          return PostView(post: modelState.posts[index]);
        },
        itemCount: modelState.posts.length,
        separatorBuilder: (context, index) => SizedBox(
          height: 32,
        ),
      ),
    );
  }
}
