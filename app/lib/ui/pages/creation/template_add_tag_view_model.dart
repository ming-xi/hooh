import 'package:app/extensions/extensions.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'template_add_tag_view_model.g.dart';

@CopyWith()
class TemplateAddTagPageModelState {
  final List<String> tags;

  TemplateAddTagPageModelState({
    required this.tags,
  });

  factory TemplateAddTagPageModelState.init() => TemplateAddTagPageModelState(tags: []);
}

class TemplateAddTagPageViewModel extends StateNotifier<TemplateAddTagPageModelState> {
  TemplateAddTagPageViewModel(TemplateAddTagPageModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    // search(isRefresh: true);
  }

  void addTag(String text) {
    text = text.trim();
    if (state.tags.contains(text)) {
      return;
    }
    updateState(state.copyWith(tags: [...state.tags, text]));
  }

  void deleteTag(String text) {
    updateState(state.copyWith(tags: [...state.tags..remove(text)]));
  }
}
