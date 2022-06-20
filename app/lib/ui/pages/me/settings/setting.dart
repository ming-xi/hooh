import 'package:app/global.dart';
import 'package:app/ui/pages/me/settings/account.dart';
import 'package:app/utils/design_colors.dart';
import 'package:badges/badges.dart';
import 'package:common/models/user.dart';
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
    User? user = ref.watch(globalUserInfoProvider);
    TextStyle? titleTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref));
    TextStyle? subTitleTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref));

    var push = buildTile(AppLocalizations.of(context)!.setting_push, showArrow: true);
    var account = buildTile(AppLocalizations.of(context)!.setting_account, showArrow: true, showDot: true, onPress: () {
      // debugPrint("account");
      Navigator.push(context, MaterialPageRoute(builder: (context) => AccountScreen()));
    });
    var language = buildTile(AppLocalizations.of(context)!.setting_languages, showArrow: true);
    var dark = buildTile(AppLocalizations.of(context)!.setting_dark_mode, tailText: AppLocalizations.of(context)!.setting_dark_mode_auto, showArrow: true);
    var cache = buildTile(AppLocalizations.of(context)!.setting_clear_cache, tailText: '24MB');
    var help = buildTile(AppLocalizations.of(context)!.setting_help, showArrow: true);
    var about = buildTile(AppLocalizations.of(context)!.setting_about, showArrow: true);
    var logout = buildTile(AppLocalizations.of(context)!.setting_logout, showArrow: false);
    List<Widget> tiles = [
      Divider(
        height: 1,
        thickness: 1,
        color: designColors.light_02.auto(ref),
      ),
      account,
      language,
      push,
      dark,
      cache,
      help,
      about,
      logout,
    ];
    if (user == null) {
      tiles.remove(push);
      tiles.remove(logout);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.setting_title),
      ),
      body: CustomScrollView(slivers: [
        SliverFillRemaining(
          child: Column(
            children: tiles,
          ),
        )
      ]),
    );
  }

  Widget buildTile(String title, {bool showDot = false, bool showArrow = false, String? tailText, Function()? onPress}) {
    TextStyle? titleTextStyle = TextStyle(
        fontSize: 14,
        // fontWeight: FontWeight.bold,
        color: designColors.light_06.auto(ref));
    TextStyle? subTitleTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref));
    TextStyle? cacheTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: designColors.dark_01.auto(ref));

    var titleWidget = Text(
      title,
      style: titleTextStyle,
    );
    return Ink(
      child: InkWell(
        onTap: onPress,
        child: Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: designColors.light_02.auto(ref), width: 1))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                !showDot
                    ? titleWidget
                    : Badge(
                        child: titleWidget,
                        position: BadgePosition.topEnd(end: -8, top: -4),
                        badgeColor: designColors.orange.auto(ref),
                        elevation: 0,
                        shape: BadgeShape.circle,
                        padding: EdgeInsets.all(4),
                      ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    tailText ?? "",
                    style: showArrow ? subTitleTextStyle : cacheTextStyle,
                  ),
                ),
                Visibility(
                  visible: showArrow,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: designColors.light_06.auto(ref),
                    size: 28,
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
