import 'dart:js' as js;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web/utils/design_colors.dart';

class UiUtil {
  static void jumpToUrl(String url) {
    debugPrint("jumpToUrl:$url");
    js.context.callMethod('open', [url]);
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
    // if (MainStyles.isDarkMode(ref)) {
    //   result = Opacity(
    //     opacity: globalDarkModeImageOpacity,
    //     child: result,
    //   );
    // }
    if (cornerRadius != 0) {
      result = ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: result,
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
        borderRadius: BorderRadius.circular(cornerRadius),
        child: icon,
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
      // if (MainStyles.isDarkMode(ref)) {
      //   result = Opacity(
      //     opacity: globalDarkModeImageOpacity,
      //     child: result,
      //   );
      // }
      return result;
    }
  }
}
