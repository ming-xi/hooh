import 'package:app/global.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/pages/user/templates_view_model.dart';
import 'package:app/ui/widgets/empty_views.dart';
import 'package:app/ui/widgets/template_detail_view.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/page_state.dart';
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
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    UserTemplateScreenModelState modelState = ref.watch(widget.provider);
    UserTemplateScreenViewModel model = ref.read(widget.provider.notifier);

    return Scaffold(
      appBar: HoohAppBar(title: Text(globalLocalizations.user_profile_templates)),
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
        child: modelState.templates.isEmpty
            ? EmptyView(text: globalLocalizations.empty_view_no_templates)
            : ListView.separated(
          controller: scrollController,
                separatorBuilder: (context, index) => SizedBox(
                  height: 32,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemBuilder: (context, index) {
                  return TemplateDetailView(
                    template: modelState.templates[index],
                    type: TemplateDetailView.TYPE_FEEDS,
                    onDelete: model.onDeleteTemplate,
                    onFavorite: (template, error) {
                      if (error != null) {
                  // showSnackBar(context, error.message);
                        showCommonRequestErrorDialog(ref, context, error);
                  return;
                }
                model.updateTemplateData(template, index);
              },
              onFollow: (template, error) {
                if (error != null) {
                  // showSnackBar(context, error.message);
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
