import 'dart:async';
import 'dart:typed_data';

// import 'package:flutter/material.dart' as material;
import 'dart:ui';

import 'package:app/utils/file_utils.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;

part 'draw_badge_view_model.g.dart';

class PaletteItem {
  static const TYPE_NORMAL = 0;
  static const TYPE_OUTLINED = 1;
  static const TYPE_ADD = 2;

  final int type;
  final Color color;
  bool selected;

  PaletteItem({required this.type, required this.color, this.selected = false});
}

@CopyWith()
class DrawBadgeModelState {
  final List<PaletteItem> paletteItems;
  final Color? customColor;
  final Color currentColor;
  final Image? image;

  DrawBadgeModelState({required this.paletteItems, this.customColor, required this.currentColor, this.image});
}

class DrawBadgeViewModel extends StateNotifier<DrawBadgeModelState> {
  DrawBadgeViewModel(DrawBadgeModelState state) : super(state) {}

  void loadImage(List<Uint8List>? imageLayerBytes) async {
    var bytes = FileUtil.combineImages(imageLayerBytes);
    if (bytes == null) {
      return;
    }
    final Completer<Image> completer = Completer();
    decodeImageFromList(bytes, (result) {
      return completer.complete(result);
    });
    state = state.copyWith(image: await completer.future);
  }

  void setSelectedColor(int index) {
    for (var value in state.paletteItems) {
      value.selected = false;
    }
    state.paletteItems[index].selected = true;
    state = state.copyWith(paletteItems: [...state.paletteItems], currentColor: state.paletteItems[index].color);
  }

  void setCustomColor(Color? color) {
    for (var value in state.paletteItems) {
      value.selected = false;
    }
    state.paletteItems[0].selected = true;
    state = state.copyWith(customColor: color, paletteItems: [...state.paletteItems], currentColor: color);
  }
}
