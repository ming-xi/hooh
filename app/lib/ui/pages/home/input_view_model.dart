import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/page_state.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'input_view_model.g.dart';

@CopyWith()
class InputPageModelState {
  final bool isStartButtonEnabled;
  final bool isMultiImageMode;
  final List<String> inputStrings;
  final String? backgroundImageUrl;

  InputPageModelState({
    this.isStartButtonEnabled = false,
    this.isMultiImageMode = false,
    this.inputStrings = const [],
    this.backgroundImageUrl,
  });

  factory InputPageModelState.init(int imageWidth) => InputPageModelState();
}

class InputPageViewModel extends StateNotifier<InputPageModelState> {
  InputPageViewModel(InputPageModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
  }
}
