import 'package:app/global.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/pages/user/user_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:localized_rich_text/localized_rich_text.dart';
import 'package:sprintf/sprintf.dart';

void showKeyboard(WidgetRef ref, FocusNode node) {
  if (ref.read(globalKeyboardInfoProvider)) {
    node.requestFocus();
  } else {
    if (node.hasFocus) {
      node.unfocus();
      Future.delayed(Duration(milliseconds: 100), () {
        node.requestFocus();
      });
    } else {
      node.requestFocus();
    }
  }
}

void hideKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

String formatAmount(int number) {
  if (number > 1000000) {
    return sprintf("%.1f", number / 1000000);
  } else {
    final formatter = NumberFormat("#,##0", "en_US");
    return formatter.format(number);
  }
}

String formatDate(BuildContext context, DateTime date, {String? absoluteDateFormat}) {
  DateTime now = DateTime.now();
  Duration diff = now.difference(DateUtil.getZonedDate(date));
  String templateAgo = AppLocalizations.of(context)!.datetime_ago;
  if (diff.inSeconds <= 60) {
    // within 60 seconds
    return sprintf(templateAgo, [AppLocalizations.of(context)!.second(diff.inSeconds)]);
  } else if (diff.inMinutes <= 60) {
    // within 60 min
    return sprintf(templateAgo, [AppLocalizations.of(context)!.minute(diff.inMinutes)]);
  } else if (diff.inHours <= 24) {
    // within 24 hours
    return sprintf(templateAgo, [AppLocalizations.of(context)!.hour(diff.inHours)]);
  } else if (diff.inDays <= 30) {
    // within 30 days
    return sprintf(templateAgo, [AppLocalizations.of(context)!.day(diff.inDays)]);
  } else if (diff.inDays <= 365) {
    // within 365 days
    return sprintf(templateAgo, [AppLocalizations.of(context)!.month(diff.inDays / 30)]);
  } else {
    return DateUtil.getZonedDateString(date, format: absoluteDateFormat);
  }
}

mixin KeyboardLogic<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;
    final temp = keyboardVisible;
    if (_keyboardVisible == temp) return;
    _keyboardVisible = temp;
    onKeyboardChanged(keyboardVisible);
  }

  void onKeyboardChanged(bool visible);

  bool get keyboardVisible =>
      EdgeInsets.fromWindowPadding(
        WidgetsBinding.instance.window.viewInsets,
        WidgetsBinding.instance.window.devicePixelRatio,
      ).bottom >
      100;
}

class HoohLocalizedKey {
  final String key;
  final String text;
  final TextStyle? style;
  final void Function(String)? onTap;

  HoohLocalizedKey({required this.key, required this.text, this.style, this.onTap});
}

class HoohLocalizedRichText extends ConsumerStatefulWidget {
  final String template;
  final List<HoohLocalizedKey> keys;
  final TextStyle defaultTextStyle;

  const HoohLocalizedRichText({
    required this.template,
    required this.keys,
    required this.defaultTextStyle,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _HoohLocalizedRichTextState();
}

class _HoohLocalizedRichTextState extends ConsumerState<HoohLocalizedRichText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    super.dispose();
    for (TapGestureRecognizer recognizer in _recognizers) {
      recognizer.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    LocalizedRichText richText = LocalizedRichText(
      text: widget.template,
      defaultTextStyle: widget.defaultTextStyle,
      keys: widget.keys
          .map((e) => LocalizedRichTextKey(
                key: e.key,
                value: e.text,
                textStyle: e.style ?? widget.defaultTextStyle,
              ))
          .toList(),
    );
    List<TextSpan> children = richText.richTextChildren;
    for (HoohLocalizedKey key in widget.keys) {
      if (key.onTap != null) {
        for (int i = 0; i < children.length; i++) {
          TextSpan span = children[i];
          debugPrint("span.text=${span.text} key.text=${key.text}");
          if (span.text == key.text) {
            TapGestureRecognizer recognizer = TapGestureRecognizer();
            recognizer.onTap = () {
              key.onTap!(key.text);
            };
            TextSpan replacement = TextSpan(text: span.text, style: span.style, children: span.children, recognizer: recognizer);
            _recognizers.add(recognizer);
            children[i] = replacement;
            break;
          }
        }
      }
    }
    return RichText(
      text: TextSpan(children: children),
    );
  }
}

class AvatarView extends ConsumerWidget {
  final double size;
  final bool clickable;
  late final String userId;
  late final String avatarUrl;

  AvatarView({
    required this.userId,
    required this.avatarUrl,
    required this.size,
    this.clickable = true,
    Key? key,
  }) : super(key: key);

