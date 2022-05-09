import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

Preferences preferences = Preferences._internal();

class Preferences {
  /// 顶层变量，单例模式
  Preferences._internal();

  static const KEY_USER_ACCESS_TOKEN = "KEY_USER_ACCESS_TOKEN";
  static const KEY_USER_HAS_SKIPPED_LOGIN = "KEY_USER_HAS_SKIPPED_LOGIN";
  static const KEY_USER_INFO = "KEY_USER_INFO";
  static const KEY_DARK_MODE = "KEY_DARK_MODE";
  static const KEY_SERVER = "KEY_SERVER";
  static const KEY_UPLOAD_TEMPLATE_AGREEMENT_CHECKED = "KEY_UPLOAD_TEMPLATE_AGREEMENT_CHECKED";
  static const KEY_USER_DRAFT = "KEY_USER_DRAFT";

  Future<void> init() async {
    // SharedPreferences.getInstance().then((value) {
    //    _prefs = value;
    //    debugPrint("Preferences ready");
    // });
    _prefs = await SharedPreferences.getInstance();
    debugPrint("Preferences ready");
  }

  late SharedPreferences _prefs;

  bool hasKey(String key) {
    return _prefs.containsKey(key);
  }

  String? getString(String key) {
    var value = _prefs.getString(key);
    return value;
  }

  int? getInt(String key) {
    var value = _prefs.getInt(key);
    return value;
  }

  double? getDouble(String key) {
    var value = _prefs.getDouble(key);
    return value;
  }

  bool? getBool(String key) {
    var value = _prefs.getBool(key);
    return value;
  }

  void putString(String key, String? value) async {
    if (value == null) {
      await _prefs.remove(key);
      return;
    }
    await _prefs.setString(key, value);
  }

  void putInt(String key, int? value) async {
    if (value == null) {
      await _prefs.remove(key);
      return;
    }
    await _prefs.setInt(key, value);
  }

  void putDouble(String key, double? value) async {
    if (value == null) {
      await _prefs.remove(key);
      return;
    }
    await _prefs.setDouble(key, value);
  }

  void putBool(String key, bool? value) async {
    if (value == null) {
      await _prefs.remove(key);
      return;
    }
    await _prefs.setBool(key, value);
  }

  void remove(String key) async {
    await _prefs.remove(key);
  }
}
