import 'package:app/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'select_topic_view_model.g.dart';

@CopyWith()
class SelectTopicScreenModelState {
  final List<String> recommendedTags;
  final List<String> userTags;

  SelectTopicScreenModelState({required this.recommendedTags, required this.userTags});

  factory SelectTopicScreenModelState.init(List<String>? selectedTags) {
    return SelectTopicScreenModelState(recommendedTags: [], userTags: selectedTags ?? []);
  }
}

class SelectTopicScreenViewModel extends StateNotifier<SelectTopicScreenModelState> {
  static const MAX_SELECTED_TAGS = 5;

  SelectTopicScreenViewModel(SelectTopicScreenModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    getRecommendedTags(onError: null);
  }

  void getRecommendedTags({Function(HoohApiErrorResponse)? onError}) {
    network.requestAsync<List<String>>(network.getRecommendedPublishPostTags(), (data) {
      // debugPrint("tags=$data");
      // List<String> list = [];
      // list.addAll([...data.map((e) => e + "1")]);
      // list.addAll([...data.map((e) => e + "2")]);
      // list.addAll([...data.map((e) => e + "3")]);
      // list.addAll([...data.map((e) => e + "4")]);
      // list.addAll([...data.map((e) => e + "5")]);
      // updateState(state.copyWith(recommendedTags: list));
      updateState(state.copyWith(recommendedTags: data));
    }, (error) {
      if (onError != null) {
        onError(error);
      }
    });
  }

  void addTag(String text) {
    text = text.trim();
    if (text.isEmpty || state.userTags.contains(text)) {
      return;
    }
    updateState(state.copyWith(userTags: [...state.userTags, text]));
  }

  void deleteTag(String text) {
    updateState(state.copyWith(userTags: [...state.userTags]..remove(text)));
  }
}
