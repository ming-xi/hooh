import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app/extensions/extensions.dart';
import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/ui/widgets/template_compose_view.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/requests.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/post.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

part 'publish_post_view_model.g.dart';

@CopyWith()
class PublishPostScreenModelState {
  final PostImageSetting setting;
  final List<String> tags;
  final bool allowDownload;
  final bool isPrivate;
  final bool uploading;

  PublishPostScreenModelState({required this.setting, this.tags = const [], this.allowDownload = true, this.isPrivate = false, this.uploading = false});

  factory PublishPostScreenModelState.init(PostImageSetting setting) {
    return PublishPostScreenModelState(setting: setting);
  }
}

class PublishPostScreenViewModel extends StateNotifier<PublishPostScreenModelState> {
  static const double OUTPUT_IMAGE_SIZE = 1080;

  PublishPostScreenViewModel(PublishPostScreenModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    // search(isRefresh: true);
  }

  void setIsPrivate(bool newState) {
    updateState(state.copyWith(isPrivate: newState));
  }

  void setAllowDownload(bool newState) {
    updateState(state.copyWith(allowDownload: newState));
  }

  void setTags(List<String> newTags) {
    updateState(state.copyWith(tags: newTags));
  }

  Future<File> _saveScreenshot(BuildContext context) async {
    WidgetsBinding? binding = WidgetsBinding.instance;
    double devicePixelRatio = binding.window.devicePixelRatio;
    double screenWidth = MediaQuery.of(context).size.width;
    double ratio = PublishPostScreenViewModel.OUTPUT_IMAGE_SIZE / (screenWidth / devicePixelRatio);
    TemplateViewSetting viewSetting = TemplateView.generateViewSetting(TemplateView.SCENE_PUBLISH_POST_PREVIEW);
    Widget widget = ProviderScope(
      child: TemplateView(state.setting, viewSetting: viewSetting, scale: 1, radius: 0),
    );
    ScreenshotController screenshotController = ScreenshotController();
    Uint8List fileBytes = await screenshotController.captureFromWidget(widget, pixelRatio: ratio);
    img.Image image = img.decodePng(fileBytes)!;
    List<int> jpgBytes = img.encodeJpg(image, quality: 80);
    String name = md5.convert(jpgBytes).toString();
    // var decodeJpg = img.decodePng(bytes);
    // debugPrint("decodeJpg ${decodeJpg!.width} x ${decodeJpg.height}");
    Directory saveDir = await getApplicationDocumentsDirectory();
    File file = File('${saveDir.path}/$name.jpg');
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsBytesSync(jpgBytes, flush: true);
    return file;
  }

  Future<void> publishPost(
      {required BuildContext context, required bool publishToWaitingList, Function(Post post)? onSuccess, Function(String msg)? onError}) async {
    state = state.copyWith(uploading: true);
    File imageFile = await _saveScreenshot(context);
    List<String?> keys = await Future.wait([imageFile].map((file) async {
      RequestUploadingFileResponse requestUploadingFileResponse;
      try {
        requestUploadingFileResponse = await network.requestUploadingPostImage(file);
      } catch (e) {
        print(e);
        if (onError != null) {
          if (e is HoohApiErrorResponse) {
            onError(e.message);
          } else {
            onError("error");
          }
        }
        state = state.copyWith(uploading: false);
        return null;
      }
      String imageKey = requestUploadingFileResponse.key;
      String url = requestUploadingFileResponse.uploadingUrl;
      bool success = await network.uploadFile(url, file.readAsBytesSync());
      if (!success) {
        if (onError != null) {
          onError("error");
        }
        state = state.copyWith(uploading: false);
        return null;
      }
      return imageKey;
    }).toList());
    List<CreateImageRequest> imageRequests = keys.map((e) => CreateImageRequest(e!, state.setting.text ?? "")).toList();
    CreatePostRequest request = CreatePostRequest(
        allowDownload: state.allowDownload,
        visible: !state.isPrivate,
        joinWaitingList: publishToWaitingList,
        images: imageRequests,
        tags: state.tags,
        templateId: state.setting.templateId);
    network.requestAsync<Post>(network.createPost(request), (post) {
      state = state.copyWith(uploading: false);
      if (onSuccess != null) {
        onSuccess(post);
      }
    }, (e) {
      if (onError != null) {
        onError(e.message);
      }
      state = state.copyWith(uploading: false);
    });
  }
}
