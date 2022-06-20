import 'package:app/ui/pages/home/templates.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return GalleryPage();
  }
}
