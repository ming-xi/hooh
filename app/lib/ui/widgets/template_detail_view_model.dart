import 'package:common/extensions/extensions.dart';
import 'package:common/models/template.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'template_detail_view_model.g.dart';

@CopyWith()
class TemplateDetailModelState {
  final Template template;

  TemplateDetailModelState({
    required this.template,
  });

  factory TemplateDetailModelState.init(Template template) => TemplateDetailModelState(
        template: template,
      );
}

class TemplateDetailViewModel extends StateNotifier<TemplateDetailModelState> {
  TemplateDetailViewModel(TemplateDetailModelState state) : super(state) {}

  void updateTemplateData(Template t) {
    debugPrint("updateTemplateData favorited=${t.favorited}");
    updateState(state.copyWith(template: Template.fromJson(t.toJson())));
  }
}
