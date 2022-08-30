import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/requests.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/template.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'template_detail_view_model.g.dart';

@CopyWith()
class TemplateDetailScreenModelState {
  final String templateId;
  final Template? template;
  final PageState pageState;
  final List<String> newTags;

  TemplateDetailScreenModelState({required this.templateId, this.template, this.newTags = const [], this.pageState = PageState.inited});

  factory TemplateDetailScreenModelState.init(String templateId, {Template? template}) {
    return TemplateDetailScreenModelState(templateId: templateId, template: template);
  }
}

class TemplateDetailScreenViewModel extends StateNotifier<TemplateDetailScreenModelState> {
  TemplateDetailScreenViewModel(TemplateDetailScreenModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    // getTemplates();
  }

  void getTemplateDetail({void Function(PageState state)? onSuccess, Function(HoohApiErrorResponse error)? onFailed}) {
    updateState(state.copyWith(pageState: PageState.loading));

    network.requestAsync<Template>(
      network.crmGetTemplateDetail(
        state.templateId,
      ),
      (newData) {
        updateState(state.copyWith(template: newData, newTags: [...?newData.tags], pageState: PageState.dataLoaded));
        if (onSuccess != null) {
          onSuccess(state.pageState);
        }
      },
      (error) {
        updateState(state.copyWith(pageState: PageState.inited));
        if (onFailed != null) {
          onFailed(error);
        }
      },
    );
  }

  void saveTemplate({void Function(PageState state)? onSuccess, Function(HoohApiErrorResponse error)? onFailed}) {
    updateState(state.copyWith(pageState: PageState.loading));

    network.requestAsync<Template>(
      network.crmModifyTemplate(state.templateId, ModifyTemplateRequest(tags: state.newTags)),
      (newData) {
        updateState(state.copyWith(template: newData, newTags: [...?newData.tags], pageState: PageState.dataLoaded));
        if (onSuccess != null) {
          onSuccess(state.pageState);
        }
      },
      (error) {
        updateState(state.copyWith(pageState: PageState.inited));
        if (onFailed != null) {
          onFailed(error);
        }
      },
    );
  }

  void removeTag(String name) {
    updateState(state.copyWith(newTags: [...state.newTags..remove(name)]));
  }

  void addTag(String name, {Function()? onDuplicated}) {
    if (state.newTags.contains(name)) {
      if (onDuplicated != null) {
        onDuplicated();
      }
      return;
    }
    updateState(state.copyWith(newTags: [...state.newTags..add(name)]));
  }
}
