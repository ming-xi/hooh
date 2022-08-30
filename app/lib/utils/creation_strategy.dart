import 'package:flutter/material.dart';

class CreationStrategy {
  static const double DEFAULT_FONT_SIZE = 8;

  static const _FONT_LEN_STOP1 = 6 ~/ 2;
  static const _FONT_LEN_STOP2 = 16 ~/ 2;
  static const _FONT_LEN_STOP3 = 40 ~/ 2;
  static const _FONT_LEN_STOP4 = 100 ~/ 2;
  static const _FONT_LEN_STOP5 = 200 ~/ 2;

  // static const _FONT_LEN_STOP1 = 6;
  // static const _FONT_LEN_STOP2 = 16;
  // static const _FONT_LEN_STOP3 = 40;
  // static const _FONT_LEN_STOP4 = 100;
  // static const _FONT_LEN_STOP5 = 200;
  static const _FONT_SIZE_MAP = <String?, Map<int?, double>>{
    'Linotte': {
      _FONT_LEN_STOP1: 100,
      _FONT_LEN_STOP2: 52,
      _FONT_LEN_STOP3: 36,
      _FONT_LEN_STOP4: 30,
      _FONT_LEN_STOP5: 24,
      null: 20,
    },
    'Montserrat': {
      _FONT_LEN_STOP1: 100,
      _FONT_LEN_STOP2: 52,
      _FONT_LEN_STOP3: 36,
      _FONT_LEN_STOP4: 30,
      _FONT_LEN_STOP5: 24,
      null: 18,
    },
    'Antonio': {
      _FONT_LEN_STOP1: 100,
      _FONT_LEN_STOP2: 52,
      _FONT_LEN_STOP3: 36,
      _FONT_LEN_STOP4: 30,
      _FONT_LEN_STOP5: 24,
      null: 20,
    },
    'Baloo': {
      _FONT_LEN_STOP1: 100,
      _FONT_LEN_STOP2: 52,
      _FONT_LEN_STOP3: 36,
      _FONT_LEN_STOP4: 30,
      _FONT_LEN_STOP5: 24,
      null: 18,
    },
    'Edo': {
      _FONT_LEN_STOP1: 100,
      _FONT_LEN_STOP2: 52,
      _FONT_LEN_STOP3: 36,
      _FONT_LEN_STOP4: 30,
      _FONT_LEN_STOP5: 24,
      null: 18,
    },
    'Lobster': {
      _FONT_LEN_STOP1: 100,
      _FONT_LEN_STOP2: 52,
      _FONT_LEN_STOP3: 36,
      _FONT_LEN_STOP4: 30,
      _FONT_LEN_STOP5: 24,
      null: 20,
    },
    'Song': {
      _FONT_LEN_STOP1: 100,
      _FONT_LEN_STOP2: 52,
      _FONT_LEN_STOP3: 36,
      _FONT_LEN_STOP4: 30,
      _FONT_LEN_STOP5: 24,
      null: 18,
    },
    'Heiti': {
      _FONT_LEN_STOP1: 100,
      _FONT_LEN_STOP2: 52,
      _FONT_LEN_STOP3: 36,
      _FONT_LEN_STOP4: 30,
      _FONT_LEN_STOP5: 24,
      null: 18,
    },
    'Zhuokai': {
      _FONT_LEN_STOP1: 100,
      _FONT_LEN_STOP2: 52,
      _FONT_LEN_STOP3: 36,
      _FONT_LEN_STOP4: 30,
      _FONT_LEN_STOP5: 24,
      null: 18,
    },
    null: {
      _FONT_LEN_STOP1: 100,
      _FONT_LEN_STOP2: 52,
      _FONT_LEN_STOP3: 36,
      _FONT_LEN_STOP4: 30,
      _FONT_LEN_STOP5: 24,
      null: 18,
    },
  };
  static const _FONT_LINE_HEIGHT_MAP = <String?, Map<int?, double>>{
    'Linotte': {
      _FONT_LEN_STOP1: 1.5,
      _FONT_LEN_STOP2: 1.5,
      _FONT_LEN_STOP3: 1.25,
      _FONT_LEN_STOP4: 1.25,
      _FONT_LEN_STOP5: 1.2,
      null: 1.2,
    },
    'Montserrat': {
      _FONT_LEN_STOP1: 1.5,
      _FONT_LEN_STOP2: 1.5,
      _FONT_LEN_STOP3: 1.25,
      _FONT_LEN_STOP4: 1.25,
      _FONT_LEN_STOP5: 1.2,
      null: 1.2,
    },
    'Antonio': {
      _FONT_LEN_STOP1: 1.5,
      _FONT_LEN_STOP2: 1.5,
      _FONT_LEN_STOP3: 1.25,
      _FONT_LEN_STOP4: 1.25,
      _FONT_LEN_STOP5: 1.2,
      null: 1.25,
    },
    'Baloo': {
      _FONT_LEN_STOP1: 1.5,
      _FONT_LEN_STOP2: 1.5,
      _FONT_LEN_STOP3: 1.25,
      _FONT_LEN_STOP4: 1.25,
      _FONT_LEN_STOP5: 1.2,
      null: 1.2,
    },
    'Edo': {
      _FONT_LEN_STOP1: 1.5,
      _FONT_LEN_STOP2: 1.5,
      _FONT_LEN_STOP3: 1.25,
      _FONT_LEN_STOP4: 1.25,
      _FONT_LEN_STOP5: 1.2,
      null: 1.2,
    },
    'Lobster': {
      _FONT_LEN_STOP1: 1.5,
      _FONT_LEN_STOP2: 1.5,
      _FONT_LEN_STOP3: 1.25,
      _FONT_LEN_STOP4: 1.25,
      _FONT_LEN_STOP5: 1.2,
      null: 1.2,
    },
    'Song': {
      _FONT_LEN_STOP1: 1.5,
      _FONT_LEN_STOP2: 1.5,
      _FONT_LEN_STOP3: 1.25,
      _FONT_LEN_STOP4: 1.25,
      _FONT_LEN_STOP5: 1.2,
      null: 1.2,
    },
    'Heiti': {
      _FONT_LEN_STOP1: 1.5,
      _FONT_LEN_STOP2: 1.5,
      _FONT_LEN_STOP3: 1.25,
      _FONT_LEN_STOP4: 1.25,
      _FONT_LEN_STOP5: 1.2,
      null: 1.2,
    },
    'Zhuokai': {
      _FONT_LEN_STOP1: 1.5,
      _FONT_LEN_STOP2: 1.5,
      _FONT_LEN_STOP3: 1.25,
      _FONT_LEN_STOP4: 1.25,
      _FONT_LEN_STOP5: 1.2,
      null: 1.2,
    },
    null: {
      _FONT_LEN_STOP1: 1.5,
      _FONT_LEN_STOP2: 1.5,
      _FONT_LEN_STOP3: 1.25,
      _FONT_LEN_STOP4: 1.25,
      _FONT_LEN_STOP5: 1.2,
      null: 1,
    },
  };

