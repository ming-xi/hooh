import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/template.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'templates_view_model.g.dart';

@CopyWith()
class UserTemplateScreenModelState {
  final List<Template> templates;
  final PageState pageState;
  final HoohApiErrorResponse? error;
  final DateTime? lastTimestamp;
  final String userId;

  UserTemplateScreenModelState({
    required this.templates,
    required this.pageState,
    required this.userId,
    this.error,
    this.lastTimestamp,
  });

  factory UserTemplateScreenModelState.init(String id) => UserTemplateScreenModelState(
        templates: [],
        userId: id,
        pageState: PageState.inited,
      );
}

class UserTemplateScreenViewModel extends StateNotifier<UserTemplateScreenModelState> {
  UserTemplateScreenViewModel(UserTemplateScreenModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    getTemplates(null);
  }

  void getTemplates(Function(PageState)? callback, {bool isRefresh = true}) {
    if (isRefresh) {
      updateState(state.copyWith(lastTimestamp: null));
      if (state.pageState == PageState.loading) {
        if (callback != null) {
          callback(state.pageState);
        }
        return;
      }
    } else {
      if (![
        PageState.dataLoaded,
      ].contains(state.pageState)) {
        if (callback != null) {
          callback(state.pageState);
        }
        return;
      }
    }
    updateState(state.copyWith(pageState: PageState.loading));
    // debugPrint("lastTimestamp=${state.lastTimestamp}");
    network.requestAsync<List<Template>>(network.getUserCreatedTemplates(state.userId, date: state.lastTimestamp), (newData) {
      if (newData.isEmpty) {
        //no data
        if (isRefresh) {
          updateState(state.copyWith(pageState: isRefresh ? PageState.empty : PageState.noMore, templates: []));
        } else {
          updateState(state.copyWith(pageState: isRefresh ? PageState.empty : PageState.noMore));
        }
        // debugPrint("${state.pageState}");
      } else {
        //has data
        if (isRefresh) {
          updateState(state.copyWith(pageState: PageState.dataLoaded, templates: newData, lastTimestamp: newData.last.createdAt));
        } else {
          updateState(state.copyWith(pageState: PageState.dataLoaded, templates: [...state.templates, ...newData], lastTimestamp: newData.last.createdAt));
        }
      }
      if (callback != null) {
        callback(state.pageState);
      }
    }, (error) {
      updateState(state.copyWith(
        error: error,
        pageState: PageState.inited,
      ));
      if (callback != null) {
        callback(state.pageState);
      }
    });
  }

  void updateTemplateData(Template template, int index) {
    List<Template> list = [...state.templates];
    list[index] = template;
    updateState(state.copyWith(templates: list));
  }

  void onDeleteTemplate(Template template) {
    state.templates.remove(template);
    updateState(state.copyWith(templates: [...state.templates]));
  }
}
