import 'dart:io';

import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'edit_profile_view_model.g.dart';

@CopyWith()
class EditProfileScreenModelState {
  final bool error;
  final String userId;

  EditProfileScreenModelState({
    required this.userId,
    this.error = false,
  });

  factory EditProfileScreenModelState.init(String userId) => EditProfileScreenModelState(userId: userId);
}

class EditProfileScreenViewModel extends StateNotifier<EditProfileScreenModelState> {
  EditProfileScreenViewModel(EditProfileScreenModelState state) : super(state) {}

  void setErrorState(bool error) {
    updateState(state.copyWith(error: error));
  }

  Future<void> changeAvatar(File file, Function(User? user, dynamic error) callback) async {
    RequestUploadingFileResponse requestUploadingFileResponse;
    try {
      requestUploadingFileResponse = await network.requestUploadingAvatar(state.userId, file);
    } catch (e) {
      if (e is HoohApiErrorResponse) {
        callback(null, e);
      } else {
        callback(null, "error");
      }
      return;
    }

    String imageKey = requestUploadingFileResponse.key;
    String url = requestUploadingFileResponse.uploadingUrl;
    bool success = await network.uploadFile(url, file.readAsBytesSync());
    if (!success) {
      callback(null, "error");
      return;
    }

    network.requestAsync<User>(network.changeUserInfo(state.userId, avatarKey: imageKey), (newData) {
      callback(newData, null);
    }, (error) {
      callback(null, error);
    });
  }

  void getChangeNameLimit(Function(int? days, HoohApiErrorResponse? error)? callback) {
    network.requestAsync<ChangeNameLimitInfoResponse>(network.getChangeNameLimitInfo(), (newData) {
      if (callback != null) {
        callback(newData.days, null);
      }
    }, (error) {
      if (callback != null) {
        callback(null, error);
      }
    });
  }

  void changeNickname(String newName, Function(User? user, HoohApiErrorResponse? response)? callback) {
    network.requestAsync<User>(network.changeUserInfo(state.userId, name: newName), (newData) {
      if (callback != null) {
        callback(newData, null);
      }
    }, (error) {
      if (callback != null) {
        callback(null, error);
      }
    });
  }

  void changeSignature(String newSignature, Function(User? user, HoohApiErrorResponse? error)? callback) {
    network.requestAsync<User>(network.changeUserInfo(state.userId, signature: newSignature), (newData) {
      if (callback != null) {
        callback(newData, null);
      }
    }, (error) {
      if (callback != null) {
        callback(null, error);
      }
    });
  }

  void changeWebsite(String newWebsite, Function(User? user, HoohApiErrorResponse? error)? callback) {
    network.requestAsync<User>(network.changeUserInfo(state.userId, website: newWebsite), (newData) {
      if (callback != null) {
        callback(newData, null);
      }
    }, (error) {
      if (callback != null) {
        callback(null, error);
      }
    });
  }
}
