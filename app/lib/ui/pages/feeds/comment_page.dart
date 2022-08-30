import 'package:app/global.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/comment_view.dart';
import 'package:app/utils/design_colors.dart';
import 'package:common/models/post_comment.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loadmore/loadmore.dart';

class CommentPage extends ConsumerStatefulWidget {
  final List<PostComment> comments;
  final void Function(PostComment comment, bool newState) onLikeClick;
  final void Function(PostComment comment) onReplyClick;
  final void Function(PostComment comment) onDeleteComment;
  final void Function() onLoadMore;
  final bool noMore;
  final bool scrollable;

  const CommentPage({
    required this.comments,
    required this.onLikeClick,
    required this.onReplyClick,
    required this.onDeleteComment,
    required this.scrollable,
    required this.onLoadMore,
    this.noMore = false,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _CommentPageState();
}

class _CommentPageState extends ConsumerState<CommentPage> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: widget.comments.isNotEmpty,
        replacement: buildEmptyView(),
        child: LoadMore(
          isFinish: widget.noMore,
          onLoadMore: () async {
            widget.onLoadMore();
            return true;
          },
          textBuilder: (status) {
            switch (status) {
              case LoadMoreStatus.idle:
                return "";
              case LoadMoreStatus.loading:
                return globalLocalizations.comment_page_loading;
              case LoadMoreStatus.fail:
                return "";
              case LoadMoreStatus.nomore:
                return "";
            }
          },
          child: ListView.separated(
            padding: EdgeInsets.zero,
            physics: widget.scrollable ? null : NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => CommentView(
              comment: widget.comments[index],
              onLikeClick: widget.onLikeClick,
              onReplyClick: widget.onReplyClick,
              onDeleted: widget.onDeleteComment,
            ),
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 1,
                color: designColors.light_02.auto(ref),
              ),
            ),
            itemCount: widget.comments.length,
          ),
        ));
  }

  Widget buildEmptyView() {
    return MainStyles.buildEmptyView(
      ref: ref,
      text: globalLocalizations.post_detail_comments_empty_hint,
    );
  }
}
