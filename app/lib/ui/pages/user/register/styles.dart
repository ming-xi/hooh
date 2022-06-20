import 'package:app/global.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MainStyles {
  static Widget getRefresherHeader(WidgetRef ref, {double? offset}) {
    return MaterialClassicHeader(
      offset: offset ?? 0,
      color: designColors.feiyu_blue.auto(ref),
      backgroundColor: designColors.light_01.auto(ref),
    );
  }

  static LinearGradient badgeGradient(WidgetRef ref) {
    List<Color> colors;
    if (isDarkMode(ref)) {
      colors = [
        const Color(0xFFBCA036),
        const Color(0xFFB381BC),
        const Color(0xFF3BA7BC),
      ];
    } else {
      colors = [
        const Color(0xFFFFD840),
        const Color(0xFFF3ACFF),
        const Color(0xFF48E1FF),
      ];
    }
    return LinearGradient(colors: colors, begin: Alignment.bottomLeft, end: Alignment.topRight);
  }

  static LinearGradient buttonGradient(WidgetRef ref, {bool enabled = true}) {
    List<Color> colors;
    if (isDarkMode(ref)) {
      colors = [
        const Color(0xFF0A51B7),
        const Color(0xFF1FA691),
      ];
    } else {
      colors = [
        const Color(0xFF0167F9),
        const Color(0xFF20E0C2),
      ];
    }
    if (!enabled) {
      colors = colors.map((e) => e.withOpacity(0.5)).toList();
    }
    return LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight);
  }

  static bool isDarkMode(WidgetRef ref) {
    int darkMode = ref.watch(globalDarkModeProvider.state).state;
    switch (darkMode) {
      case DARK_MODE_LIGHT:
        return false;
      case DARK_MODE_DARK:
        return true;
      case DARK_MODE_SYSTEM:
      default:
        Brightness brightness = SchedulerBinding.instance.window.platformBrightness;
        return brightness != Brightness.light;
    }
  }

  static ButtonStyle textButtonStyle(WidgetRef ref) {
    return TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(100.0)),
      ),
      minimumSize: const Size(72, 32),
    );
  }

  static Widget buildListDivider(WidgetRef ref) {
    return Container(
      height: 1,
      color: designColors.light_02.auto(ref),
    );
  }

  static Widget buildListTile(WidgetRef ref, String title, {bool showArrow = false, Widget? tailWidget, String? tailText, Function()? onPress}) {
    List<Widget> children = [
      Text(
        title,
        style: TextStyle(fontSize: 14, color: designColors.light_06.auto(ref)),
      ),
      const Spacer(),
    ];
    if (tailText != null) {
      children.add(Text(
        tailText,
        style: TextStyle(fontSize: 14, color: designColors.light_06.auto(ref), fontWeight: FontWeight.bold),
      ));
      children.add(const SizedBox(
        width: 8,
      ));
    }
    if (tailWidget != null) {
      children.add(tailWidget);
    }
    if (showArrow) {
      children.add(Icon(
        Icons.arrow_forward_ios_rounded,
        size: 18,
        color: designColors.light_06.auto(ref),
      ));
    }
    return Material(
      child: Ink(
        height: 48,
        // color: designColors.light_02.auto(ref),
        child: InkWell(
          onTap: onPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  static BoxDecoration gradientButtonDecoration(WidgetRef ref, {double cornerRadius = 24, bool enabled = true}) {
    return BoxDecoration(
      gradient: buttonGradient(ref, enabled: enabled),
      borderRadius: BorderRadius.circular(cornerRadius),
    );
  }

  static Widget gradientButton(WidgetRef ref, String text, Function()? onPressed, {double cornerRadius = 24}) {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: onPressed != null
            ? gradientButtonDecoration(ref, cornerRadius: cornerRadius, enabled: true)
            : BoxDecoration(
                color: designColors.dark_03.auto(ref),
                borderRadius: BorderRadius.circular(cornerRadius),
              ),
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
          onTap: onPressed,
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            child: Center(
                child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            )),
          ),
        ),
      ),
    );
  }

  static Widget blueButton(WidgetRef ref, String text, Function()? onPressed, {double? cornerRadius}) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontFamily: 'Linotte'),
      ),
      style: RegisterStyles.blueButtonStyle(ref, cornerRadius: cornerRadius)
          .copyWith(textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    );
  }

  static Widget outlinedTextButton(WidgetRef ref, String text, Function() onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
      style: outlineTextButtonStyle(ref),
    );
  }

  static Widget outlinedIconButton(WidgetRef ref, String iconAssetName, double iconSize, bool checked, Function() onPressed) {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        width: iconSize,
        height: iconSize,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: checked ? designColors.feiyu_blue.auto(ref) : designColors.dark_03.auto(ref),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(const Radius.circular(12)),
          onTap: onPressed,
          child: HoohIcon(
            iconAssetName,
            width: iconSize,
            height: iconSize,
            color: designColors.dark_01.auto(ref),
          ),
        ),
      ),
    );
  }

  static ButtonStyle outlineIconButtonStyle(WidgetRef ref) {
    return ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return designColors.light_01.auto(ref).withOpacity(0.5);
          } else {
            return designColors.light_01.auto(ref);
          }
        }),
        overlayColor: MaterialStateProperty.all(designColors.dark_03.auto(ref).withOpacity(0.2)),
        shape: MaterialStateProperty.resolveWith<OutlinedBorder>((states) {
          if (states.contains(MaterialState.disabled)) {
            return RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12.0)), side: BorderSide(color: designColors.dark_03.auto(ref).withOpacity(0.5)));
          } else {
            return RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(12.0)), side: BorderSide(color: designColors.dark_03.auto(ref)));
          }
        }),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        minimumSize: MaterialStateProperty.all(const Size.square(36)),
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 20)));
  }

  static ButtonStyle outlineTextButtonStyle(WidgetRef ref) {
    return ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return designColors.light_01.auto(ref).withOpacity(0.5);
          } else {
            return designColors.light_01.auto(ref);
          }
        }),
        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return designColors.light_06.auto(ref).withOpacity(0.5);
          } else {
            return designColors.light_06.auto(ref);
          }
        }),
        overlayColor: MaterialStateProperty.all(designColors.dark_03.auto(ref).withOpacity(0.2)),
        shape: MaterialStateProperty.resolveWith<OutlinedBorder>((states) {
          if (states.contains(MaterialState.disabled)) {
            return RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(22.0)), side: BorderSide(color: designColors.light_06.auto(ref).withOpacity(0.5)));
          } else {
            return RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(22.0)), side: BorderSide(color: designColors.light_06.auto(ref)));
          }
        }),
        minimumSize: MaterialStateProperty.all(const Size.fromHeight(64)),
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 20)));
  }
}

