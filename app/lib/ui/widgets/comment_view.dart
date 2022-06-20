import 'package:app/global.dart';
import 'package:app/ui/pages/user/user_profile.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/post_comment.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sprintf/sprintf.dart';

class CommentView extends ConsumerStatefulWidget {
  static const SUBSTITUTE = "[]";
  static const SUBSTITUTE_REGEX = r'\[\]';
  static const SUBSTITUTE_ESCAPE_REGEX = r'\\\[\\\]';

  final PostComment comment;
  final void Function(PostComment comment)? onReplyClick;
  final void Function(PostComment comment, bool newState)? onLikeClick;

  const CommentView({
    required this.comment,
    this.onReplyClick,
    this.onLikeClick,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _CommentViewState();
}

class _CommentViewState extends ConsumerState<CommentView> {
  final TapGestureRecognizer _tapGestureRecognizer = TapGestureRecognizer();

  @override
  void dispose() {
    super.dispose();
    _tapGestureRecognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PostComment comment = widget.comment;
    User author = comment.author;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarView.fromUser(comment.author, size: 32),
          SizedBox(
            width: 6,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  author.name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref)),
                ),
                SizedBox(
                  height: 6,
                ),
                // Text(
                //   comment.content,
                //   style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref)),
                // ),
                buildContentWidget(comment),
                SizedBox(
                  height: 8,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      DateUtil.getZonedDateString(comment.createdAt!),
                      style: TextStyle(fontSize: 8, color: designColors.light_06.auto(ref)),
                    ),
                    Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (widget.onLikeClick != null) {
                          widget.onLikeClick!(comment, !comment.liked!);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4, left: 16, top: 6, bottom: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HoohIcon(
                              "assets/images/icon_post_like.svg",
                              width: 16,
                              height: 16,
                              color: (comment.liked ?? false) ? designColors.feiyu_blue.auto(ref) : designColors.light_06.auto(ref),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            SizedBox(
                              width: 16,
                              child: Text(
                                comment.likeCount == 0 ? "" : formatAmount(comment.likeCount),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 6,
                                  color: designColors.light_06.auto(ref),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.onReplyClick != null) {
                          widget.onReplyClick!(comment);
                        }
                      },
                      child: Text(
                        globalLocalizations.post_detail_comment_reply,
                        style: TextStyle(color: designColors.light_06.auto(ref)),
                      ),
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(40, 16),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          textStyle: TextStyle(fontSize: 10, fontFamily: 'Linotte'),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          primary: designColors.light_02.auto(ref),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildContentWidget(PostComment comment) {
    TextStyle normalTextStyle = TextStyle(fontFamily: 'Linotte', fontSize: 14, color: designColors.dark_01.auto(ref));
    TextStyle highLightTextStyle = TextStyle(fontFamily: 'Linotte', fontSize: 14, color: designColors.blue_dark.auto(ref), fontWeight: FontWeight.bold);
    List<Substitute> substitutes = [...comment.substitutes];
    String placeholder = "[@*placeholder_#*@]";
    int index = 0;
    String template;
    if (comment.repliedUser != null) {
      template = sprintf(globalLocalizations.post_detail_comment_with_reply, [placeholder.replaceAll("#", "$index"), comment.content]);
      index++;
      substitutes.insert(0, Substitute(comment.repliedUser!.name, comment.repliedUser!.id, Substitute.TYPE_MENTION));
    } else {
      template = comment.content;
    }
    template = template.replaceAllMapped(RegExp(CommentView.SUBSTITUTE_REGEX), (match) {
      String placeholderString = placeholder.replaceAll("#", "$index");
      index++;
      return placeholderString;
    });
    return HoohLocalizedRichText(
        text: template,
        defaultTextStyle: normalTextStyle,
        keys: substitutes.map((e) {
          String key = placeholder.replaceAll("#", "${substitutes.indexOf(e)}");
          String text;
          TextStyle style;
          Function() onTap;
          if (e.type == Substitute.TYPE_MENTION) {
            text = "@${e.text}";
            style = highLightTextStyle;
            onTap = () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(userId: e.data)));
            };
          } else if (e.type == Substitute.TYPE_URL) {
            text = e.text;
            style = highLightTextStyle.apply(decoration: TextDecoration.underline);
            onTap = () {
              openLink(context, e.data, title: text);
            };
          } else {
            text = e.text;
            style = highLightTextStyle;
            onTap = () {
              Toast.showSnackBar(context, "not supported yet");
            };
          }
          return HoohLocalizedTextKey(key: key, text: text, style: style, onTap: onTap);
        }).toList());
  }
}
