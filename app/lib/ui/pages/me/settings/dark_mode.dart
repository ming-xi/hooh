import 'package:app/global.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/utils/design_colors.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DarkModeScreen extends ConsumerStatefulWidget {
  const DarkModeScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _DarkModeScreenState();
}

class _DarkModeScreenState extends ConsumerState<DarkModeScreen> {
  Map<String, int> languageCodes = {
    globalLocalizations.dark_mode_auto: DARK_MODE_SYSTEM,
    globalLocalizations.dark_mode_light: DARK_MODE_LIGHT,
    globalLocalizations.dark_mode_dark: DARK_MODE_DARK,
  };

  @override
  Widget build(BuildContext context) {
    debugPrint("dark mode build");
    int darkMode = ref.watch(globalDarkModeProvider);
    return Scaffold(
      appBar: HoohAppBar(
        title: Text(AppLocalizations.of(context)!.setting_dark_mode),
      ),
      body: CustomScrollView(slivers: [
        SliverFillRemaining(
          child: Column(
            children: [
              Divider(
                height: 1,
                color: designColors.light_02.auto(ref),
              ),
              ...languageCodes.entries.map((e) => buildTile(e.key, e.value, darkMode))
            ],
          ),
        )
      ]),
    );
  }

  Widget buildTile(String title, int mode, int selectedMode) {
    TextStyle? titleTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref));
    return Ink(
      child: InkWell(
        onTap: () {
          _onChange(mode);
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
                Radio<int>(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: mode,
                    groupValue: selectedMode,
                    onChanged: (code) {
                      _onChange(mode);
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onChange(int code) {
    ref.read(globalDarkModeProvider.state).state = code;
    preferences.putInt(Preferences.KEY_DARK_MODE, code);
  }
}
