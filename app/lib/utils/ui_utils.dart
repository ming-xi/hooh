import 'package:app/global.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';

void showKeyboard(FocusNode node) {
  if (globalIsKeyboardVisible) {
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

class AvatarView extends ConsumerWidget {
  final User user;
  final double size;

  const AvatarView({
    required this.user,
    required this.size,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HoohImage(
      imageUrl: user.avatarUrl!,
      width: size,
      height: size,
      cornerRadius: size / 2,
      onPress: () {
        Toast.showSnackBar(context, "show user ${user.id}");
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
    int darkMode = ref.watch(globalDarkModeProvider.state).state;

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
            return HoohIcon(
              "assets/images/image_placeholder.png",
              width: width,
              height: height,
            );
          },
      placeholder: (context, url) {
        return HoohIcon(
          "assets/images/image_placeholder.png",
          width: width,
          height: height,
        );
        // return Container(color: Colors.red,);
      },
    );
    if (getThemeMode(darkMode) == ThemeMode.dark) {
      result = Opacity(
        opacity: 0.7,
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

  ThemeMode getThemeMode(int darkModeValue) {
    switch (darkModeValue) {
      case DARK_MODE_LIGHT:
        return ThemeMode.light;
      case DARK_MODE_DARK:
        return ThemeMode.dark;
      case DARK_MODE_SYSTEM:
      default:
        return ThemeMode.system;
    }
  }
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
      return Image.asset(
        assetName,
        width: width,
        height: height,
        color: color,
      );
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
