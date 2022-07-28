import 'package:app/global.dart';
import 'package:app/ui/pages/me/badges_view_model.dart';
import 'package:app/ui/pages/user/register/set_badge.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/pages/user/user_profile.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

class BadgesScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<BadgesScreenViewModel, BadgesScreenModelState> provider;
  final String userId;

  BadgesScreen({
    required this.userId,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return BadgesScreenViewModel(BadgesScreenModelState.init(userId));
    });
  }

  @override
  ConsumerState createState() => _BadgesScreenState();
}

class _BadgesScreenState extends ConsumerState<BadgesScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    TextStyle? titleTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref));
    double screenWidth = MediaQuery.of(context).size.width;
    const double padding = 20;
    const double spacing = 4;
    double tileWidth = (screenWidth - padding * 2 - spacing) / 2;
    BadgesScreenModelState modelState = ref.watch(widget.provider);
    BadgesScreenViewModel model = ref.read(widget.provider.notifier);
    User? currentUser = ref.read(globalUserInfoProvider);
    return Scaffold(
      appBar: HoohAppBar(title: Text(globalLocalizations.badges_title)),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: MainStyles.getRefresherHeader(ref),
        onRefresh: () async {
          model.getBadges((state) {
            // debugPrint("refresh state=$state");
            _refreshController.refreshCompleted();
            _refreshController.resetNoData();
          });
        },
        onLoading: () async {
          model.getBadges((state) {
            if (state == PageState.noMore) {
              _refreshController.loadNoData();
              // debugPrint("load no more state=$state");
            } else {
              _refreshController.loadComplete();
              // debugPrint("load complete state=$state");
            }
          }, isRefresh: false);
        },
        controller: _refreshController,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: padding, top: 28, bottom: padding),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Text(
                        sprintf(globalLocalizations.badges_created_count, [modelState.createdBadgeCount]),
                        style: titleTextStyle,
                      ),
                    ),
                    Visibility(
                      child: buildCreateButton(),
                      visible: currentUser?.id == widget.userId,
                    )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: tileWidth / (165 / 180),
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => buildCreatedBadge(modelState.createdBadges[index], ended: index != 0),
                  itemCount: modelState.createdBadges.length,
                  separatorBuilder: (context, index) => SizedBox(
                    width: spacing,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: padding, right: padding, top: 36, bottom: padding),
                child: Text(sprintf(globalLocalizations.badges_received_count, [modelState.receivedBadgeCount]), style: titleTextStyle),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) => buildReceivedBadge(modelState.receivedBadges[index]),
                    childCount: modelState.receivedBadges.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: spacing, mainAxisSpacing: spacing, childAspectRatio: 165 / 204),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildCreatedBadge(UserCreatedBadge badge, {bool ended = true}) {
    String template;
    TextStyle textStyle;
    if (ended) {
      template = globalLocalizations.badges_amt_ended;
      textStyle = TextStyle(fontSize: 14, color: designColors.light_06.auto(ref));
    } else {
      template = globalLocalizations.badges_amt;
      textStyle = TextStyle(fontSize: 14, color: designColors.light_01.auto(ref), fontWeight: FontWeight.bold);
    }
    return BadgeView(imageUrl: badge.imageUrl, ratio: 165 / 180, ended: ended, isCreatedBadge: true, content: [
      SizedBox(
        height: 16,
      ),
      Text(
        badge.displayDate,
        style: textStyle.copyWith(fontSize: 12),
      ),
      SizedBox(
        height: 6,
      ),
      Text(
        sprintf(template, [formatAmount(badge.ownerAmount)]),
        style: textStyle,
      ),
    ]);
  }

  Widget buildReceivedBadge(UserBadge badge) {
    return BadgeView(imageUrl: badge.imageUrl, ratio: 165 / 204, isCreatedBadge: false, content: [
      SizedBox(
        height: 16,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(userId: badge.designer.id)));
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  globalLocalizations.badges_from,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 14, color: designColors.light_06.auto(ref)),
                ),
              ),
              SizedBox(
                width: 4,
              ),
              ClipOval(
                child: HoohImage(
                  imageUrl: badge.designer.avatarUrl!,
                  width: 24,
                  height: 24,
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Expanded(
                child: Text(
                  badge.designer.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: designColors.blue_dark.auto(ref), decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 2,
      ),
      Text(
        DateUtil.getZonedDateString(badge.createdAt, format: DateUtil.FORMAT_ONLY_DATE),
        style: TextStyle(fontSize: 14, color: designColors.light_06.auto(ref)),
      ),
      SizedBox(
        height: 6,
      ),
      Text(
        sprintf(globalLocalizations.badges_serial_number, [badge.serialNumber]),
        style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref)),
      ),
    ]);
  }

  Widget buildCreateButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SetBadgeScreen(scene: SetBadgeScreen.SCENE_CHANGE))).then((result) {
          if (result != null && result is bool && result) {
            ref.read(widget.provider.notifier).getBadgeStats(forced: true);
          }
        });
      },
      child: Row(
        children: [
          SizedBox(
            width: 8,
          ),
          Text(
            globalLocalizations.badges_create,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: designColors.light_01.light),
          ),
          HoohIcon(
            "assets/images/icon_arrow_next_ios.svg",
            color: designColors.light_01.light,
            width: 16,
            height: 16,
          )
        ],
      ),
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8), topRight: Radius.zero, bottomRight: Radius.zero),
        ),
        primary: Colors.white,
        onSurface: Colors.white,
        padding: EdgeInsets.zero,
        minimumSize: Size(100, 32),
        backgroundColor: designColors.feiyu_blue.auto(ref),
      ),
    );
  }
}

class BadgeView extends ConsumerWidget {
  final String imageUrl;
  final List<Widget> content;
  final double ratio;
  final bool ended;
  final bool isCreatedBadge;

  const BadgeView({
    required this.imageUrl,
    required this.content,
    required this.ratio,
    required this.isCreatedBadge,
    this.ended = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double radius = 20;
    final BoxShadow boxShadow = BoxShadow(color: designColors.dark_00.auto(ref).withOpacity(0.2), offset: Offset.zero, blurRadius: 10, spreadRadius: -4);
    if (isCreatedBadge) {
      if (ended) {
        return AspectRatio(
          aspectRatio: ratio,
          child: Container(
            decoration: BoxDecoration(
              color: designColors.light_02.auto(ref),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HoohImage(
                    imageUrl: imageUrl,
                    isBadge: true,
                    width: 80,
                  ),
                  ...content
                ],
              ),
            ),
          ),
        );
      } else {
        return AspectRatio(
          aspectRatio: ratio,
          child: Container(
            decoration: BoxDecoration(gradient: MainStyles.badgeGradient(ref), borderRadius: BorderRadius.circular(radius), boxShadow: [boxShadow]),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HoohImage(
                    imageUrl: imageUrl,
                    isBadge: true,
                    width: 80,
                  ),
                  ...content
                ],
              ),
            ),
          ),
        );
      }
    } else {
      return AspectRatio(
        aspectRatio: ratio,
        child: Container(
          padding: EdgeInsets.all(1),
          decoration: BoxDecoration(gradient: MainStyles.badgeGradient(ref), borderRadius: BorderRadius.circular(radius), boxShadow: [boxShadow]),
          child: Container(
            decoration: BoxDecoration(color: designColors.light_01.auto(ref), borderRadius: BorderRadius.circular(radius - 1)),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HoohImage(
                    imageUrl: imageUrl,
                    isBadge: true,
                    width: 80,
                  ),
                  ...content
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
