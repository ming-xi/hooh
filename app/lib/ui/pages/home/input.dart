import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class InputPage extends ConsumerStatefulWidget {
  const InputPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _InputPageState();
}

class _InputPageState extends ConsumerState<InputPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.withAlpha(100),
      child: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("test"),
            tileColor: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
          );
        },
      ),
    );
  }
}
