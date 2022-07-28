import 'package:app/global.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/utils/design_colors.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  Map<String, String?> languageCodes = {
    globalLocalizations.languages_auto: null,
    globalLocalizations.languages_en: "en",
    globalLocalizations.languages_zh: "zh",
  };

  @override
  Widget build(BuildContext context) {
    Locale? locale = ref.watch(globalLocaleProvider);
    String? code = locale?.languageCode ?? languageCodes.entries.toList()[0].value;
    return Scaffold(
      appBar: HoohAppBar(
        title: Text(AppLocalizations.of(context)!.setting_languages),
      ),
      body: CustomScrollView(slivers: [
        SliverFillRemaining(
          child: Column(
            children: [
              Divider(
                height: 1,
                color: designColors.light_02.auto(ref),
              ),
              ...languageCodes.entries.map((e) => buildTile(e.key, e.value, code))
            ],
          ),
        )
      ]),
    );
  }

  Widget buildTile(String title, String? languageCode, String? selectedCode) {
    TextStyle? titleTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref));
    return Ink(
      child: InkWell(
        onTap: () {
          _onChange(languageCode);
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
                Radio<String?>(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: languageCode,
                    groupValue: selectedCode,
                    onChanged: (code) {
                      _onChange(languageCode);
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onChange(String? code) {
    ref.read(globalLocaleProvider.state).state = code == null ? null : Locale(code);
    preferences.putString(Preferences.KEY_LANGUAGE, code);
  }
}
