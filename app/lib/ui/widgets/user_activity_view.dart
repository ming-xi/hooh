import 'package:app/global.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/app_link.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sprintf/sprintf.dart';

class UserActivityView extends ConsumerWidget {
  // static const ITEM_RATIO = 165 / 211;
  final User user;
  final UserActivity activity;
  final Function(UserActivity activity) onDelete;

  const UserActivityView({
    required this.user,
    required this.activity,
    required this.onDelete,
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
          title = globalLocalizations.user_activity_posted;
          child = buildLargeImage(data, 'post_image_url');
          break;
        }
      case UserActivity.TYPE_CREATE_TEMPLATE:
        {
          title = globalLocalizations.user_activity_posted;
          child = buildLargeImage(data, 'template_image_url');
          break;
        }
      case UserActivity.TYPE_LIKE_POST:
        {
          title = globalLocalizations.user_activity_liked;
          child = Stack(
            children: [
              Positioned.fill(child: buildLargeImage(data, 'post_image_url')),
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
          title = globalLocalizations.user_activity_commented;
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
          title = globalLocalizations.user_activity_voted;
          child = buildLargeImage(data, 'post_image_url');
          break;
        }
      case UserActivity.TYPE_FAVORITE_TEMPLATE:
        {
          title = globalLocalizations.user_activity_bookmarked;
          child = buildLargeImage(data, 'template_image_url');
          break;
        }
      case UserActivity.TYPE_FOLLOW_USER:
        {
          title = globalLocalizations.user_activity_followed;
          child = buildFollowChild(data, ref);
          break;
        }
      case UserActivity.TYPE_CANCEL_FOLLOW_USER:
        {
          title = globalLocalizations.user_activity_unfollowed;
          child = buildFollowChild(data, ref);
          break;
        }
      case UserActivity.TYPE_FOLLOW_TAG:
        {
          title = globalLocalizations.user_activity_followed;
          child = Container();
          break;
        }
      case UserActivity.TYPE_CANCEL_FOLLOW_TAG:
        {
          title = globalLocalizations.user_activity_unfollowed;
          child = Container();
          break;
        }
      case UserActivity.TYPE_CREATE_BADGE:
        {
          title = globalLocalizations.user_activity_created;
          child = Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(gradient: MainStyles.badgeGradient(ref), borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: HoohImage(
                imageUrl: data['badge_image_url'],
                isBadge: true,
                width: 72,
              ),
            ),
          );
          break;
        }
      case UserActivity.TYPE_RECEIVE_BADGE:
        {
          title = globalLocalizations.user_activity_exchanged;
          child = Container(
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
          );
          break;
        }
      default:
        {
          child = Container();
        }
    }
    return ElevatedButton(
      onPressed: () {
        openAppLink(context, activity.universalLink, ref: ref);
      },
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          primary: designColors.light_01.auto(ref),
          onPrimary: designColors.light_02.auto(ref),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          shadowColor: Colors.black.withAlpha((255 * 0.2).toInt()),
          elevation: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildUserRow(title, ref, context, activity),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: AspectRatio(aspectRatio: 1, child: child),
          ),
        ],
      ),
    );
  }

  Widget buildLargeImage(Map<String, dynamic> data, String key) {
    return HoohImage(
      imageUrl: data[key],
      cornerRadius: 20,
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
    Widget child = Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(gradient: MainStyles.badgeGradient(ref), borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
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

  Widget buildUserRow(String title, WidgetRef ref, BuildContext context, UserActivity activity) {
    User? currentUser = ref.read(globalUserInfoProvider);
    // var iconButton = IconButton(
    //     padding: EdgeInsets.zero,
    //     constraints: BoxConstraints(minHeight: 24, minWidth: 24),
    //     onPressed: () {},
    //     splashRadius: 16,
    //     icon: HoohIcon(
    //       "assets/images/icon_more.svg",
    //       width: 24,
    //       height: 24,
    //       color: designColors.light_06.auto(ref),
    //     ));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: 10,
        ),
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
        // SizedBox(
        //   width: 4,
        // ),
        Visibility(
          visible: currentUser != null && currentUser.id == user.id,
          replacement: SizedBox.square(dimension: 48),
          child: PopupMenuButton(
            padding: EdgeInsets.zero,
            color: designColors.light_00.auto(ref),
            splashRadius: 16,
            constraints: BoxConstraints(minHeight: 24, minWidth: 24),
            icon: HoohIcon(
              "assets/images/icon_more.svg",
              width: 24,
              height: 24,
              color: designColors.light_06.auto(ref),
            ),
            onSelected: (value) {},
            // offset: Offset(0.0, appBarHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            itemBuilder: (ctx) {
              TextStyle style = TextStyle(fontSize: 16, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold);
              PopupMenuItem itemDelete = PopupMenuItem(
                onTap: () {
                  Future.delayed(Duration(milliseconds: 250), () {
                    network.getFeeInfo().then((response) {
                      int deleteActivityFee = response.deleteActivity;
                      showHoohDialog(
                          context: ctx,
                          barrierDismissible: false,
                          builder: (popContext) {
                            return AlertDialog(
                              content: Text(sprintf(globalLocalizations.user_activity_delete_dialog_title, [formatCurrency(deleteActivityFee)])),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(popContext).pop();
                                      network.requestAsync<void>(network.deleteUserActivity(user.id, activity.id), (_) {
                                        showSnackBar(context, globalLocalizations.user_activity_delete_success);
                                        onDelete(activity);
                                      }, (e) {
                                        if (e.errorCode == Constants.INSUFFICIENT_FUNDS) {
                                          List<String> split = e.message.split("\n");
                                          showNotEnoughOreDialog(ref: ref, context: context, needed: int.tryParse(split[0])!, current: int.tryParse(split[1])!);
                                        } else {
                                          showCommonRequestErrorDialog(ref, context, e);
                                        }
                                      });
                                    },
                                    child: Text(globalLocalizations.common_delete)),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(popContext).pop();
                                    },
                                    child: Text(globalLocalizations.common_cancel))
                              ],
                            );
                          });
                    });
                  });
                },
                child: Text(
                  globalLocalizations.user_activity_delete_menu_text,
                  style: style,
                ),
              );

              List<PopupMenuItem> items = [itemDelete];
              return items;
            },
          ),
        )
      ],
    );
  }
}
