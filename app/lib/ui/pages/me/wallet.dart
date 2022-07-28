import 'package:app/global.dart';
import 'package:app/ui/pages/me/wallet_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/user.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

class WalletScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<WalletScreenViewModel, WalletScreenModelState> provider;
  final Map<int, String> costMap = {
    WalletLog.COST_TYPE_INTO_WAITING_LIST: globalLocalizations.wallet_cost_type_into_waiting_list,
    WalletLog.COST_TYPE_CREATE_BADGE: globalLocalizations.wallet_cost_type_create_badge,
    WalletLog.COST_TYPE_DELETE_ACTIVITY: globalLocalizations.wallet_cost_type_delete_activity,
    WalletLog.COST_TYPE_VOTE_POST: globalLocalizations.wallet_cost_type_vote_post,
  };

  WalletScreen({
    required String userId,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return WalletScreenViewModel(WalletScreenModelState.init(userId));
    });
  }

  @override
  ConsumerState createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  late final Color cardShadowColor;
  late final List<BoxShadow> cardShadow;

  _WalletScreenState() {
    cardShadowColor = Colors.black.withAlpha((255 * 0.2).toInt());
    cardShadow = [BoxShadow(color: cardShadowColor, blurRadius: 10, spreadRadius: -4)];
  }

  @override
  Widget build(BuildContext context) {
    WalletScreenModelState modelState = ref.watch(widget.provider);
    WalletScreenViewModel model = ref.read(widget.provider.notifier);
    Widget body;
    UserWalletOverviewResponse? response = modelState.response;
    Size screenSize = MediaQuery.of(context).size;
    double gridItemWidth = 140;
    double gridHorizontalSpacing = 12;
    double gridVerticalSpacing = 6;
    int gridColumnCount = (screenSize.width - 20 * 4 + gridHorizontalSpacing) ~/ (gridItemWidth - gridHorizontalSpacing);
    gridItemWidth = screenSize.width - 20 * 4 + (gridColumnCount + 1) * gridHorizontalSpacing / gridColumnCount;
    double gridItemHeight = 48;
    if (response != null) {
      body = CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: MainStyles.getRefresherHeader(ref),
              onRefresh: () async {
                model.getOverview((error) {
                  if (error != null) {
                    showCommonRequestErrorDialog(ref, context, error);
                  }
                });
              },
              controller: _refreshController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      globalLocalizations.wallet_overview,
                      style: TextStyle(fontSize: 16, color: designColors.dark_01.auto(ref)),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HoohIcon(
                          "assets/images/common_ore.svg",
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(sprintf(globalLocalizations.me_wallet_ore_amount, [formatCurrency(response.balanceInt, precise: true)]),
                            style: TextStyle(color: designColors.feiyu_blue.auto(ref), fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(
                      height: 36,
                    ),
                    buildDataRow(response, globalLocalizations.wallet_pow, response.totalEarnedPowInt, () {}),
                    SizedBox(
                      height: 32,
                    ),
                    buildDataRow(response, globalLocalizations.wallet_reputation, response.totalEarnedReputationInt, () {}),
                    SizedBox(
                      height: 32,
                    ),
                    (buildCard(Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              globalLocalizations.wallet_cost,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref)),
                            ),
                            Expanded(
                              child: Text(formatCurrency(-response.totalCostInt, precise: true, withSymbol: true),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(color: designColors.orange.auto(ref), fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            HoohIcon(
                              "assets/images/common_ore.svg",
                              width: 24,
                              height: 24,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        GridView(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: gridItemWidth / gridItemHeight,
                              crossAxisCount: gridColumnCount,
                              mainAxisSpacing: gridVerticalSpacing,
                              crossAxisSpacing: gridHorizontalSpacing),
                          children: getGridItems(response),
                        )
                      ],
                    ))),
                  ],
                ),
              ),
            ),
          )
        ],
      );
    } else {
      body = Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: HoohAppBar(
        title: Text(globalLocalizations.me_wallet),
      ),
      body: body,
    );
  }

  List<Widget> getGridItems(UserWalletOverviewResponse response) {
    Map<int, int> costs = response.costByCategory;
    return costs
        .map((key, value) => MapEntry(widget.costMap[key] ?? globalLocalizations.wallet_cost_type_other, value))
        .entries
        .map((e) => Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.ideographic,
              children: [
                Text(
                  e.key,
                  style: TextStyle(color: designColors.dark_01.auto(ref)),
                ),
                Expanded(
                    child: Text(
                  formatCurrency(e.value),
                  style: TextStyle(fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref)),
                  textAlign: TextAlign.right,
                ))
              ],
            ))
        .toList();
  }

  Widget buildDataRow(UserWalletOverviewResponse response, String title, int amount, Function() callback) {
    return buildCard(Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref)),
        ),
        Expanded(
          child: Text(formatCurrency(amount, precise: true, withSymbol: true),
              textAlign: TextAlign.right, style: TextStyle(color: designColors.feiyu_blue.auto(ref), fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          width: 4,
        ),
        HoohIcon(
          "assets/images/common_ore.svg",
          width: 24,
          height: 24,
        ),
      ],
    ));
  }

  Widget buildCard(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: buildCardDecoration(),
      child: child,
    );
  }

  BoxDecoration buildCardDecoration() => BoxDecoration(boxShadow: cardShadow, borderRadius: BorderRadius.circular(20), color: designColors.light_01.auto(ref));
}
