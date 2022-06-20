import 'dart:ui';

import 'package:app/global.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/pages/user/templates_view_model.dart';
import 'package:app/ui/widgets/template_compose_view.dart';
import 'package:app/ui/widgets/template_detail_view.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/template.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserTemplateScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<UserTemplateScreenViewModel, UserTemplateScreenModelState> provider;

  UserTemplateScreen({
    required String userId,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return UserTemplateScreenViewModel(UserTemplateScreenModelState.init(userId));
    });
  }

  @override
  ConsumerState createState() => _UserTemplateScreenState();
}

class _UserTemplateScreenState extends ConsumerState<UserTemplateScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    UserTemplateScreenModelState modelState = ref.watch(widget.provider);
    UserTemplateScreenViewModel model = ref.read(widget.provider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(globalLocalizations.user_profile_templates)),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: MainStyles.getRefresherHeader(ref),
        onRefresh: () async {
          model.getTemplates((state) {
            // debugPrint("refresh state=$state");
            _refreshController.refreshCompleted();
            _refreshController.resetNoData();
          });
        },
        onLoading: () async {
          model.getTemplates((state) {
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
          separatorBuilder: (context, index) => SizedBox(
            height: 32,
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemBuilder: (context, index) {
            return TemplateDetailView(
              template: modelState.templates[index],
              type: TemplateDetailView.TYPE_FEEDS,
              onFavorite: (template, error) {
                if (error != null) {
                  // Toast.showSnackBar(context, error.message);
                  showCommonRequestErrorDialog(ref, context, error);
                  return;
                }
                template.favorited = !template.favorited;
                model.updateTemplateData(template, index);
              },
              onFollow: (template, error) {
                if (error != null) {
                  // Toast.showSnackBar(context, error.message);
                  showCommonRequestErrorDialog(ref, context, error);
                  return;
                }
                template.author!.followed = true;
                model.updateTemplateData(template, index);
              },
            );
          },
          itemCount: modelState.templates.length,
        ),
      ),
    );
  }
}
