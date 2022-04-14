import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/material.dart';

class HoohImage extends StatelessWidget {
  const HoohImage({
    Key? key,
    required this.imageUrl,
    required this.size,
  }) : super(key: key);

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      width: size,
      fit: BoxFit.cover,
      height: size,
      cacheKey: network.getS3ImageKey(imageUrl),
      imageUrl: imageUrl,
      progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
      errorWidget: (context, url, error) => Container(
        color: Colors.black.withAlpha(10),
      ),
    );
  }
}
