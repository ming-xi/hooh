import 'package:app/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/template.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'recommended_templates_view_model.g.dart';

@CopyWith()
class RecommendedTemplatesScreenModelState {
  final List<Template> templates;
  final List<String> contents;
  final PageState pageState;

  RecommendedTemplatesScreenModelState({
    required this.templates,
    required this.contents,
    required this.pageState,
  });

  factory RecommendedTemplatesScreenModelState.init(List<String> contents) =>
      RecommendedTemplatesScreenModelState(templates: [], contents: contents, pageState: PageState.inited);
}

class RecommendedTemplatesScreenViewModel extends StateNotifier<RecommendedTemplatesScreenModelState> {
  RecommendedTemplatesScreenViewModel(RecommendedTemplatesScreenModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
  }

  void getRecommendedTemplates({required void Function() onComplete, required void Function(HoohApiErrorResponse ex) onError}) {
    if (state.pageState == PageState.loading) {
      return;
    }

    updateState(state.copyWith(pageState: PageState.loading));
    network.requestAsync<List<Template>>(network.getRecommendedTemplates(state.contents), (data) {
      updateState(state.copyWith(
        templates: data,
        pageState: PageState.dataLoaded,
      ));
      onComplete();
    }, (error) {
      updateState(state.copyWith(
        pageState: PageState.dataLoaded,
      ));
      onError(error);
    });
  }
}
