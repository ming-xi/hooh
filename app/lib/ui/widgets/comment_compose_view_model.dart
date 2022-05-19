import 'package:common/models/post.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'comment_compose_view_model.g.dart';

@CopyWith()
class CommentComposeWidgetModelState {
  final bool liked;
  final bool favorited;

  CommentComposeWidgetModelState({
    required this.liked,
    required this.favorited,
  });

  factory CommentComposeWidgetModelState.init(Post post) => CommentComposeWidgetModelState(
        liked: post.liked,
        favorited: post.favorited,
      );
}

class CommentComposeWidgetViewModel extends StateNotifier<CommentComposeWidgetModelState> {
  CommentComposeWidgetViewModel(CommentComposeWidgetModelState state) : super(state) {}
}
