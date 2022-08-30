import 'package:app/global.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/utils/ui_utils.dart';
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

  static TextButton smallTextButton(
      {required WidgetRef ref, required BuildContext context, required String text, TextStyle? textStyle, bool enabled = true, required Function() onClick}) {
    return TextButton(
      style: TextButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.padded,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size(48, 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
      onPressed: !enabled ? null : onClick,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: textStyle ??
            TextStyle(
                color: enabled ? designColors.blue_dark.auto(ref) : designColors.light_06.auto(ref),
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.underline,
                fontSize: 12),
      ),
    );
  }

  static LinearGradient badgeGradient(WidgetRef ref) {
    List<Color> colors;
    if (isDarkMode(ref)) {
      colors = [
        const Color(0xFF3BA7BC),
        const Color(0xFFB381BC),
        const Color(0xFFBCA036),
      ];
    } else {
      colors = [
        const Color(0xFF48E1FF),
        const Color(0xFFF3ACFF),
        const Color(0xFFFFD840),
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
    int darkMode = ref.watch(globalDarkModeProvider);
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
      children.add(HoohIcon(
        "assets/images/icon_arrow_next_ios.svg",
        width: 24,
        height: 24,
        color: designColors.light_06.auto(ref),
      ));
    }
    return Material(
      color: designColors.light_00.auto(ref),
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

  static Widget gradientButton(WidgetRef ref, String text, Function()? onPressed, {double cornerRadius = 18}) {
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
            constraints: const BoxConstraints(minHeight: 48),
            child: Center(
                child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            )),
          ),
        ),
      ),
    );
  }

  static Widget blueButton(WidgetRef ref, String text, Function()? onPressed, {double cornerRadius = 18}) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontFamily: 'Linotte'),
      ),
      style: RegisterStyles.blueButtonStyle(ref, cornerRadius: cornerRadius)
          .copyWith(textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
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
                borderRadius: const BorderRadius.all(Radius.circular(18.0)), side: BorderSide(color: designColors.light_06.auto(ref).withOpacity(0.5)));
          } else {
            return RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(18.0)), side: BorderSide(color: designColors.light_06.auto(ref)));
          }
        }),
        minimumSize: MaterialStateProperty.all(const Size.fromHeight(48)),
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 18, fontFamily: 'Linotte')));
  }

  static Widget buildEmptyView({
    required WidgetRef ref,
    required String text,
    String? buttonText,
    Function()? buttonOnClick,
  }) {
    List<Widget> children = [
      HoohIcon(
        "assets/images/figure_not_login_face.svg",
        width: 64,
        color: designColors.dark_03.auto(ref),
      ),
      SizedBox(
        height: 12,
      ),
      Text(
        text,
        style: TextStyle(
          fontSize: 20,
          color: designColors.dark_03.auto(ref),
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    ];
    if (buttonText != null && buttonOnClick != null) {
      children.addAll([
        SizedBox(
          height: 32,
        ),
        MainStyles.gradientButton(ref, buttonText, buttonOnClick)
      ]);
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class RegisterStyles {
  static TextStyle titleTextStyle(WidgetRef ref) {
    return TextStyle(fontSize: 18, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold);
  }

  static TextStyle inputTextStyle(WidgetRef ref) {
    return TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref));
  }

  static TextStyle hintTextStyle(WidgetRef ref) {
    return TextStyle(fontSize: 14, color: designColors.dark_03.auto(ref));
  }

  static TextStyle descriptionTextStyle(WidgetRef ref) {
    return TextStyle(fontSize: 12, color: designColors.feiyu_blue.auto(ref));
  }

  static TextStyle errorTextStyle(WidgetRef ref) {
    return TextStyle(fontSize: 12, color: designColors.orange.auto(ref));
  }

  static InputDecoration commonInputDecoration(String hint, WidgetRef ref, {String? helperText, String? errorText}) {
    BorderRadius radius = BorderRadius.all(Radius.circular(18.0));
    BorderSide borderSide = BorderSide(width: 1, color: designColors.light_02.auto(ref));
    Color errorColor = designColors.orange.auto(ref);
    Color disabledColor = designColors.light_00.auto(ref);
    Color focusedColor = designColors.feiyu_blue.auto(ref);
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 22),
      hintText: hint,
      hintStyle: hintTextStyle(ref),
      errorText: errorText,
      helperText: helperText,
      helperStyle: descriptionTextStyle(ref),
      errorStyle: errorTextStyle(ref),
      helperMaxLines: 5,
      errorMaxLines: 5,
      focusedErrorBorder: OutlineInputBorder(borderSide: borderSide.copyWith(color: focusedColor), borderRadius: radius),
      errorBorder: OutlineInputBorder(borderSide: borderSide.copyWith(color: errorColor), borderRadius: radius),
      disabledBorder: OutlineInputBorder(borderSide: borderSide.copyWith(color: disabledColor), borderRadius: radius),
      focusedBorder: OutlineInputBorder(borderSide: borderSide.copyWith(color: focusedColor), borderRadius: radius),
      enabledBorder: OutlineInputBorder(borderSide: borderSide, borderRadius: radius),
    );
  }

  static InputDecoration passwordInputDecoration(String hint, WidgetRef ref,
      {String? helperText, String? errorText, bool passwordVisible = false, Function()? onTogglePasswordVisible}) {
    return commonInputDecoration(hint, ref, helperText: helperText, errorText: errorText).copyWith(
        suffixIcon: IconButton(
      icon: HoohIcon(
        passwordVisible ? "assets/images/icon_password_visible.svg" : "assets/images/icon_password_invisible.svg",
        width: 36,
        height: 36,
        color: designColors.dark_03.auto(ref),
      ),
      // Icon(
      //   // Based on passwordVisible state choose the icon
      //   passwordVisible ? Icons.visibility : Icons.visibility_off,
      // ),
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
        minimumSize: const Size.fromHeight(48),
        backgroundColor: designColors.feiyu_blue.auto(ref),
        textStyle: const TextStyle(
          fontSize: 16,
          fontFamily: 'Linotte',
          fontWeight: FontWeight.bold,
        ));
  }

  static ButtonStyle appbarTextButtonStyle(WidgetRef ref) {
    return TextButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.zero),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16),
        primary: designColors.feiyu_blue.auto(ref),
        onSurface: designColors.feiyu_blue.auto(ref),
        backgroundColor: Colors.transparent,
        textStyle: const TextStyle(fontSize: 16, fontFamily: 'Linotte', fontWeight: FontWeight.bold));
  }

  static void showRegisterStyleDialog({
    required WidgetRef ref,
    required BuildContext context,
    required String title,
    required String content,
    required String okText,
    required Function() onOk,
    bool barrierDismissible = true,
    String? cancelText,
    Function()? onCancel,
  }) {
    showHoohDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          List<TextButton> buttons = [];
          if (cancelText != null) {
            buttons.add(TextButton(
              style: RegisterStyles.blackOutlineButtonStyle(ref),
              onPressed: () {
                Navigator.of(context).pop();
                if (onCancel != null) {
                  onCancel();
                }
              },
              child: Text(cancelText),
            ));
          }
          buttons.add(TextButton(
            style: RegisterStyles.blackButtonStyle(ref),
            onPressed: () {
              Navigator.of(context).pop();
              onOk();
            },
            child: Text(okText),
          ));
          return AlertDialog(
            insetPadding: EdgeInsets.all(20),
            title: Text(title),
            content: SizedBox(
              height: 220,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: Text(content)),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: buttons
                        .map((e) => [
                              Expanded(child: e),
                              SizedBox(
                                width: 12,
                              )
                            ])
                        .expand((element) => element)
                        .toList()
                      ..removeLast(),
                  )
                ],
              ),
            ),
          );
        });
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
          borderRadius: BorderRadius.all(Radius.circular(18.0)),
        )),
        minimumSize: MaterialStateProperty.all(const Size.fromHeight(48)),
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Linotte')));

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
            return RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(18.0)), side: BorderSide(color: designColors.dark_03.auto(ref)));
          } else {
            return RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(18.0)), side: BorderSide(color: designColors.dark_01.auto(ref)));
          }
        }),
        minimumSize: MaterialStateProperty.all(const Size.fromHeight(48)),
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Linotte')));
  }

  static ButtonStyle rainbowOutlineButtonStyle(WidgetRef ref) {
    return TextButton.styleFrom(
        primary: designColors.feiyu_blue.auto(ref),
        onSurface: designColors.feiyu_blue.auto(ref),
        backgroundColor: designColors.light_01.auto(ref),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18.0)), side: BorderSide(color: Colors.transparent)),
        minimumSize: const Size.fromHeight(48),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  static Widget rainbowButton(WidgetRef ref, {Widget? label, Widget? icon, Function()? onPress}) {
    const double radius = 18;
    final gradient = BoxDecoration(
      gradient: MainStyles.badgeGradient(ref),
      borderRadius: BorderRadius.circular(radius),
    );
    var buttonStyle = TextButton.styleFrom(
        primary: designColors.feiyu_blue.auto(ref),
        onSurface: designColors.feiyu_blue.auto(ref),
        backgroundColor: designColors.light_01.auto(ref),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radius - 1)), side: BorderSide(color: Colors.transparent)),
        minimumSize: const Size.fromHeight(48),
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
