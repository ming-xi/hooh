import 'package:app/global.dart';
import 'package:app/ui/pages/feeds/post_detail.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/post.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostView extends ConsumerStatefulWidget {
  final Post post;
  final Function(Post post, HoohApiErrorResponse? error)? onVote;
  final Function(Post post, HoohApiErrorResponse? error)? onLike;
  final Function(Post post, HoohApiErrorResponse? error)? onComment;

  final Function(Post post, HoohApiErrorResponse? error)? onShare;
  final Function(Post post, HoohApiErrorResponse? error)? onFollow;

  const PostView({
    required this.post,
    this.onVote,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onFollow,
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
    return Container(
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: Color(0x0C000000), offset: Offset(0, 8), blurRadius: 24)]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              child: Ink(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PostDetailScreen(
                                  postId: post.id,
                                  post: post,
                                )));
                  },
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: HoohImage(imageUrl: post.images[0].imageUrl),
                  ),
                ),
              ),
            ),
            Material(
              // padding: const EdgeInsets.only( top: 16, bottom: 20),

              color: designColors.light_01.auto(ref),
              child: Builder(builder: (context) {
                List<Widget> widgets = [];
                if (post.publishState == Post.PUBLISH_STATE_WAITING_LIST) {
                  widgets.add(buildUserInfoRow(post));
                } else if (post.publishState == Post.PUBLISH_STATE_MAIN_LIST) {
                  widgets.add(buildUserInfoRow(post));
                  widgets.add(SizedBox(
                    height: 12,
                  ));
                  widgets.add(buildButtons(post));
                } else {}
                return Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  // padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widgets,
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  Builder buildButtons(Post post) {
    return Builder(builder: (context) {
      List<Widget> widgets = [
        ...buildIconAndAmount("assets/images/common_ore.svg", 24, 0, null),
        Spacer(),
        ...buildIconAndAmount("assets/images/icon_post_like.svg", 32, post.likeCount, () {
          onLikePress(post);
        }),
        SizedBox(
          width: 8,
        ),
        ...buildIconAndAmount("assets/images/icon_post_comment.svg", 32, post.commentCount, () {
          onCommentPress(post);
        }),
        SizedBox(
          width: 8,
        ),
        ...buildIconAndAmount("assets/images/icon_post_share.svg", 32, null, () {
          onSharePress(post);
        }),
      ];
      return Padding(
        padding: const EdgeInsets.only(left: 4, right: 4),
        child: Row(
          children: widgets,
        ),
      );
    });
  }

  void onVotePress(Post post) {
    network.requestAsync<Post>(network.votePost(post.id), (data) {
      if (widget.onVote != null) {
        widget.onVote!(data, null);
      }
    }, (error) {
      if (widget.onVote != null) {
        widget.onVote!(post, error);
      }
    });
  }

  void onFollowPress(Post post) {
    if (post.author.followed ?? false) {
      return;
    }
    network.requestAsync<void>(network.followUser(post.author.id), (data) {
      if (widget.onFollow != null) {
        widget.onFollow!(post, null);
      }
    }, (error) {
      if (widget.onFollow != null) {
        widget.onFollow!(post, error);
      }
    });
  }

  void onLikePress(Post post) {
    Future<void> request = post.liked ? network.cancelLikePost(post.id) : network.likePost(post.id);
    network.requestAsync<void>(request, (data) {
      if (widget.onLike != null) {
        widget.onLike!(post, null);
      }
    }, (error) {
      if (widget.onLike != null) {
        widget.onLike!(post, error);
      }
    });
  }

  void onCommentPress(Post post) {
    if (widget.onComment != null) {
      widget.onComment!(post, null);
    } else {
      // Navigator.push(context, MaterialPageRoute(builder: (context) =>));
    }
  }

  void onSharePress(Post post) {
    if (widget.onShare != null) {
      widget.onShare!(post, null);
    } else {
      // Navigator.push(context, MaterialPageRoute(builder: (context) =>));
    }
  }

  Widget buildUserInfoRow(Post post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Builder(builder: (context) {
        List<Widget> widgets = buildUserInfo(post);
        widgets.add(SizedBox(
          width: 8,
        ));
        if (post.publishState == Post.PUBLISH_STATE_WAITING_LIST) {
          widgets.add(buildVoteButton(post));
        } else if (post.publishState == Post.PUBLISH_STATE_MAIN_LIST) {
          Widget? followButton = buildFollowButton(post);
          if (followButton != null) {
            widgets.add(followButton);
          } else {
            widgets.add(SizedBox(
              height: 40,
            ));
          }
        } else {}
        return Row(
          children: widgets,
        );
      }),
    );
  }

  List<Widget> buildIconAndAmount(String iconPath, double size, int? amount, Function()? onPress) {
    List<Widget> list = [
      IconButton(
        onPressed: onPress,
        // padding: EdgeInsets.zero,
        icon: HoohIcon(
          iconPath,
          width: size,
          height: size,
        ),
      ),
    ];
    if (amount != null) {
      list.add(SizedBox(
        width: 24,
        child: Text(
          formatAmount(amount),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref)),
        ),
      ));
    }
    return list;
  }

  List<Widget> buildUserInfo(Post post) {
    User author = post.author;
    return [
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
    ];
  }

  Widget? buildFollowButton(Post post) {
    User? user = ref.watch(globalUserInfoProvider.state).state;
    User author = post.author;
    if ((author.followed ?? false) || (user?.id == author.id)) {
      return null;
    }
    return _buildButton(
        text: Text(
          "Follow",
          style: TextStyle(fontFamily: 'Linotte'),
        ),
        isEnabled: (post.myVoteCount ?? 0) == 0,
        onPress: () {
          onFollowPress(post);
        });
  }

  Widget buildVoteButton(Post post) {
    String text = "Vote";
    if ((post.myVoteCount ?? 0) > 0) {
      text = "$text ${post.voteCount ?? 0}";
    }
    return _buildButton(
        text: Text(
          text,
          style: TextStyle(fontFamily: 'Linotte'),
        ),
        isEnabled: (post.myVoteCount ?? 0) == 0,
        onPress: () {
          onVotePress(post);
        });
  }

  Widget _buildButton({required Widget text, required bool isEnabled, required Function() onPress}) {
    ButtonStyle style = RegisterStyles.blueButtonStyle(ref, cornerRadius: 14).copyWith(
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        minimumSize: MaterialStateProperty.all(Size.fromHeight(40)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap);
    if (!isEnabled) {
      style = style.copyWith(backgroundColor: MaterialStateProperty.all(designColors.dark_03.auto(ref)));
    }
    return SizedBox(
      width: 120,
      child: TextButton(
        onPressed: onPress,
        child: text,
        style: style,
      ),
    );
  }
}
