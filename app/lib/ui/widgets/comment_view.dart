import 'package:app/global.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/post_comment.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CommentView extends ConsumerStatefulWidget {
  final PostComment comment;

  const CommentView({
    required this.comment,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _CommentViewState();
}

class _CommentViewState extends ConsumerState<CommentView> {
  static const SUBSTITUTE = "[]";
  static const SUBSTITUTE_REGEX = r'\[\]';
  static const SUBSTITUTE_ESCAPE_REGEX = r'\\\[\\\]';
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
          ClipOval(
            child: HoohImage(
              imageUrl: author.avatarUrl!,
              width: 32,
              height: 32,
            ),
          ),
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
                      onTap: () {
                        debugPrint("tap");
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HoohIcon(
                              "assets/images/icon_post_like.svg",
                              width: 16,
                              height: 16,
                              color: (comment.liked ?? false) ? designColors.feiyu_blue.auto(ref) : null,
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            SizedBox(
                              width: 16,
                              child: Text(
                                formatAmount(comment.likeCount),
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
                      onPressed: () {},
                      child: Text(
                        "Reply",
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
    TextStyle normalTextStyle = TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref));
    TextStyle highLightTextStyle = TextStyle(fontSize: 14, color: designColors.blue_dark.auto(ref));
    List<Substitute> substitutes = comment.substitutes;
    if (substitutes.isEmpty) {
      return Text(
        comment.content,
        style: normalTextStyle,
      );
    } else {
      List<dynamic> splits = comment.content.split(RegExp(SUBSTITUTE_REGEX)).map((e) => e as dynamic).toList();
      int index = 0;
      for (int i = 0; i < splits.length; i++) {
        if (i < substitutes.length) {
          splits.insert(i + 1, substitutes[index]);
          index++;
          i++;
        }
      }

      return RichText(
          text: TextSpan(
              children: splits.map((e) {
        if (e is String) {
          return TextSpan(text: e.replaceAll(RegExp(SUBSTITUTE_ESCAPE_REGEX), SUBSTITUTE), style: normalTextStyle);
        } else if (e is Substitute) {
          if (e.type == Substitute.TYPE_MENTION) {
            return TextSpan(
              text: "@${e.text}",
              style: highLightTextStyle,
              recognizer: _tapGestureRecognizer
                ..onTap = () {
                  Toast.showSnackBar(context, "show user ${e.data}");
                },
            );
          } else if (e.type == Substitute.TYPE_URL) {
            return TextSpan(
              text: e.text,
              style: highLightTextStyle.apply(decoration: TextDecoration.underline),
              recognizer: _tapGestureRecognizer
                ..onTap = () {
                  openLink(context, e.data);
                },
            );
          } else {
            return TextSpan(
              text: e.text,
              style: highLightTextStyle,
              recognizer: _tapGestureRecognizer
                ..onTap = () {
                  Toast.showSnackBar(context, "not supported yet");
                },
            );
          }
        } else {
          return TextSpan(text: " ? ");
        }
      }).toList()));
    }
  }
}
