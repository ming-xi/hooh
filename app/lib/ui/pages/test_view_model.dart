import 'package:common/models/gallery_image.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/page_state.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'test_view_model.g.dart';

@CopyWith()
@immutable
class TestPageModelState {
  final List<GalleryImage> images;
  final String keyword;
  final int pageIndex;

  TestPageModelState(
      {required this.images,
      required this.keyword,
      required this.pageIndex,});

  factory TestPageModelState.init(int imageWidth, bool showFavoriteStatus) => TestPageModelState(
      images: [], keyword: "", pageIndex: 1, );
}

class TestPageViewModel extends StateNotifier<TestPageModelState> {
  TestPageViewModel(TestPageModelState state) : super(state) {
    // search(isRefresh: true);
  }
  void update(TestPageModelState s){
    state=s;
  }
}
