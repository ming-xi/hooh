import 'package:flutter/material.dart';

class RegisterStyles {
  static TextStyle titleTextStyle() => const TextStyle(fontSize: 18, color: Color(0xFF707070));
  static TextStyle inputTextStyle() => const TextStyle(fontSize: 14, color: Color(0xFF212121));
  static TextStyle hintTextStyle() => const TextStyle(fontSize: 14, color: Color(0xFFC4C4C4));

  static TextStyle descriptionTextStyle() => const TextStyle(fontSize: 12, color: Color(0xFFC4C4C4));

  static TextStyle largerDescriptionTextStyle() => descriptionTextStyle().copyWith(fontSize: 14);

  static InputDecoration commonInputDecoration(String hint, {String? errorText}) => InputDecoration(
      hintText: hint,
      hintStyle: hintTextStyle(),
      errorText: errorText,
      errorStyle: descriptionTextStyle().copyWith(color: Color(0xFFF26218)),
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(22.0))));

  static ButtonStyle flatBlackButtonStyle() => TextButton.styleFrom(
      primary: Colors.white,
      minimumSize: Size.fromHeight(64),
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22.0)),
      ),
      textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));

  static ButtonStyle flatWhiteButtonStyle() => OutlinedButton.styleFrom(
      primary: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22.0)),
      ),
      minimumSize: Size.fromHeight(64),
      side: BorderSide(width: 1, color: Colors.black),
      textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black));
}
