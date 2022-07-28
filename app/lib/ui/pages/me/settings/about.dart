import 'package:app/global.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:sprintf/sprintf.dart';

class AboutScreen extends ConsumerStatefulWidget {
  static const USER_AGREEMENT_URL = "https://www.hooh.zone/user-agreement/";
  static const PRIVACY_POLICY_URL = "https://www.hooh.zone/privacy-policy/";

  const AboutScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HoohAppBar(
        title: Text(AppLocalizations.of(context)!.setting_about),
      ),
      body: CustomScrollView(slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: [
              SizedBox(
                height: 36,
              ),
              HoohIcon(
                "assets/images/logo.png",
                width: 128,
                height: 128,
              ),
              SizedBox(height: 16),
              Text(
                globalLocalizations.common_app_name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref)),
              ),
              SizedBox(height: 4),
              Text(
                sprintf(globalLocalizations.about_version, [deviceInfo.appVersion]),
                style: TextStyle(fontSize: 14, color: designColors.light_06.auto(ref)),
              ),
              SizedBox(height: 24),
              Divider(
                height: 1,
                color: designColors.light_02.auto(ref),
              ),
              buildTile(globalLocalizations.register_user_agreement, () {
                openLink(context, AboutScreen.USER_AGREEMENT_URL, title: globalLocalizations.register_user_agreement);
              }),
              buildTile(globalLocalizations.register_privacy_policy, () {
                openLink(context, AboutScreen.PRIVACY_POLICY_URL, title: globalLocalizations.register_privacy_policy);
              }),
              buildTile(globalLocalizations.about_voted, () async {
                final InAppReview inAppReview = InAppReview.instance;
                if (await inAppReview.isAvailable()) {
                  inAppReview.requestReview();
                }
              }),
              Spacer(
                flex: 2,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  sprintf(globalLocalizations.about_copyrights, [DateUtil.getZonedDateString(DateUtil.getCurrentUtcDate(), format: "yyyy")]),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: designColors.light_06.auto(ref)),
                ),
              ),
              Spacer(
                flex: 1,
              ),
            ],
          ),
        )
      ]),
    );
  }

  Widget buildTile(String title, Function() onPress) {
    TextStyle? titleTextStyle = TextStyle(
      fontSize: 14,
      color: designColors.light_06.auto(ref),
      fontWeight: FontWeight.bold,
    );
    return Ink(
      child: InkWell(
        onTap: () {
          onPress();
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: designColors.light_02.auto(ref), width: 1))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  title,
                  style: titleTextStyle,
                ),
                const Spacer(),
                HoohIcon(
                  "assets/images/icon_arrow_next_ios.svg",
                  width: 24,
                  height: 24,
                  color: designColors.light_06.auto(ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