class RegisterStyles {
  static TextStyle titleTextStyle(WidgetRef ref) {
    return TextStyle(fontSize: 16, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold);
  }

  static TextStyle inputTextStyle(WidgetRef ref) {
    return TextStyle(fontSize: 16, color: designColors.dark_01.auto(ref));
  }

  static TextStyle hintTextStyle(WidgetRef ref) {
    return TextStyle(fontSize: 16, color: designColors.dark_03.auto(ref));
  }

  static TextStyle descriptionTextStyle(WidgetRef ref) {
    return TextStyle(fontSize: 16, color: designColors.feiyu_blue.auto(ref));
  }

  static TextStyle errorTextStyle(WidgetRef ref) {
    return TextStyle(fontSize: 16, color: designColors.orange.auto(ref));
  }

  static InputDecoration commonInputDecoration(String hint, WidgetRef ref, {String? helperText, String? errorText}) {
    return InputDecoration(
        hintText: hint,
        hintStyle: hintTextStyle(ref),
        errorText: errorText,
        helperText: helperText,
        helperStyle: descriptionTextStyle(ref),
        errorStyle: errorTextStyle(ref),
        helperMaxLines: 5,
        errorMaxLines: 5,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(22.0))));
  }

  static InputDecoration passwordInputDecoration(String hint, WidgetRef ref,
      {String? helperText, String? errorText, bool passwordVisible = false, Function()? onTogglePasswordVisible}) {
    return commonInputDecoration(hint, ref, helperText: helperText, errorText: errorText).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            // Based on passwordVisible state choose the icon
            passwordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: onTogglePasswordVisible,
        ));
  }

  static ButtonStyle blueButtonStyle(WidgetRef ref, {double? cornerRadius}) {
    return TextButton.styleFrom(
      // primary: designColors.light_01.auto(ref),
      // onSurface: designColors.light_01.auto(ref),
        shape: cornerRadius == null
            ? null
            : RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
        ),
        primary: Colors.white,
        onSurface: Colors.white,
        minimumSize: const Size.fromHeight(64),
        backgroundColor: designColors.feiyu_blue.auto(ref),
        textStyle: const TextStyle(fontSize: 16));
  }

  static ButtonStyle appbarTextButtonStyle(WidgetRef ref) {
    return TextButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.zero),
        ),
        primary: designColors.feiyu_blue.auto(ref),
        onSurface: designColors.feiyu_blue.auto(ref),
        backgroundColor: Colors.transparent,
        textStyle: const TextStyle(fontSize: 16, fontFamily: 'Linotte', fontWeight: FontWeight.bold));
  }

  static ButtonStyle blackButtonStyle(WidgetRef ref) {
    var color = MaterialStateProperty.all(designColors.light_01.auto(ref));
    // debugPrint("blackButtonStyle result=$color");
    return ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return designColors.dark_03.auto(ref);
          } else {
            return designColors.dark_01.auto(ref);
          }
        }),
        foregroundColor: color,
        overlayColor: MaterialStateProperty.all(designColors.light_01.auto(ref).withOpacity(0.2)),
        shape: MaterialStateProperty.all(const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(22.0)),
        )),
        minimumSize: MaterialStateProperty.all(const Size.fromHeight(64)),
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));

    // return TextButton.styleFrom(
    //     primary: designColors.light_01.auto(ref),
    //     onSurface: designColors.light_01.auto(ref),
    //     minimumSize: const Size.fromHeight(64),
    //     backgroundColor: designColors.dark_01.auto(ref),
    //     shape: const RoundedRectangleBorder(
    //       borderRadius: BorderRadius.all(Radius.circular(22.0)),
    //     ),
    //     textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  static ButtonStyle blackOutlineButtonStyle(WidgetRef ref) {
    // var color = MaterialStateProperty.all(designColors.light_01.auto(ref));
    // debugPrint("blackOutlineButtonStyle result=$color");
    // return TextButton.styleFrom(
    //     primary: designColors.dark_01.auto(ref),
    //     onSurface: designColors.dark_01.auto(ref),
    //     backgroundColor: designColors.light_01.auto(ref),
    //     shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(22.0)), side: BorderSide(color: designColors.dark_01.auto(ref))),
    //     minimumSize: const Size.fromHeight(64),
    //     side: BorderSide(width: 1, color: designColors.dark_01.auto(ref)),
    //     textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
    return ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return designColors.light_01.auto(ref).withOpacity(0.5);
          } else {
            return designColors.light_01.auto(ref);
          }
        }),
        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return designColors.dark_03.auto(ref);
          } else {
            return designColors.dark_01.auto(ref);
          }
        }),
        overlayColor: MaterialStateProperty.all(designColors.light_06.auto(ref).withOpacity(0.2)),
        shape: MaterialStateProperty.resolveWith<OutlinedBorder>((states) {
          if (states.contains(MaterialState.disabled)) {
            return RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(22.0)), side: BorderSide(color: designColors.dark_03.auto(ref)));
          } else {
            return RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(22.0)), side: BorderSide(color: designColors.dark_01.auto(ref)));
          }
        }),
        minimumSize: MaterialStateProperty.all(const Size.fromHeight(64)),
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
  }

  static ButtonStyle rainbowOutlineButtonStyle(WidgetRef ref) {
    return TextButton.styleFrom(
        primary: designColors.feiyu_blue.auto(ref),
        onSurface: designColors.feiyu_blue.auto(ref),
        backgroundColor: designColors.light_01.auto(ref),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(22.0)), side: BorderSide(color: Colors.transparent)),
        minimumSize: const Size.fromHeight(64),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  static Widget rainbowButton(WidgetRef ref, {Widget? label, Widget? icon, Function()? onPress}) {
    const double radius = 24;
    final gradient = BoxDecoration(
      gradient: MainStyles.badgeGradient(ref),
      borderRadius: BorderRadius.circular(radius),
    );
    var buttonStyle = TextButton.styleFrom(
        primary: designColors.feiyu_blue.auto(ref),
        onSurface: designColors.feiyu_blue.auto(ref),
        backgroundColor: designColors.light_01.auto(ref),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radius - 1)), side: BorderSide(color: Colors.transparent)),
        minimumSize: const Size.fromHeight(64),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
    Widget button;

    if (icon != null) {
      if (label != null) {
        button = TextButton.icon(
          style: buttonStyle,
          onPressed: onPress,
          icon: icon,
          label: label,
        );
      } else {
        // button = IconButton(onPressed: onPress, icon: icon,color: designColors.feiyu_blue.auto(ref),);
        button = TextButton(
          style: buttonStyle.copyWith(minimumSize: MaterialStateProperty.all(const Size.square(64))),
          onPressed: onPress,
          child: icon,
        );
      }
    } else {
      if (label != null) {
        button = TextButton(
          style: buttonStyle,
          onPressed: onPress,
          child: label,
        );
      } else {
        throw UnsupportedError("icon and label cannot both be null");
      }
    }
    return Container(
      decoration: gradient,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: button,
      ),
    );
  }
}
