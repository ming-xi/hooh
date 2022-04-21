import 'package:app/utils/design_colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Setting"),
      ),
      body: CustomScrollView(slivers: [
        SliverFillRemaining(
          child: Column(
            children: [
              Divider(
                height: 1,
                color: designColors.light_02.auto(ref),
              )
            ],
          ),
        )
      ]),
    );
  }

  Widget buildTile(String title, {bool showDot = false, bool showArrow = false, String? tailText, Function()? onPress}) {
    return Ink(
      child: InkWell(
        child: Row(
          children: [
            Text(title),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
