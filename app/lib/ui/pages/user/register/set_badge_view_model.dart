import 'package:universal_io/io.dart';
import 'dart:typed_data';

import 'package:app/utils/file_utils.dart';
import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/social_badge.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;

part 'set_badge_view_model.g.dart';

class LayerData {
  final SocialBadgeTemplateLayer template;
  final Uint8List bytes;

  LayerData(this.template, this.bytes);
}

@CopyWith()
class SetBadgeScreenModelState {
  final List<LayerData> layers;

  final bool originalColor;

  // user's painting image
  final Uint8List? badgeImageBytes;

  final bool dialogCheckBoxChecked;

  SetBadgeScreenModelState({
    required this.layers,
    this.originalColor = false,
    this.badgeImageBytes,
    required this.dialogCheckBoxChecked,
  });

  factory SetBadgeScreenModelState.init() =>
      SetBadgeScreenModelState(layers: [], dialogCheckBoxChecked: preferences.getBool(Preferences.KEY_CHANGE_BADGE_DIALOG_CHECKED) ?? false);
}

class SetBadgeScreenViewModel extends StateNotifier<SetBadgeScreenModelState> {
  String? userId;

  SetBadgeScreenViewModel(this.userId, SetBadgeScreenModelState state) : super(state) {
    // if (userId != null) {
    //   getRandomBadge(userId!);
    // }
  }

  void toggleOriginalColor() {
    state = state.copyWith(originalColor: !state.originalColor);
  }

  void getRandomBadge(String userId, {Function()? callback}) {
    network.requestAsync<List<SocialBadgeTemplateLayer>>(network.getRandomBadgeTemplate(userId), (list) async {
      list.sort(
        (a, b) => a.layerIndex.compareTo(b.layerIndex),
      );
      List<LayerData> completedFuture = await Future.wait(list.map((e) async {
        ByteData byteData = (await NetworkAssetBundle(Uri.parse(e.imageUrl)).load(e.imageUrl));
        return LayerData(e, byteData.buffer.asUint8List());
      }).toList());
      state = state.copyWith(layers: completedFuture);
      if (callback != null) {
        callback();
      }
    }, (error) {});
  }

  Future<dynamic> changeUserBadge({double? hue}) async {
    Uint8List? bytes;
    if (state.badgeImageBytes == null) {
      // bytes = FileUtil.combineImages(state.layers.map((e) => e.bytes).toList());
      bytes =
          FileUtil.combineImages(state.layers.map((e) => getImageBytesWithHue(e.bytes, double.tryParse(e.template.hue) ?? 0, state.originalColor)).toList());
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

  void setDialogCheckBoxChecked(bool checked) {
    updateState(state.copyWith(dialogCheckBoxChecked: checked));
  }

  Uint8List getImageBytesWithHue(Uint8List fileBytes, double hue, bool originalColor) {
    if (originalColor) {
      return fileBytes;
    }
    img.Image? image = img.decodeImage(fileBytes);
    Uint32List pixels = image!.data;
    for (int i = 0; i < pixels.length; i++) {
      int pixel = pixels[i];
      Color color = Color(pixel);
      int a = color.alpha;
      int b = color.red;
      int g = color.green;
      int r = color.blue;
      color = Color.fromARGB(a, r, g, b);
      HSLColor hslColor = HSLColor.fromColor(color);
      double hue2 = hslColor.hue + hue;
      if (hue2 > 360) {
        hue2 -= 360;
      }
      hslColor = hslColor.withHue(hue2);
      color = hslColor.toColor();
      pixels[i] = Color.fromARGB(color.alpha, color.blue, color.green, color.red).value;
    }
    return Uint8List.fromList(img.encodePng(image));
  }
}
