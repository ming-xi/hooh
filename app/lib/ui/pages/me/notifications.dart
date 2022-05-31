import 'package:app/global.dart';
import 'package:app/ui/pages/me/notifications_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/system_notification_view.dart';
import 'package:common/models/page_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SystemNotificationScreen extends ConsumerStatefulWidget {
  final StateNotifierProvider<SystemNotificationScreenViewModel, SystemNotificationScreenModelState> provider = StateNotifierProvider((ref) {
    return SystemNotificationScreenViewModel(SystemNotificationScreenModelState.init());
  });

  SystemNotificationScreen({
    Key? key,
  }) : super(key: key) {}

  @override
  ConsumerState createState() => _SystemNotificationScreenState();
}

class _SystemNotificationScreenState extends ConsumerState<SystemNotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(globalLocalizations.system_notification_title)),
      body: SystemNotificationPage(
        provider: widget.provider,
      ),
    );
  }
}

class SystemNotificationPage extends ConsumerStatefulWidget {
  final StateNotifierProvider<SystemNotificationScreenViewModel, SystemNotificationScreenModelState> provider;

  SystemNotificationPage({
    required this.provider,
    Key? key,
  }) : super(key: key) {}

  @override
  ConsumerState createState() => _SystemNotificationPageState();
}

class _SystemNotificationPageState extends ConsumerState<SystemNotificationPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    SystemNotificationScreenModelState modelState = ref.watch(widget.provider);
    SystemNotificationScreenViewModel model = ref.read(widget.provider.notifier);

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: MainStyles.getRefresherHeader(ref),
      onRefresh: () async {
        model.getNotifications((state) {
          // debugPrint("refresh state=$state");
          _refreshController.refreshCompleted();
          _refreshController.resetNoData();
        });
      },
      onLoading: () async {
        model.getNotifications((state) {
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
      child: ListView.builder(
        itemBuilder: (context, index) {
          return SystemNotificationView(notification: modelState.notifications[index]);
        },
        itemCount: modelState.notifications.length,
      ),
    );
  }
}
