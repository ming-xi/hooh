import 'dart:math' as math;

import 'package:app/ui/pages/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class InputPage extends ConsumerStatefulWidget {
  const InputPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _InputPageState();
}

class _InputPageState extends ConsumerState<InputPage> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      final direction = controller.position.userScrollDirection;
      if (direction == ScrollDirection.forward) {
        ref.read(bottomBarVisibilityProvider.state).state = true;
      } else if (direction == ScrollDirection.reverse) {
        ref.read(bottomBarVisibilityProvider.state).state = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.withAlpha(100),
      child: ListView.builder(
        controller: controller,
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
