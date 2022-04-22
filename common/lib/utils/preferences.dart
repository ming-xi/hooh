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

  void putString(String key, String? value) {
    if (value == null) {
      _prefs.remove(key);
      return;
    }
    _prefs.setString(key, value);
  }

  void putInt(String key, int? value) async {
    if (value == null) {
      _prefs.remove(key);
      return;
    }
    _prefs.setInt(key, value);
  }

  void putDouble(String key, double? value) async {
    if (value == null) {
      _prefs.remove(key);
      return;
    }
    _prefs.setDouble(key, value);
  }

  void putBool(String key, bool? value) async {
    if (value == null) {
      _prefs.remove(key);
      return;
    }
    _prefs.setBool(key, value);
  }
}
