import 'package:app/utils/design_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';

String formatAmount(int number) {
  if (number > 1000000) {
    return sprintf("%.1f", number / 1000000);
  } else {
    final formatter = NumberFormat("#,##0.00", "en_US");
    return formatter.format(number);
  }
}

class HoohImage extends ConsumerWidget {
  const HoohImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.cornerRadius = 0,
    this.placeholderWidget,
    this.errorWidget,
  }) : super(key: key);

  final String imageUrl;
  final double? width;
  final double? height;
  final double cornerRadius;
  final Widget Function(BuildContext, String)? placeholderWidget;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var networkImage = CachedNetworkImage(
      width: width,
      fit: BoxFit.cover,
      height: height,
      cacheKey: network.getS3ImageKey(imageUrl),
      imageUrl: imageUrl,
      errorWidget: errorWidget ??
          (context, url, error) {
            var color = designColors.light_06.auto(ref);
            return Container(
              color: Colors.white.withOpacity(0.5),
              child: SizedBox(
                width: width,
                height: height,
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.error,
                        color: color,
                      ),
                      Text(
                        "error",
                        style: TextStyle(color: color),
                      )
                    ],
                  ),
                ),
              ),
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
    if (cornerRadius != 0) {
      return ClipRRect(
        child: networkImage,
        borderRadius: BorderRadius.circular(cornerRadius),
      );
    } else {
      return networkImage;
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
