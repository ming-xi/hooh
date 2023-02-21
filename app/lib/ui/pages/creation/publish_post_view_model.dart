import 'dart:async';
import 'dart:typed_data';

import 'package:app/global.dart';
import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/ui/widgets/template_compose_view.dart';
import 'package:app/utils/file_utils.dart';
import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/requests.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/post.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sprintf/sprintf.dart';
import 'package:universal_io/io.dart';

part 'publish_post_view_model.g.dart';

@CopyWith()
class PublishPostScreenModelState {
  final PostImageSetting setting;
  final List<String> tags;
  final bool allowDownload;
  final bool isPrivate;
  final bool uploading;
  final bool hintChecked;

  PublishPostScreenModelState({
    required this.setting,
    required this.hintChecked,
    required this.allowDownload,
    this.tags = const [],
    this.isPrivate = false,
    this.uploading = false,
  });

  factory PublishPostScreenModelState.init(PostImageSetting setting) {
    return PublishPostScreenModelState(
        setting: setting,
        hintChecked: preferences.getBool(Preferences.KEY_ADD_TO_VOTE_LIST_DIALOG_CHECKED) ?? false,
        allowDownload: preferences.getBool(Preferences.KEY_PUBLISH_POST_DOWNLOAD_TO_DEVICE) ?? true);
  }
}

class PublishPostScreenViewModel extends StateNotifier<PublishPostScreenModelState> {
  // static const double OUTPUT_IMAGE_SIZE = 1080;
  static const double OUTPUT_IMAGE_SIZE = 720;

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

  Future<File> _saveScreenshot(BuildContext context, User currentUser) async {
    WidgetsBinding? binding = WidgetsBinding.instance;
    double devicePixelRatio = binding.window.devicePixelRatio;
    double screenWidth = MediaQuery.of(context).size.width;
    // double ratio = PublishPostScreenViewModel.OUTPUT_IMAGE_SIZE / (screenWidth / devicePixelRatio);
    double ratio = PublishPostScreenViewModel.OUTPUT_IMAGE_SIZE / screenWidth;
    debugPrint("screenWidth=$screenWidth devicePixelRatio=$devicePixelRatio ratio=$ratio");
    TemplateViewSetting viewSetting = TemplateView.generateViewSetting(TemplateView.SCENE_PUBLISH_POST_PREVIEW);

    Widget widget = ProviderScope(
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            Positioned.fill(child: TemplateView(state.setting, viewSetting: viewSetting, scale: 1, radius: 0)),
            Positioned(
              child: Text(
                sprintf(globalLocalizations.publish_post_watermark, [currentUser.name, globalLocalizations.common_app_name]),
                style: TextStyle(
                    fontSize: 8,
                    // fontFamily: 'Baloo',
                    color: Colors.white.withOpacity(0.9),
                    shadows: [Shadow(color: Colors.black.withOpacity(0.7), offset: Offset(0.25, 0.25), blurRadius: 1)]),
                textAlign: TextAlign.center,
              ),
              left: 0,
              right: 0,
              bottom: 5.5,
            )
          ],
        ),
      ),
    );
    ScreenshotController screenshotController = ScreenshotController();
    Uint8List fileBytes = await screenshotController.captureFromWidget(widget, pixelRatio: ratio);
    img.Image image = img.decodeImage(fileBytes)!;
    List<int> jpgBytes = img.encodeJpg(image, quality: 100);
    // List<int> jpgBytes = img.encodePng(image);
    String name = md5.convert(jpgBytes).toString();
    Directory saveDir = await getApplicationDocumentsDirectory();
    File file = File('${saveDir.path}/$name.jpg');
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsBytesSync(jpgBytes, flush: true);
    return file;
  }

  Future<void> publishPost(
      {required BuildContext context,
      required User currentUser,
      required bool publishToWaitingList,
      Function(Post post)? onSuccess,
      Function(dynamic reponse)? onError}) async {
    state = state.copyWith(uploading: true);
    File imageFile = await _saveScreenshot(context, currentUser);
    if (state.allowDownload) {
      FileUtil.saveImageToGallery(imageFile);
    }
    preferences.putBool(Preferences.KEY_PUBLISH_POST_DOWNLOAD_TO_DEVICE, state.allowDownload);
    // Navigator.of(context).pop();
    // showHoohDialog(
    //     context: context,
    //     builder: (popContext) =>
    //         AlertDialog(
    //           content: Image.file(imageFile),
    //         ));
    // return;

    List<String?> keys = await Future.wait([imageFile].map((file) async {
      RequestUploadingFileResponse requestUploadingFileResponse;
      try {
        requestUploadingFileResponse = await network.requestUploadingPostImage(file);
      } catch (e) {
        if (onError != null) {
          if (e is HoohApiErrorResponse) {
            onError(e);
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
    List<CreateImageRequest> imageRequests = keys.map((e) => CreateImageRequest(e!, state.setting.text ?? "", templateId: state.setting.templateId)).toList();
    CreatePostRequest request = CreatePostRequest(
      visible: !state.isPrivate,
      joinWaitingList: publishToWaitingList,
      images: imageRequests,
      tags: state.tags,
    );
    network.requestAsync<Post>(network.createPost(request), (post) {
      state = state.copyWith(uploading: false);
      if (onSuccess != null) {
        onSuccess(post);
      }
    }, (e) {
      if (onError != null) {
        onError(e);
      }
      state = state.copyWith(uploading: false);
    });
  }

  void setHintChecked(bool checked) {
    updateState(state.copyWith(hintChecked: checked));
  }
}
