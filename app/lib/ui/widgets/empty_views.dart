import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EmptyView extends ConsumerWidget {
  final String text;

  const EmptyView({
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _BaseView(text: text, svgPath: "assets/images/figure_empty_list.svg");
  }
}

class ErrorView extends ConsumerWidget {
  final String text;

  const ErrorView({
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _BaseView(text: text, svgPath: "assets/images/figure_error.svg");
  }
}

class _BaseView extends ConsumerWidget {
  final String text;
  final String svgPath;

  const _BaseView({
    required this.text,
    required this.svgPath,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HoohIcon(
              svgPath,
              width: 64,
              color: designColors.dark_03.auto(ref),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              text,
              style: TextStyle(color: designColors.dark_03.auto(ref), fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
