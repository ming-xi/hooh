import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ScaleScreen extends ConsumerStatefulWidget {
  final File file;

  const ScaleScreen(
    this.file, {
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _ScaleScreenState();
}

class _ScaleScreenState extends ConsumerState<ScaleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("scale"),
      ),
      body: Container(
        child: Center(
          child: Image.file(widget.file),
        ),
      ),
    );
  }
}
