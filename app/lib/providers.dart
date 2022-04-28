import 'package:app/utils/design_colors.dart';
import 'package:common/models/user.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final StateProvider<User?> globalUserInfoProvider = StateProvider<User?>((ref) => null);

final StateProvider<bool> globalDarkModeProvider = StateProvider((ref) {
  return false;
});
final StateProvider<ThemeData> globalThemeDataProvider = StateProvider((ref) {
  bool darkMode = ref.watch(globalDarkModeProvider.state).state;

  return darkMode ? globalDarkTheme : globalLightTheme;
});
final globalLightTheme = ThemeData(
    primaryColor: designColors.bar90_1.light,
    brightness: Brightness.light,
    backgroundColor: designColors.light_00.light,
    fontFamily: 'Linotte',
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: designColors.bar90_1.light,
      titleTextStyle: TextStyle(color: designColors.dark_01.light, fontFamily: 'Linotte', fontWeight: FontWeight.bold, fontSize: 16),
      actionsIconTheme: IconThemeData(color: designColors.dark_01.light),
      iconTheme: IconThemeData(color: designColors.dark_01.light),
      foregroundColor: designColors.feiyu_blue.generic,
      toolbarTextStyle: TextStyle(color: designColors.feiyu_blue.generic, fontFamily: 'Linotte', fontWeight: FontWeight.bold, fontSize: 16),
      // shadowColor: Colors.transparent,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
    }),
    dialogTheme: DialogTheme(
      backgroundColor: designColors.light_01.light,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
    ),
    checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.all(designColors.light_01.light),
        fillColor: MaterialStateProperty.all(designColors.dark_01.light),
        side: BorderSide(color: designColors.dark_01.light, width: 1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        )),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
                TextStyle(fontSize: 16, color: designColors.feiyu_blue.generic, fontFamily: 'Linotte', fontWeight: FontWeight.bold)))));

final globalDarkTheme = ThemeData(
    primaryColor: designColors.bar90_1.dark,
    brightness: Brightness.dark,
    backgroundColor: designColors.light_00.dark,
    fontFamily: 'Linotte',
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: designColors.bar90_1.dark,
      titleTextStyle: TextStyle(color: designColors.dark_01.dark, fontFamily: 'Linotte', fontWeight: FontWeight.bold, fontSize: 16),
      actionsIconTheme: IconThemeData(color: designColors.dark_01.dark),
      iconTheme: IconThemeData(color: designColors.dark_01.dark),
      foregroundColor: designColors.feiyu_blue.generic,
      toolbarTextStyle: TextStyle(color: designColors.feiyu_blue.generic, fontFamily: 'Linotte', fontWeight: FontWeight.bold, fontSize: 16),
      // shadowColor: Colors.transparent,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    }),
    dialogTheme: DialogTheme(
      backgroundColor: designColors.light_01.dark,
      shape: const RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(24))),
    ),
    checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.all(designColors.light_01.dark),
        fillColor: MaterialStateProperty.all(designColors.dark_01.dark),
        side: BorderSide(color: designColors.dark_01.dark, width: 1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        )),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
                TextStyle(fontSize: 16, color: designColors.feiyu_blue.generic, fontFamily: 'Linotte', fontWeight: FontWeight.bold)))));
