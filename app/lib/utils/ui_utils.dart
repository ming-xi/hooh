import 'dart:io';
import 'dart:ui' as ui;

import 'package:app/global.dart';
import 'package:app/launcher.dart';
import 'package:app/ui/pages/creation/template_adjust.dart';
import 'package:app/ui/pages/misc/image_cropper.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/pages/user/user_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';

void showSelectLocalImageActionSheet(
    {required BuildContext context, required WidgetRef ref, double? cropRatio, bool adjustTemplateImage = false, required Function(File? file) onSelected}) {
  debugPrint("sheet context=$context");
  if (Platform.isIOS || Platform.isMacOS) {
    /// To display an actionSheet
    showCupertinoModalPopup(
        context: context,
        builder: (popContext) => CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                  child: Text(globalLocalizations.templates_choose_from_camera),
                  onPressed: () {
                    // debugPrint("camera");
                    // Navigator.pop(context);
                    Navigator.of(popContext).pop();
                    _openImagePicker(
                        context: context, ref: ref, adjustTemplateImage: adjustTemplateImage, cropRatio: cropRatio, useCamera: true, onSelected: onSelected);
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text(globalLocalizations.templates_choose_from_gallery),
                  onPressed: () {
                    // debugPrint("gallery");
                    // Navigator.pop(context);
                    Navigator.of(popContext).pop();
                    _openImagePicker(
                        context: context, ref: ref, adjustTemplateImage: adjustTemplateImage, cropRatio: cropRatio, useCamera: false, onSelected: onSelected);
                  },
                )
              ],
              cancelButton: CupertinoActionSheetAction(
                child: Text(globalLocalizations.common_cancel),
                onPressed: () {
                  // debugPrint("cancel");
                  Navigator.of(popContext).pop();
                },
              ),
            ));
  } else {
    showModalBottomSheet(
        context: context,
        builder: (popContext) => Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.camera),
                  title: Text(globalLocalizations.templates_choose_from_camera),
                  onTap: () {
                    // Navigator.pop(context);
                    Navigator.of(popContext).pop();
                    _openImagePicker(
                        context: context, ref: ref, adjustTemplateImage: adjustTemplateImage, cropRatio: cropRatio, useCamera: true, onSelected: onSelected);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text(globalLocalizations.templates_choose_from_gallery),
                  onTap: () {
                    // Navigator.pop(context);
                    Navigator.of(popContext).pop();
                    _openImagePicker(
                        context: context, ref: ref, adjustTemplateImage: adjustTemplateImage, cropRatio: cropRatio, useCamera: false, onSelected: onSelected);
                  },
                ),
              ],
            ));
  }
}

/// Open image picker
void _openImagePicker(
    {required BuildContext context,
    required WidgetRef ref,
    required bool useCamera,
    double? cropRatio,
    bool adjustTemplateImage = true,
    required Function(File? file) onSelected}) {
  ImageSource source;
  if (useCamera) {
    source = ImageSource.camera;
  } else {
    source = ImageSource.gallery;
  }
  debugPrint("context=$context");
  ImagePicker().pickImage(source: source).then((pickedFile) {
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ImageCropperScreen(
                    imageFile: file,
                    ratio: cropRatio,
                  ))).then((file) {
        if (file == null) {
          onSelected(null);
        } else {
          if (adjustTemplateImage) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AdjustTemplatePositionScreen(
                file,
                onFileAdjusted: onSelected,
              );
            }));
          } else {
            onSelected(file);
          }
        }
      });
    }
  });
}

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

void showCommonRequestErrorDialog(WidgetRef ref, BuildContext context, dynamic response) {
  showDialog(
      context: context,
      builder: (context) {
        String title = globalLocalizations.error_network_error;
        String content;
        if (response is HoohApiErrorResponse) {
          content = response.message;
          if (FlavorConfig.instance.variables[Launcher.KEY_ADMIN_MODE]) {
            content = content + "\n\n[Admin Mode] dev message:\n\n" + response.devMessage;
          }
        } else {
          if (response is String) {
            content = response;
          } else {
            if (response == null) {
              content = "error";
            } else {
              content = response.toString();
            }
          }
        }
        return AlertDialog(
          title: Text(title),
          content: Text(content),
        );
      });
}

void hideKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

