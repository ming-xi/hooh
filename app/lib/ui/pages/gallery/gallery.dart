import 'package:app/ui/pages/home/templates.dart';
import 'package:app/ui/pages/home/templates_view_model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  final List<String> contents;

  const GalleryScreen({Key? key, this.contents = const []}) : super(key: key);

  @override
  ConsumerState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      provider: StateNotifierProvider((ref) {
        return TemplatesPageViewModel(TemplatesPageModelState.init(contents: widget.contents));
      }),
    );
  }
}
