import 'package:app/ui/pages/me/badges_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BadgesScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<BadgesScreenViewModel, BadgesScreenModelState> templatesProvider;

  BadgesScreen({
    required String userId,
    Key? key,
  }) : super(key: key) {
    templatesProvider = StateNotifierProvider((ref) {
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
    BadgesScreenModelState modelState = ref.watch(widget.templatesProvider);
    BadgesScreenViewModel model = ref.read(widget.templatesProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text("Social Icon")),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: MaterialClassicHeader(
          // offset: totalHeight,
          color: designColors.feiyu_blue.auto(ref),
        ),
        onRefresh: () async {
          model.getBadges((state) {
            debugPrint("refresh state=$state");
            _refreshController.refreshCompleted();
          });
        },
        onLoading: () async {
          model.getBadges((state) {
            if (state == PageState.noMore) {
              _refreshController.loadNoData();
              debugPrint("load no more state=$state");
            } else {
              _refreshController.loadComplete();
              debugPrint("load complete state=$state");
            }
          }, isRefresh: false);
        },
        controller: _refreshController,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: padding, right: padding, top: 28, bottom: padding),
                child: Text(
                  "Personal Social Icon ${modelState.createdBadgeCount}",
                  style: titleTextStyle,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: tileWidth / (165 / 180),
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => buildCreatedBadge(modelState.createdBadges[index]),
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
                child: Text("Possess Social Icon ${modelState.receivedBadgeCount}", style: titleTextStyle),
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

  Widget buildCreatedBadge(UserCreatedBadge badge) {
    return BadgeView(imageUrl: badge.imageUrl, ratio: 165 / 180, content: [
      SizedBox(
        height: 16,
      ),
      Text(
        badge.displayDate,
        style: TextStyle(fontSize: 12, color: designColors.light_06.auto(ref)),
      ),
      SizedBox(
        height: 6,
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Number : ",
            style: TextStyle(fontSize: 14, color: designColors.light_06.auto(ref)),
          ),
          Text(
            formatAmount(badge.ownerAmount),
            style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ]);
  }

  Widget buildReceivedBadge(UserBadge badge) {
    return BadgeView(imageUrl: badge.imageUrl, ratio: 165 / 204, content: [
      SizedBox(
        height: 16,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GestureDetector(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "From : ",
                style: TextStyle(fontSize: 14, color: designColors.light_06.auto(ref)),
              ),
              ClipOval(
                child: HoohImage(
                  imageUrl: badge.designer.avatarUrl!,
                  width: 24,
                  height: 24,
                ),
              ),
              SizedBox(
                width: 2,
              ),
              Expanded(
                child: Text(
                  badge.designer.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: designColors.blue_dark.auto(ref), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
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
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "#No.  ",
            style: TextStyle(fontSize: 14, color: designColors.light_06.auto(ref)),
          ),
          Text(
            badge.serialNumber.toString(),
            style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref)),
          ),
        ],
      ),
    ]);
  }
}

class BadgeView extends ConsumerWidget {
  final String imageUrl;
  final List<Widget> content;
  final double ratio;

  const BadgeView({
    required this.imageUrl,
    required this.content,
    required this.ratio,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double radius = 20;
    return AspectRatio(
      aspectRatio: ratio,
      child: Container(
        padding: EdgeInsets.all(1),
        decoration: BoxDecoration(gradient: MainStyles.badgeGradient(), borderRadius: BorderRadius.circular(radius)),
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
