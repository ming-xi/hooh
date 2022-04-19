import 'package:app/providers.dart';
import 'package:app/utils/design_colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RegisterStyles {
  static TextStyle titleTextStyle(WidgetRef ref) {
    return ref.watch(globalThemeDataProvider.state).state.textTheme.bodyText1!.copyWith(fontSize: 16, color: designColors.dark_01.auto(ref));
  }

  static TextStyle inputTextStyle(WidgetRef ref) {
    return ref.watch(globalThemeDataProvider.state).state.textTheme.bodyText1!.copyWith(fontSize: 16, color: designColors.dark_01.auto(ref));
  }

  static TextStyle hintTextStyle(WidgetRef ref) {
    return ref.watch(globalThemeDataProvider.state).state.textTheme.bodyText1!.copyWith(fontSize: 16, color: designColors.dark_03.auto(ref));
  }

  static TextStyle descriptionTextStyle(WidgetRef ref) {
    return ref.watch(globalThemeDataProvider.state).state.textTheme.bodyText1!.copyWith(fontSize: 16, color: designColors.feiyu_blue.auto(ref));
  }

  static TextStyle errorTextStyle(WidgetRef ref) {
    return ref.watch(globalThemeDataProvider.state).state.textTheme.bodyText1!.copyWith(fontSize: 16, color: designColors.orange.auto(ref));
  }

  static InputDecoration commonInputDecoration(String hint, WidgetRef ref, {String? helperText, String? errorText}) {
    return InputDecoration(
        hintText: hint,
        hintStyle: hintTextStyle(ref),
        errorText: errorText,
        helperText: helperText,
        helperStyle: descriptionTextStyle(ref),
        errorStyle: errorTextStyle(ref),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(22.0))));
  }

  static ButtonStyle blueButtonStyle(WidgetRef ref) {
    return TextButton.styleFrom(
        primary: designColors.light_01.auto(ref),
        onSurface: designColors.light_01.auto(ref),
        minimumSize: const Size.fromHeight(64),
        backgroundColor: designColors.feiyu_blue.auto(ref),
        textStyle: ref.watch(globalThemeDataProvider.state).state.textTheme.bodyText1!.copyWith(fontSize: 16));
  }

  static ButtonStyle appbarTextButtonStyle(WidgetRef ref) {
    return TextButton.styleFrom(
        primary: designColors.feiyu_blue.auto(ref),
        onSurface: designColors.feiyu_blue.auto(ref),
        backgroundColor: Colors.transparent,
        textStyle: ref.watch(globalThemeDataProvider.state).state.textTheme.bodyText1!.copyWith(fontSize: 16));
  }

  static ButtonStyle blackButtonStyle(WidgetRef ref) {
    return TextButton.styleFrom(
        primary: designColors.light_01.auto(ref),
        onSurface: designColors.light_01.auto(ref),
        minimumSize: const Size.fromHeight(64),
        backgroundColor: designColors.dark_01.auto(ref),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(22.0)),
        ),
        textStyle: ref.watch(globalThemeDataProvider.state).state.textTheme.button!.copyWith(fontSize: 20, fontWeight: FontWeight.bold));
  }

  static ButtonStyle blackOutlineButtonStyle(WidgetRef ref) {
    return TextButton.styleFrom(
        primary: designColors.dark_01.auto(ref),
        onSurface: designColors.dark_01.auto(ref),
        backgroundColor: designColors.light_01.auto(ref),
        shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(22.0)), side: BorderSide(color: designColors.dark_01.auto(ref))),
        minimumSize: const Size.fromHeight(64),
        side: BorderSide(width: 1, color: designColors.dark_01.auto(ref)),
        textStyle: ref.watch(globalThemeDataProvider.state).state.textTheme.button!.copyWith(fontSize: 20, fontWeight: FontWeight.bold));
  }
}
