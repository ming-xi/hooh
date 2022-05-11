import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/post.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostView extends ConsumerStatefulWidget {
  final Post post;

  const PostView({
    required this.post,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _PostViewState();
}

class _PostViewState extends ConsumerState<PostView> {
  @override
  Widget build(BuildContext context) {
    Post post = widget.post;
    User author = post.author;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: HoohImage(imageUrl: post.images[0].imageUrl),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 20),
            color: designColors.light_01.auto(ref),
            child: Row(
              children: [
                HoohImage(
                  imageUrl: author.avatarUrl!,
                  cornerRadius: 100,
                  width: 32,
                  height: 32,
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author.name,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: designColors.dark_00.auto(ref)),
                      ),
                      Text(
                        DateUtil.getZonedDateString(post.createdAt),
                        style: TextStyle(fontSize: 10, color: designColors.light_06.auto(ref)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                buildVoteButton(post)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildVoteButton(Post post) {
    String text = "Vote";
    if (post.voteCount > 0) {
      text = "$text ${post.voteCount}";
    }
    return SizedBox(
      width: 120,
      child: TextButton(
        onPressed: () {},
        child: Text(
          text,
          style: TextStyle(fontFamily: 'Linotte'),
        ),
        style: RegisterStyles.blueButtonStyle(ref, cornerRadius: 14).copyWith(
            textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            minimumSize: MaterialStateProperty.all(Size.fromHeight(40))),
      ),
    );
  }
}