  AvatarView.fromUser(
    User user, {
    Key? key,
    required this.size,
    this.clickable = true,
  }) : super(key: key) {
    avatarUrl = user.avatarUrl!;
    userId = user.id;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HoohImage(
      imageUrl: avatarUrl,
      width: size,
      height: size,
      cornerRadius: size / 2,
      onPress: !clickable
          ? null
          : () {
              // Toast.showSnackBar(context, "show user ${user.id}");
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(userId: userId)));
            },
    );
  }
}

class HoohImage extends ConsumerWidget {
  const HoohImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.isBadge = false,
    this.cornerRadius = 0,
    this.placeholderWidget,
    this.errorWidget,
    this.onPress,
  }) : super(key: key);

  final String imageUrl;
  final double? width;
  final double? height;
  final bool? isBadge;
  final double cornerRadius;
  final Widget Function(BuildContext, String)? placeholderWidget;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final void Function()? onPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget result = CachedNetworkImage(
      filterQuality: (isBadge ?? false) ? FilterQuality.none : FilterQuality.low,
      width: width,
      fit: BoxFit.cover,
      height: height,
      useOldImageOnUrlChange: true,
      cacheKey: network.getS3ImageKey(imageUrl),
      imageUrl: imageUrl,
      errorWidget: errorWidget ??
          (context, url, error) {
            // var color = designColors.light_06.auto(ref);
            // return Container(
            //   color: Colors.white.withOpacity(0.5),
            //   child: SizedBox(
            //     width: width,
            //     height: height,
            //     child: Center(
            //       child: Column(
            //         children: [
            //           Icon(
            //             Icons.error,
            //             color: color,
            //           ),
            //           Text(
            //             "error",
            //             style: TextStyle(color: color),
            //           )
            //         ],
            //       ),
            //     ),
            //   ),
            // );
            return buildPlaceHolder();
          },
      placeholder: (context, url) {
        return buildPlaceHolder();
        // return Container(color: Colors.red,);
      },
    );
    if (MainStyles.isDarkMode(ref)) {
      result = Opacity(
        opacity: globalDarkModeImageOpacity,
        child: result,
      );
    }
    if (cornerRadius != 0) {
      result = ClipRRect(
        child: result,
        borderRadius: BorderRadius.circular(cornerRadius),
      );
      // return ClipRRect(
      //   child: result,
      //   borderRadius: BorderRadius.circular(cornerRadius),
      // );
    }
    if (onPress != null) {
      result = Stack(
        children: [
          result,
          Material(
            type: MaterialType.transparency,
            child: Ink(
              child: InkWell(
                onTap: onPress,
                borderRadius: BorderRadius.circular(cornerRadius),
                child: SizedBox(
                  width: width,
                  height: height,
                ),
              ),
            ),
          )
        ],
      );
    }
    return result;
  }

  Widget buildPlaceHolder() {
    HoohIcon icon = HoohIcon(
      "assets/images/image_placeholder.png",
      width: width,
      height: height,
    );
    if (cornerRadius != 0) {
      return ClipRRect(
        child: icon,
        borderRadius: BorderRadius.circular(cornerRadius),
      );
    } else {
      return icon;
    }
  }

// ThemeMode getThemeMode(int darkModeValue) {
//   switch (darkModeValue) {
//     case DARK_MODE_LIGHT:
//       return ThemeMode.light;
//     case DARK_MODE_DARK:
//       return ThemeMode.dark;
//     case DARK_MODE_SYSTEM:
//     default:
//       return ThemeMode.system;
//   }
// }
}

class HoohIcon extends ConsumerWidget {
  final String assetName;
  final double? width;
  final double? height;
  final Color? color;

  const HoohIcon(this.assetName, {this.width, this.height, this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (assetName.endsWith(".svg")) {
      return SvgPicture.asset(
        assetName,
        width: width,
        height: height,
        color: color,
      );
    } else {
      Widget result = Image.asset(
        assetName,
        width: width,
        height: height,
        color: color,
      );
      if (MainStyles.isDarkMode(ref)) {
        result = Opacity(
          opacity: globalDarkModeImageOpacity,
          child: result,
        );
      }
      return result;
    }
  }
}

class LoadingDialog extends ConsumerStatefulWidget {
  final LoadingDialogController _controller;

  const LoadingDialog(
    this._controller, {
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends ConsumerState<LoadingDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
            value: widget._controller.progress(),
          ),
        ),
      ),
    );
  }
}

class LoadingDialogController {
  bool hasProgress;
  double value = 0;
  double max = 100;

  LoadingDialogController({this.hasProgress = false});

  double? progress() {
    return hasProgress ? (value / max) : null;
  }
}
