import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GalleryPage extends ConsumerStatefulWidget {
  const GalleryPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _InputPageState();
}

class _InputPageState extends ConsumerState<GalleryPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.withAlpha(100),
    );
  }
}
