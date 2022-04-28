import 'package:app/test.dart';
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // HoohImage(imageUrl: imageUrl, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height),
      CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              children: [],
            ),
          )
        ],
      ),
      Positioned(
        top: 16,
        right: 16,
        child: SafeArea(
          child: FloatingActionButton(
            child: Icon(Icons.code),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TestMenuScreen()));
            },
          ),
        ),
      )
    ]);
  }
}
