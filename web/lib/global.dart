import 'dart:convert';

import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

late AppLocalizations globalLocalizations;
double globalDarkModeImageOpacity = 0.7;
int globalDarkModeImageAlpha = (255 * globalDarkModeImageOpacity).toInt();

final StateProvider<bool> globalKeyboardInfoProvider = StateProvider<bool>((ref) => false);
final StateProvider<User?> globalUserInfoProvider = StateProvider<User?>((ref) => null);
final StateProvider<Locale?> globalLocaleProvider = StateProvider<Locale?>((ref) => null);
const DARK_MODE_SYSTEM = 0;
const DARK_MODE_LIGHT = 1;
const DARK_MODE_DARK = 2;
const DARK_MODE_VALUES = [
  DARK_MODE_SYSTEM,
  DARK_MODE_LIGHT,
  DARK_MODE_DARK,
];
final StateProvider<int> globalDarkModeProvider = StateProvider((ref) {
  return DARK_MODE_SYSTEM;
});
