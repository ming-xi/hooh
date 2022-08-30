import 'package:app/global.dart';
import 'package:app/ui/pages/me/settings/about.dart';
import 'package:app/ui/pages/me/settings/account.dart';
import 'package:app/ui/pages/me/settings/dark_mode.dart';
import 'package:app/ui/pages/me/settings/language.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:badges/badges.dart';
import 'package:common/models/user.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String cacheSize = globalLocalizations.setting_cache_calculating;

  @override
  void initState() {
    super.initState();
    refreshCacheSize();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("setting build");
    // important! make it change text when locale changes
    ref.watch(globalLocaleProvider);
    User? user = ref.watch(globalUserInfoProvider);
    TextStyle? titleTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref));
    TextStyle? subTitleTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref));

    var push = buildTile(globalLocalizations.setting_push, showArrow: true);
    var account = buildTile(globalLocalizations.setting_account, showArrow: true, showDot: !(user?.emailValidated ?? false), onPress: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AccountScreen()));
    });
    var language = buildTile(globalLocalizations.setting_languages, showArrow: true, onPress: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LanguageScreen()));
    });
    var dark = buildTile(globalLocalizations.setting_dark_mode, tailText: getDarkModeTailText(), showArrow: true, onPress: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => DarkModeScreen()));
    });
    var cache = buildTile(globalLocalizations.setting_clear_cache, tailText: cacheSize, onPress: () {
      clearCache().then((_) {
        refreshCacheSize();
      });
    });
    var help = buildTile(globalLocalizations.setting_help, showArrow: true, onPress: () {
      openLink(context, "https://www.hooh.zone/help-support/", title: globalLocalizations.setting_help);
    });
    var about = buildTile(globalLocalizations.setting_about, showArrow: true, onPress: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AboutScreen()));
    });
    var logout = buildTile(globalLocalizations.setting_logout, showArrow: false, onPress: () {
      handleUserLogout(ref);
    });
    List<Widget> tiles = [
      Divider(
        height: 1,
        thickness: 1,
        color: designColors.light_02.auto(ref),
      ),
      account,
      language,
      // push,
      dark,
      cache,
      help,
      about,
      logout,
    ];
    if (user == null) {
      tiles.remove(account);
      // tiles.remove(push);
      tiles.remove(logout);
    }
    return Scaffold(
      appBar: HoohAppBar(
        title: Text(globalLocalizations.setting_title),
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
    TextStyle? titleTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref));
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
                  child: HoohIcon(
                    "assets/images/icon_arrow_next_ios.svg",
                    width: 24,
                    height: 24,
                    color: designColors.light_06.auto(ref),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getDarkModeTailText() {
    int darkMode = ref.watch(globalDarkModeProvider);
    switch (darkMode) {
      case DARK_MODE_LIGHT:
        {
          return globalLocalizations.dark_mode_light;
        }
      case DARK_MODE_DARK:
        {
          return globalLocalizations.dark_mode_dark;
        }
      case DARK_MODE_SYSTEM:
      default:
        {
          return globalLocalizations.dark_mode_auto;
        }
    }
  }

  Future<int> getCacheSize() async {
    String appDir = (await getTemporaryDirectory()).path;
    return dirStatSync(appDir)['size'] ?? 0;
  }

  Map<String, int> dirStatSync(String dirPath) {
    int fileNum = 0;
    int totalSize = 0;
    var dir = Directory(dirPath);
    try {
      if (dir.existsSync()) {
        dir.listSync(recursive: true, followLinks: false).forEach((FileSystemEntity entity) {
          if (entity is File) {
            fileNum++;
            totalSize += entity.lengthSync();
          }
        });
      }
    } catch (e) {
      print(e.toString());
    }

    return {'fileNum': fileNum, 'size': totalSize};
  }

  void refreshCacheSize() {
    getCacheSize().then((size) {
      setState(() {
        cacheSize = formatFileSize(size);
      });
    });
  }

  Future<void> clearCache() async {
    String appDir = (await getTemporaryDirectory()).path;
    await Directory(appDir).delete(recursive: true);
  }
}
