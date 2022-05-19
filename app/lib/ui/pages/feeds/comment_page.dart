import 'package:app/ui/widgets/comment_view.dart';
import 'package:app/utils/design_colors.dart';
import 'package:common/models/post_comment.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CommentPage extends ConsumerStatefulWidget {
  final List<PostComment> comments;
  final void Function(PostComment comment, bool newState) onLikeClick;
  final void Function(PostComment comment) onReplyClick;

  const CommentPage({
    required this.comments,
    required this.onLikeClick,
    required this.onReplyClick,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _CommentPageState();
}

class _CommentPageState extends ConsumerState<CommentPage> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => CommentView(comment: widget.comments[index]),
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 1,
          color: designColors.light_02.auto(ref),
        ),
      ),
      itemCount: widget.comments.length,
    );
  }
}
