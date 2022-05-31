import 'package:app/ui/pages/me/settings/account.dart';
import 'package:app/utils/design_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    TextStyle? titleTextStyle = TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: designColors.light_06.auto(ref));
    TextStyle? subTitleTextStyle = TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: designColors.light_06.auto(ref));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.setting_title),
      ),
      body: CustomScrollView(slivers: [
        SliverFillRemaining(
          child: Column(
            children: [
              Divider(
                height: 1,
                color: designColors.light_02.auto(ref),
              ),
              buildTile(AppLocalizations.of(context)!.setting_account,
                  showArrow: true, showDot: true, onPress: () {
                // debugPrint("account");
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AccountScreen()));
              }),
              buildTile(AppLocalizations.of(context)!.setting_languages,
                  showArrow: true),
              buildTile(AppLocalizations.of(context)!.setting_account,
                  tailText: AppLocalizations.of(context)!
                      .setting_picture_quality_high,
                  showArrow: true),
              buildTile(AppLocalizations.of(context)!.setting_push,
                  showArrow: true),
              buildTile(AppLocalizations.of(context)!.setting_dark_mode,
                  tailText:
                      AppLocalizations.of(context)!.setting_dark_mode_auto,
                  showArrow: true),
              buildTile(AppLocalizations.of(context)!.setting_clear_cache,
                  tailText: '24MB'),
              buildTile(AppLocalizations.of(context)!.setting_help,
                  showArrow: true),
              buildTile(AppLocalizations.of(context)!.setting_about,
                  showArrow: true),
              buildTile(AppLocalizations.of(context)!.setting_logout,
                  showArrow: false),
            ],
          ),
        )
      ]),
    );
  }

  Widget buildTile(String title,
      {bool showDot = false,
      bool showArrow = false,
      String? tailText,
      Function()? onPress}) {
    TextStyle? titleTextStyle = TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: designColors.light_06.auto(ref));
    TextStyle? subTitleTextStyle = TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: designColors.light_06.auto(ref));
    TextStyle? cacheTextStyle = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: designColors.dark_01.auto(ref));

    return Ink(
      child: InkWell(
        onTap: onPress,
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: designColors.light_02.auto(ref), width: 1))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              children: [
                Text(
                  title,
                  style: titleTextStyle,
                ),
                Visibility(
                    visible: showDot,
                    child: SizedBox(
                      height: 16,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: designColors.orange.auto(ref),
                                borderRadius: BorderRadius.circular(100)),
                            width: 8,
                            height: 8,
                          ),
                          Spacer(),
                        ],
                      ),
                    )),
                const Spacer(),
                Text(
                  tailText ?? "",
                  style: showArrow ? subTitleTextStyle : cacheTextStyle,
                ),
                Visibility(
                  visible: showArrow,
                  child: Icon(
                    Icons.chevron_right,
                    color: designColors.light_06.auto(ref),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