  static double getEmptyTextDefaultFontSize() {
    return 24;
  }

  static int getStopsCount() {
    return _FONT_SIZE_MAP.entries.first.value.entries.length;
  }

  static double calculateFontSize(String fontFamily, String text) {
    Map<int?, double>? map = _FONT_SIZE_MAP[fontFamily];
    map ??= _FONT_SIZE_MAP[null];
    List<int?> keys = map!.keys.toList();
    keys.sort(
          (a, b) {
        if (a == null && b == null) {
          return 0;
        } else if (a == null || b == null) {
          return a == null ? 1 : -1;
        }
        return a.compareTo(b);
      },
    );
    debugPrint("keys=$keys");
    int length = text.length;
    double? result;
    for (int i = 0; i < keys.length; i++) {
      int? key = keys[i];
      debugPrint("key=$key");
      if (key == null) {
        result = map[null]!;
      } else {
        if (length < key) {
          result = map[key]!;
          break;
        }
      }
    }
    debugPrint("result=$result");
    return result!;
  }

  static double calculateLineHeight(String fontFamily, String text) {
    Map<int?, double>? map = _FONT_LINE_HEIGHT_MAP[fontFamily];
    map ??= _FONT_LINE_HEIGHT_MAP[null];
    List<int?> keys = map!.keys.toList();
    keys.sort(
          (a, b) {
        if (a == null && b == null) {
          return 0;
        } else if (a == null || b == null) {
          return a == null ? 1 : -1;
        }
        return a.compareTo(b);
      },
    );
    debugPrint("keys=$keys");
    int length = text.length;
    double? result;
    for (int i = 0; i < keys.length; i++) {
      int? key = keys[i];
      debugPrint("key=$key");
      if (key == null) {
        result = map[null]!;
      } else {
        if (length < key) {
          result = map[key]!;
          break;
        }
      }
    }
    debugPrint("result=$result");
    return result!;
  }

  static const FONT_LIST = [
    'Linotte',
    'Montserrat',
    'Antonio',
    'Baloo',
    'Edo',
    'Lobster',
    'Song',
    'Heiti',
    'Zhuokai',
  ];
  static const FONT_FOR_RANDOM = [
    'Linotte',
    'Montserrat',
    'Antonio',
    'Baloo',
    'Edo',
    'Lobster',
    'Song',
    'Heiti',
    'Zhuokai',
  ];
// static const FONT_FOR_RANDOM = [
//   'Linotte',
//   'Montserrat',
//   'Antonio',
//   'Baloo',
//   'Edo',
//   'Lobster',
// ];
}