String formatCurrency(int? currency, {bool? precise = false}) {
  final formatter = NumberFormat("#,##0.00", "en_US");
  if (precise ?? false) {
    if (currency == null) {
      return "0";
    }
    double value = currency / 100.0;
    return formatter.format(value);
  } else {
    if (currency == null) {
      return "";
    }
    double value = currency / 100.0;
    if (value > 1000000) {
      return sprintf("%.1f", value / 1000000);
    } else {
      return formatter.format(value);
    }
  }
}

String formatAmount(int? number) {
  if (number == null) {
    return "";
  }
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

class HoohLocalizedRichText extends ConsumerStatefulWidget {
  final String text;
  final TextStyle defaultTextStyle;
  final List<HoohLocalizedKey> keys;

  final TextAlign textAlign;
  final ui.TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int? maxLines;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  HoohLocalizedRichText({
    Key? key,
    required this.text,
    required this.defaultTextStyle,
    required this.keys,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
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
    if (widget.keys.isEmpty) {
      return Text(
        widget.text,
        style: widget.defaultTextStyle,
      );
    }
    List<InlineSpan> textSpans = [];

    //Text to localize
    String localizedText = widget.text;

    for (final localizedKey in widget.keys) {
      //Key dynamic value
      final _key = localizedKey.key;

      //Check if is present a String before the first localizedKey
      final textBeforeTheKey = localizedText.split(_key).first;

      //Add the textBeforeTheKey if present
      if (textBeforeTheKey.isNotEmpty) {
        _addPlainTextSpan(
          textSpans,
          textBeforeTheKey,
          widget.defaultTextStyle,
        );
      }

      //Add the custom TextSpan
      if (localizedKey is HoohLocalizedTextKey) {
        _addTextSpan(textSpans, localizedKey);
      } else if (localizedKey is HoohLocalizedWidgetKey) {
        _addWidgetSpan(textSpans, localizedKey);
      }

      final textAfterTheKey = localizedText.split(_key).last;

      //If is the last Key, we control if there is a String after her
      if (localizedKey == widget.keys.last) {
        //Add the textAfterTheKey if present
        if (textAfterTheKey.isNotEmpty) {
          _addPlainTextSpan(
            textSpans,
            textAfterTheKey,
            widget.defaultTextStyle,
          );
        }
      } else {
        localizedText = textAfterTheKey;
      }
    }
    return RichText(
      key: widget.key,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      textScaleFactor: widget.textScaleFactor,
      maxLines: widget.maxLines,
      locale: widget.locale,
      strutStyle: widget.strutStyle,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      text: TextSpan(
        children: textSpans,
      ),
    );
  }

  void _addPlainTextSpan(List<InlineSpan> list, String text, TextStyle? style) {
    final textSpan = TextSpan(
      text: text,
      style: style,
    );
    return list.add(textSpan);
  }

  void _addTextSpan(List<InlineSpan> list, HoohLocalizedTextKey localizedTextKey) {
    TapGestureRecognizer? recognizer;
    if (localizedTextKey.onTap != null) {
      recognizer = TapGestureRecognizer();
      recognizer.onTap = () {
        localizedTextKey.onTap!();
      };
      _recognizers.add(recognizer);
    }
    final textSpan = TextSpan(text: localizedTextKey.text, style: localizedTextKey.style, recognizer: recognizer);
    return list.add(textSpan);
  }

  void _addWidgetSpan(List<InlineSpan> list, HoohLocalizedWidgetKey localizedWidgetKey) {
    Widget result = localizedWidgetKey.widget;
    if (localizedWidgetKey.onTap != null) {
      result = GestureDetector(
        child: result,
        onTap: () {
          localizedWidgetKey.onTap!();
        },
      );
    }
    final textSpan = WidgetSpan(
      child: result,
    );
    return list.add(textSpan);
  }
}

abstract class HoohLocalizedKey {
  final String key;
  final void Function()? onTap;

  HoohLocalizedKey({required this.key, this.onTap});
}

class HoohLocalizedTextKey extends HoohLocalizedKey {
  final String text;
  final TextStyle? style;

  HoohLocalizedTextKey({
    required super.key,
    super.onTap,
    required this.text,
    this.style,
  });
}

class HoohLocalizedWidgetKey extends HoohLocalizedKey {
  final Widget widget;

  HoohLocalizedWidgetKey({
    required super.key,
    super.onTap,
    required this.widget,
  });
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
