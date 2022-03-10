import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MePage extends ConsumerStatefulWidget {
  const MePage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _InputPageState();
}

class _InputPageState extends ConsumerState<MePage> {

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.yellow.withAlpha(100),);
  }
}
