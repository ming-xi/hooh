import 'package:app/global.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/app_link.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/user.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sprintf/sprintf.dart';

class SystemNotificationView extends ConsumerWidget {
  final SystemNotification notification;

  const SystemNotificationView({
    required this.notification,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget? rightWidget;
    List<Widget> iconRowChildren;
    switch (notification.type) {
      case SystemNotification.TYPE_POST_COMMENTED:
        {
          rightWidget = buildPostImage(notification.imageUrl!);
          iconRowChildren = buildIconRowWidgets(
              context, ref, "assets/images/icon_notification_comment.svg", sprintf(globalLocalizations.system_notification_comment, [notification.content]));
          break;
        }
      case SystemNotification.TYPE_COMMENT_REPLIED:
        {
          rightWidget = buildPostImage(notification.imageUrl!);
          iconRowChildren = buildIconRowWidgets(
              context, ref, "assets/images/icon_notification_comment.svg", sprintf(globalLocalizations.system_notification_reply, [notification.content]));
          break;
        }
      case SystemNotification.TYPE_POST_LIKED:
        {
          rightWidget = buildPostImage(notification.imageUrl!);
          iconRowChildren = buildIconRowWidgets(context, ref, "assets/images/icon_notification_like.svg", globalLocalizations.system_notification_like_post);
          break;
        }
      case SystemNotification.TYPE_POST_FAVORITED:
        {
          rightWidget = buildPostImage(notification.imageUrl!);
          iconRowChildren =
              buildIconRowWidgets(context, ref, "assets/images/icon_notification_star.svg", globalLocalizations.system_notification_favorite_post);
          break;
        }
      case SystemNotification.TYPE_COMMENT_LIKED:
        {
          rightWidget = buildPostImage(notification.imageUrl!);
          iconRowChildren = buildIconRowWidgets(
              context, ref, "assets/images/icon_notification_like.svg", sprintf(globalLocalizations.system_notification_like_comment, [notification.content]));
          break;
        }
      case SystemNotification.TYPE_POST_MOVED_TO_MAIN_LIST:
        {
          rightWidget = buildPostImage(notification.imageUrl!);
          iconRowChildren =
              buildIconRowWidgets(context, ref, "assets/images/icon_notification_general.svg", globalLocalizations.system_notification_into_main_list);
          break;
        }
      case SystemNotification.TYPE_POST_VOTED:
        {
          rightWidget = buildPostImage(notification.imageUrl!);
          iconRowChildren = buildIconRowWidgets(context, ref, "assets/images/icon_notification_vote.svg", globalLocalizations.system_notification_vote_post);
          break;
        }
      case SystemNotification.TYPE_TEMPLATE_APPROVED:
        {
          rightWidget = buildPostImage(notification.imageUrl!);
          iconRowChildren =
              buildIconRowWidgets(context, ref, "assets/images/icon_notification_vote.svg", globalLocalizations.system_notification_approve_template);
          break;
        }
      case SystemNotification.TYPE_BADGE_RECEIVED:
        {
          rightWidget = buildBadgeImage(ref, notification.imageUrl!);
          iconRowChildren =
              buildIconRowWidgets(context, ref, "assets/images/icon_notification_general.svg", globalLocalizations.system_notification_exchange_badge);
          break;
        }
      case SystemNotification.TYPE_POST_DELETED:
        {
          rightWidget = buildPostImage(notification.imageUrl!);
          iconRowChildren =
              buildIconRowWidgets(context, ref, "assets/images/icon_notification_general.svg", globalLocalizations.system_notification_delete_post);
          break;
        }
      case SystemNotification.TYPE_TEMPLATE_FAVORITED:
        {
          rightWidget = buildPostImage(notification.imageUrl!);
          iconRowChildren =
              buildIconRowWidgets(context, ref, "assets/images/icon_notification_heart.svg", globalLocalizations.system_notification_favorite_template);
          break;
        }
      case SystemNotification.TYPE_FOLLOWED:
        {
          iconRowChildren = buildIconRowWidgets(context, ref, "assets/images/icon_notification_follow.svg", globalLocalizations.system_notification_follow);
          break;
        }
      default:
        {
          iconRowChildren = buildIconRowWidgets(context, ref, "assets/images/icon_notification_delete.svg", globalLocalizations.system_notification_unknown);
          break;
        }
    }

    Row iconRow = Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: iconRowChildren,
    );
    List<Widget> mainChildren = [
      buildAvatar(context, notification.avatarUniversalLink, notification.avatarUrl),
      SizedBox(
        width: 8,
      ),
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildTitle(ref, notification.title),
            SizedBox(
              height: 4,
            ),
            buildDate(context, ref, notification.createdAt),
            SizedBox(
              height: 8,
            ),
            iconRow
          ],
        ),
      ),
    ];
    if (rightWidget != null) {
      mainChildren.add(SizedBox(
        width: 2,
      ));
      mainChildren.add(rightWidget);
    }
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        child: InkWell(
          onTap: () {
            openAppLink(context, notification.mainUniversalLink, ref: ref);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: mainChildren,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildIconRowWidgets(BuildContext context, WidgetRef ref, String assetPath, String text) {
    return [
      HoohIcon(
        assetPath,
        width: 24,
        height: 24,
      ),
      SizedBox(
        width: 4,
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            text,
            maxLines: 2,
            style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )
    ];
  }

  Widget buildDate(BuildContext context, WidgetRef ref, DateTime date) {
    return Text(
      formatDate(context, date),
      style: TextStyle(color: designColors.light_06.auto(ref), fontSize: 12),
    );
  }

  Widget buildPostImage(String imageUrl) {
    return HoohImage(
      imageUrl: imageUrl,
      width: 72,
      height: 72,
      cornerRadius: 8,
    );
  }

  Widget buildBadgeImage(WidgetRef ref, String imageUrl) {
    return Container(
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: MainStyles.badgeGradient(ref),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: designColors.light_01.auto(ref),
          borderRadius: BorderRadius.circular(20 - 1),
        ),
        child: Center(
          child: HoohImage(
            imageUrl: imageUrl,
            width: 50,
            isBadge: true,
          ),
        ),
      ),
    );
  }

  Widget buildTitle(WidgetRef ref, String? name) {
    return Text(
      name ?? globalLocalizations.common_system_notice,
      style: TextStyle(color: designColors.light_06.auto(ref), fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget buildAvatar(BuildContext context, String? link, String? url, {String? userId}) {
    return GestureDetector(
      onTap: () {
        openAppLink(context, link);
      },
      child: ClipOval(
          child: url != null
              ? HoohImage(
                  imageUrl: url,
                  width: 40,
                  height: 40,
                  cornerRadius: 100,
                )
              : HoohIcon(
            "assets/images/system_notice.png",
                  width: 40,
                  height: 40,
                )),
    );
  }
}
