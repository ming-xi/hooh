import 'dart:io';

import 'package:common/models/network/responses.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'test_uploading_view_model.g.dart';

@CopyWith()
@immutable
class TestUploadingPageModelState {
  final bool uploading;
  final String? imageUrl;

  TestUploadingPageModelState({required this.uploading, required this.imageUrl});
}

class TestUploadingPageModel extends StateNotifier<TestUploadingPageModelState> {
  TestUploadingPageModel(TestUploadingPageModelState state) : super(state) {}

  Future<String> uploadFile(String userId, File file) async {
    state = state.copyWith(uploading: true);
    RequestUploadingFileResponse requestUploadingFileResponse = await network.requestUploadingAvatar(userId, file);
    String uploadingUrl = requestUploadingFileResponse.uploadingUrl;
    String key = requestUploadingFileResponse.key;
    await network.uploadFile(uploadingUrl, file.readAsBytesSync());
    state = state.copyWith(uploading: false);
    return key;
  }

  Future<void> changeAvatar(String userId, String key) async {
    User userInfo = await network.changeUserInfo(userId, avatarKey: key);
    state = state.copyWith(imageUrl: userInfo.avatarUrl);
  }
}
