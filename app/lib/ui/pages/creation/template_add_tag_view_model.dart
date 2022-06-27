import 'dart:io';

import 'package:app/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/requests.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/template.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'template_add_tag_view_model.g.dart';

@CopyWith()
class TemplateAddTagPageModelState {
  final List<String> tags;
  final bool uploading;

  TemplateAddTagPageModelState({required this.tags, this.uploading = false});

  factory TemplateAddTagPageModelState.init() => TemplateAddTagPageModelState(tags: []);
}

class TemplateAddTagPageViewModel extends StateNotifier<TemplateAddTagPageModelState> {
  TemplateAddTagPageViewModel(TemplateAddTagPageModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    // search(isRefresh: true);
  }

  void addTag(String text, {required Function(String tag) onDuplicateTagAdded}) {
    text = text.trim();
    if (text.isEmpty) {
      return;
    }
    if (state.tags.contains(text)) {
      onDuplicateTagAdded(text);
      return;
    }
    updateState(state.copyWith(tags: [...state.tags, text]));
  }

  void deleteTag(String text) {
    updateState(state.copyWith(tags: [...state.tags..remove(text)]));
  }

  Future<void> saveTemplate({
    required double frameHeight,
    required double frameWidth,
    required double frameX,
    required double frameY,
    required File imageFile,
    required String textColor,
    Function(Template template)? onSuccess,
    Function(dynamic msg)? onError,
  }) async {
    state = state.copyWith(uploading: true);
    RequestUploadingFileResponse requestUploadingFileResponse;
    try {
      requestUploadingFileResponse = await network.requestUploadingTemplate(imageFile);
    } catch (e) {
      print(e);
      if (onError != null) {
        if (e is HoohApiErrorResponse) {
          onError(e);
        } else {
          onError("error");
        }
      }
      state = state.copyWith(uploading: false);
      return;
    }

    String imageKey = requestUploadingFileResponse.key;
    String url = requestUploadingFileResponse.uploadingUrl;
    bool success = await network.uploadFile(url, imageFile.readAsBytesSync());
    if (!success) {
      if (onError != null) {
        onError("error");
      }
      state = state.copyWith(uploading: false);
      return;
    }
    CreateTemplateRequest request = CreateTemplateRequest(
        frameHeight: frameHeight.toStringAsFixed(2),
        frameWidth: frameWidth.toStringAsFixed(2),
        frameX: frameX.toStringAsFixed(2),
        frameY: frameY.toStringAsFixed(2),
        imageKey: imageKey,
        textColor: textColor);
    try {
      Template template = await network.createTemplate(request);
      state = state.copyWith(uploading: false);
      if (onSuccess != null) {
        onSuccess(template);
      }
    } catch (e) {
      print(e);
      if (onError != null) {
        if (e is HoohApiErrorResponse) {
          onError(e);
        } else {
          onError("error");
        }
      }
      state = state.copyWith(uploading: false);
      return;
    }
  }
}
