import 'package:app/extensions/extensions.dart';
import 'package:common/models/post.dart';
import 'package:common/models/post_comment.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'comment_compose_view_model.g.dart';

@CopyWith()
class CommentComposeWidgetModelState {
  final bool liked;
  final bool favorited;
  final PostComment? replyingComment;

  CommentComposeWidgetModelState({
    required this.liked,
    required this.favorited,
    this.replyingComment,
  });

  factory CommentComposeWidgetModelState.init({required Post post, PostComment? replyingComment}) =>
      CommentComposeWidgetModelState(liked: post.liked, favorited: post.favorited ?? false, replyingComment: replyingComment);
}

class CommentComposeWidgetViewModel extends StateNotifier<CommentComposeWidgetModelState> {
  CommentComposeWidgetViewModel(CommentComposeWidgetModelState state) : super(state) {}

  void setRepliedComment(PostComment? comment) {
    debugPrint("setRepliedComment comment=$comment");
    updateState(state.copyWith(replyingComment: comment));
  }
}
