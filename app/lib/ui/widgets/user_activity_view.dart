import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/app_link.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/user.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserActivityView extends ConsumerWidget {
  static const ITEM_RATIO = 165 / 211;
  final User user;
  final UserActivity activity;

  const UserActivityView({
    required this.user,
    required this.activity,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String title = "";
    Widget child;
    Map<String, dynamic> data = activity.data;

    switch (activity.type) {
      case UserActivity.TYPE_CREATE_POST:
        {
          title = "Posted";
          child = buildLargeImage(data, 'post_image_url');
          break;
        }
      case UserActivity.TYPE_CREATE_TEMPLATE:
        {
          title = "Posted";
          child = buildLargeImage(data, 'template_image_url');
          break;
        }
      case UserActivity.TYPE_LIKE_POST:
        {
          title = "Liked";
          child = Stack(
            children: [
              buildLargeImage(data, 'post_image_url'),
              Positioned(
                  right: 8,
                  bottom: 8,
                  child: HoohIcon(
                    "assets/images/icon_activity_like.svg",
                    width: 48,
                    height: 48,
                  )),
            ],
          );
          break;
        }
      case UserActivity.TYPE_COMMENT_POST:
        {
          title = "Posted";
          child = Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HoohImage(
                imageUrl: data['post_image_url'],
                cornerRadius: 12,
                width: 64,
                height: 64,
              ),
              SizedBox(
                height: 12,
              ),
              Expanded(
                  child: Text(
                data['comment_content'],
                style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref)),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ))
            ],
          );
          break;
        }
      case UserActivity.TYPE_VOTE_POST:
        {
          title = "Voted";
          child = buildLargeImage(data, 'post_image_url');
          break;
        }
      case UserActivity.TYPE_FAVORITE_TEMPLATE:
        {
          title = "Bookmarked";
          child = buildLargeImage(data, 'template_image_url');
          break;
        }
      case UserActivity.TYPE_FOLLOW_USER:
        {
          title = "Followed";
          child = buildFollowChild(data, ref);
          break;
        }
      case UserActivity.TYPE_CANCEL_FOLLOW_USER:
        {
          title = "Unfollowed";
          child = buildFollowChild(data, ref);
          break;
        }
      case UserActivity.TYPE_FOLLOW_TAG:
        {
          title = "Followed";
          child = Container();
          break;
        }
      case UserActivity.TYPE_CANCEL_FOLLOW_TAG:
        {
          title = "Unfollowed";
          child = Container();
          break;
        }
      case UserActivity.TYPE_CREATE_BADGE:
        {
          title = "Created";
          child = AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(gradient: MainStyles.badgeGradient(ref), borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: HoohImage(
                  imageUrl: data['badge_image_url'],
                  isBadge: true,
                  width: 72,
                ),
              ),
            ),
          );
          break;
        }
      case UserActivity.TYPE_RECEIVE_BADGE:
        {
          title = "Exchanged";
          child = AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(gradient: MainStyles.badgeGradient(ref), borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Spacer(),
                    HoohImage(
                      imageUrl: data['badge_image_url'],
                      isBadge: true,
                      width: 72,
                    ),
                    Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
                          padding: EdgeInsets.all(0.5),
                          child: HoohImage(
                            imageUrl: data['user_avatar_url'],
                            width: 24,
                            height: 24,
                            cornerRadius: 100,
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Expanded(
                            child: Text(
                          data['name'],
                          style: TextStyle(fontSize: 14, color: designColors.light_01.auto(ref), fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ))
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
          break;
        }
      default:
        {
          child = Container();
        }
    }
    Column column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        buildUserRow(title, ref),
        // buildDate(ref, context),
        SizedBox(
          height: 10,
        ),
        Expanded(child: child)
      ],
    );
    // var material = Material(
    //   type: MaterialType.transparency,
    //   child: Ink(
    //     decoration: BoxDecoration(
    //         color: designColors.light_01.auto(ref),
    //         borderRadius: BorderRadius.circular(24),
    //         boxShadow: [BoxShadow(color: Colors.black.withAlpha((255 * 0.2).toInt()), offset: Offset.zero, blurRadius: 10, spreadRadius: -4)]),
    //     child: InkWell(
    //       onTap: () {},
    //       borderRadius: BorderRadius.circular(24),
    //       child: Padding(
    //         padding: const EdgeInsets.all(10.0),
    //         child: column,
    //       ),
    //     ),
    //   ),
    // );
    ElevatedButton card = ElevatedButton(
      onPressed: () {
        openUniversalLink(context, activity.universalLink);
      },
      child: column,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(10),
        primary: designColors.light_01.auto(ref),
        onPrimary: designColors.light_02.auto(ref),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        // shadowColor: Colors.black.withAlpha((255 * 0.2).toInt()),
        // elevation: 8
      ),
    );
    return AspectRatio(
      aspectRatio: UserActivityView.ITEM_RATIO,
      child: card,
    );
  }

  AspectRatio buildLargeImage(Map<String, dynamic> data, String key) {
    return AspectRatio(
      aspectRatio: 1,
      child: HoohImage(
        imageUrl: data[key],
        cornerRadius: 20,
      ),
    );
  }

  Widget buildFollowChild(Map<String, dynamic> data, WidgetRef ref) {
    List<Widget> signatures = [
      SizedBox(
        height: 8,
      ),
      Text(
        data['signature'],
        style: TextStyle(
          fontSize: 12,
          color: designColors.light_01.auto(ref),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      )
    ];
    List<Widget> children = [
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
        padding: EdgeInsets.all(1),
        child: HoohImage(
          imageUrl: data['user_avatar_url'],
          width: 48,
          height: 48,
          cornerRadius: 100,
        ),
      ),
      SizedBox(
        height: 8,
      ),
      Text(data['name'],
          style: TextStyle(fontSize: 14, color: designColors.light_01.auto(ref), fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
    ];
    if (data['signature'] != null && data['signature'].toString().isNotEmpty) {
      children.addAll(signatures);
    }
    Widget child = AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(gradient: MainStyles.badgeGradient(ref), borderRadius: BorderRadius.circular(20)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
    return child;
  }

  Widget buildDate(WidgetRef ref, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: 30,
        ),
        Expanded(
          child: Text(
            formatDate(context, activity.createdAt),
            // DateUtil.getZonedDateString(activity.createdAt),
            style: TextStyle(fontSize: 10, color: designColors.light_06.auto(ref)),
          ),
        ),
      ],
    );
  }

  Widget buildUserRow(String title, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        AvatarView.fromUser(
          user,
          size: 24,
          clickable: false,
        ),
        SizedBox(
          width: 6,
        ),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref)),
          ),
        ),
        SizedBox(
          width: 4,
        ),
        IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minHeight: 24, minWidth: 24),
            onPressed: () {},
            splashRadius: 16,
            icon: Icon(
              Icons.more_horiz_rounded,
              color: designColors.light_06.auto(ref),
            ))
      ],
    );
  }
}
