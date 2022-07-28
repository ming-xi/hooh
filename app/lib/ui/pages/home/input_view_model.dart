import 'dart:convert';

import 'package:common/extensions/extensions.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'input_view_model.g.dart';

@CopyWith()
class InputPageModelState {
  static const MAX_CONTENT_LENGTH = 280;

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

  factory InputPageModelState.init() => InputPageModelState();
}

class InputPageViewModel extends StateNotifier<InputPageModelState> {
  late TextEditingController controller;

  InputPageViewModel(InputPageModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    getBackgroundImage();
    readFromDraft();
  }

  void getBackgroundImage() {
    network.requestAsync<HomepageBackgroundImageResponse>(network.getHomepageRandomBackground(), (obj) {
      updateState(state.copyWith(backgroundImageUrl: obj.imageUrl));
    }, (error) {});
  }

  List<String> readFromDraft({bool needsUpdate = true}) {
    List<String> strings = (json.decode(preferences.getString(Preferences.KEY_USER_DRAFT) ?? "[]") as List<dynamic>).map((e) => e.toString()).toList();
    // debugPrint("load draft: $strings");
    if (needsUpdate) {
      updateState(state.copyWith(inputStrings: strings, isStartButtonEnabled: strings.isNotEmpty && strings[0].isNotEmpty));
    }
    return strings;
  }

  void updateButtonState(bool enabled) {
    updateState(state.copyWith(isStartButtonEnabled: enabled));
  }

  List<String> updateInputText(String text, {bool needRefresh = false}) {
    saveDraft(text);
    updateState(state.copyWith(inputStrings: [text]));
    if (needRefresh) {
      controller.text = text;
    }
    return [text];
  }

  void saveDraft(String text) {
    // debugPrint("save draft: $text");
    preferences.putString(Preferences.KEY_USER_DRAFT, json.encode([text]));
  }
}
