import 'package:app/utils/design_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    return CachedNetworkImage(
      width: width,
      fit: BoxFit.cover,
      height: height,
      cacheKey: network.getS3ImageKey(imageUrl),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cornerRadius),
          image: DecorationImage(
            image: imageProvider,
            // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn)
          ),
        ),
      ),
      imageUrl: imageUrl,
      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
          child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: downloadProgress.progress,
                strokeWidth: 2,
                color: designColors.feiyu_blue.auto(ref),
              ))),
      errorWidget: errorWidget ??
          (context, url, error) => Container(
                color: Colors.white.withOpacity(0.5),
                child: Center(
                  child: Column(
                    children: [Icon(Icons.error), Text("error")],
                  ),
                ),
              ),
      placeholder: placeholderWidget,
    );
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
    return SvgPicture.asset(
      assetName,
      width: width,
      height: height,
      color: color,
    );
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
