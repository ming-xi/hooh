import 'dart:io';
import 'dart:typed_data';

import 'package:app/utils/file_utils.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/social_badge.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'set_badge_view_model.g.dart';

class LayerData {
  final SocialBadgeTemplateLayer template;
  final Uint8List bytes;

  LayerData(this.template, this.bytes);
}

@CopyWith()
class SetBadgeModelState {
  final List<LayerData> layers;

  final bool originalColor;
  final Uint8List? badgeImageBytes;

  SetBadgeModelState({required this.layers, this.originalColor = false, this.badgeImageBytes});

  factory SetBadgeModelState.init() => SetBadgeModelState(layers: []);
}

class SetBadgeViewModel extends StateNotifier<SetBadgeModelState> {
  String? userId;

  SetBadgeViewModel(this.userId, SetBadgeModelState state) : super(state) {
    if (userId != null) {
      getRandomBadge(userId!);
    }
  }

  void toggleOriginalColor() {
    state = state.copyWith(originalColor: !state.originalColor);
  }

  void getRandomBadge(String userId) {
    network.getRandomBadgeTemplate(userId).then((list) async {
      list.sort(
        (a, b) => a.layerIndex.compareTo(b.layerIndex),
      );
      List<LayerData> completedFuture = await Future.wait(list.map((e) async {
        ByteData byteData = (await NetworkAssetBundle(Uri.parse(e.imageUrl)).load(e.imageUrl));
        return LayerData(e, byteData.buffer.asUint8List());
      }).toList());
      state = state.copyWith(layers: completedFuture);
    });
  }

  Future<dynamic> changeUserBadge() async {
    Uint8List? bytes;
    if (state.badgeImageBytes == null) {
      bytes = FileUtil.combineImages(state.layers.map((e) => e.bytes).toList());
    } else {
      bytes = state.badgeImageBytes;
    }
    File tempFile = await FileUtil.writeTempFile(bytes!, "png");
    try {
      RequestUploadingFileResponse response = await network.requestUploadingSocialBadge(userId!, tempFile);
      bool success = await network.uploadFile(response.uploadingUrl, bytes);
      if (!success) {
        return false;
      }
      User userInfo = await network.changeUserInfo(userId!, badgeImageKey: response.key);
      return userInfo;
    } catch (error) {
      if (error is HoohApiErrorResponse) {
        return error;
      }
    }
  }
}
