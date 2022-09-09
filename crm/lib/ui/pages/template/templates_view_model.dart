import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/template.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'templates_view_model.g.dart';

@CopyWith()
class TemplatesPageModelState {
  final List<Template> templates;
  final int templateState;
  final DateTime? lastTimestamp;
  final bool desc;
  final int size;
  final PageState pageState;

  TemplatesPageModelState(
      {this.templates = const [],
      this.templateState = Template.STATE_PENDING,
      this.lastTimestamp,
      this.desc = true,
      this.size = 50,
      // this.size = 2,
      this.pageState = PageState.inited});

  factory TemplatesPageModelState.init() {
    return TemplatesPageModelState();
  }
}

class TemplatesPageViewModel extends StateNotifier<TemplatesPageModelState> {
  TemplatesPageViewModel(TemplatesPageModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    // getTemplates();
  }

  void setTemplateState(int newState) {
    updateState(state.copyWith(templateState: newState));
  }

  void setSize(int size) {
    updateState(state.copyWith(size: size));
  }

  void setDesc(bool desc) {
    updateState(state.copyWith(desc: desc));
  }

  void getTemplates({String? tag, bool isRefresh = false, void Function(PageState state)? onSuccess, Function(HoohApiErrorResponse error)? onFailed}) {
    if (isRefresh) {
      updateState(state.copyWith(lastTimestamp: null));
      if (state.pageState == PageState.loading) {
        return;
      }
    } else {
      if (state.pageState != PageState.dataLoaded) {
        return;
      }
    }
    updateState(state.copyWith(pageState: PageState.loading));
    network.requestAsync<List<Template>>(
      network.crmSearchTemplates(state.templateState, date: state.lastTimestamp, size: state.size, desc: state.desc, tag: tag),
      (newData) {
        if (newData.isEmpty) {
          //no data
          if (isRefresh) {
            updateState(state.copyWith(templates: [], pageState: PageState.empty));
          } else {
            updateState(state.copyWith(pageState: PageState.noMore));
          }
          // debugPrint("${state.pageState}");
        } else {
          //has data
          bool isFeatured = state.templateState == Template.STATE_FEATURED;
          if (isRefresh) {
            updateState(state.copyWith(
                templates: newData, lastTimestamp: isFeatured ? newData.last.featuredAt : newData.last.createdAt, pageState: PageState.dataLoaded));
          } else {
            updateState(state.copyWith(
                templates: [...state.templates, ...newData],
                lastTimestamp: isFeatured ? newData.last.featuredAt : newData.last.createdAt,
                pageState: PageState.dataLoaded));
          }
        }
        if (onSuccess != null) {
          onSuccess(state.pageState);
        }
      },
      (error) {
        if (onFailed != null) {
          onFailed(error);
        }
      },
    );
  }

  void approveTemplate(Template template, {Function()? onSuccess, Function(HoohApiErrorResponse error)? onFailed}) {
    network.requestAsync<void>(
      network.crmApproveTemplate(template.id),
      (newData) {
        int index = state.templates.indexOf(template);
        template.state = Template.STATE_FEATURED;
        template = Template.fromJson(template.toJson());
        state.templates.removeAt(index);
        state.templates.insert(index, template);
        updateState(state.copyWith(templates: [...state.templates]));
        if (onSuccess != null) {
          onSuccess();
        }
      },
      (error) {
        if (onFailed != null) {
          onFailed(error);
        }
      },
    );
  }

  void rejectTemplate(Template template, {Function()? onSuccess, Function(HoohApiErrorResponse error)? onFailed}) {
    network.requestAsync<void>(
      network.crmRejectTemplate(template.id),
      (newData) {
        int index = state.templates.indexOf(template);
        template.state = Template.STATE_REJECTED;
        template = Template.fromJson(template.toJson());
        state.templates.removeAt(index);
        state.templates.insert(index, template);
        updateState(state.copyWith(templates: [...state.templates]));
        if (onSuccess != null) {
          onSuccess();
        }
      },
      (error) {
        if (onFailed != null) {
          onFailed(error);
        }
      },
    );
  }
}
