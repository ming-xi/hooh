import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateUtil {
  static const String FORMAT_DEFAULT = "yyyy-MM-dd HH:mm:ss";
  static const String FORMAT_ONLY_DATE = "yyyy-MM-dd";
  static const String FORMAT_ONLY_TIME = "HH:mm:ss";
  static const String FORMAT_ONLY_TIME_WITHOUT_SECOND = "HH:mm";

  static DateTime getCurrentUtcDate() {
    return DateTime.now().toUtc();
  }

  static DateTime getUtcDate(String dateString) {
    return DateTime.parse(dateString);
  }

  static String getUtcDateString(DateTime dateTime, {String? format}) {
    return DateFormat(format ?? FORMAT_DEFAULT).format(dateTime);
  }

  static String getZonedDateString(DateTime dateTime, {String? format}) {
    return DateFormat(format ?? FORMAT_DEFAULT).format(dateTime.add(dateTime.timeZoneOffset));
  }
}
