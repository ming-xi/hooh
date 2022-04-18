import 'dart:typed_data';

import 'package:common/models/social_badge.dart';
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

  SetBadgeModelState({required this.layers});

  factory SetBadgeModelState.init() => SetBadgeModelState(layers: []);
}

class SetBadgeViewModel extends StateNotifier<SetBadgeModelState> {
  SetBadgeViewModel(String? userId, SetBadgeModelState state) : super(state) {
    if (userId != null) {
      getRandomBadge(userId);
    }
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
}
