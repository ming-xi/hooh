import 'dart:ui';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

mixin KeyboardLogic<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;
    final temp = keyboardVisible;
    if (_keyboardVisible == temp) return;
    _keyboardVisible = temp;
    onKeyboardChanged(keyboardVisible);
  }

  void onKeyboardChanged(bool visible);

  bool get keyboardVisible =>
      EdgeInsets.fromWindowPadding(
        WidgetsBinding.instance.window.viewInsets,
        WidgetsBinding.instance.window.devicePixelRatio,
      ).bottom >
      100;
}

void showSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    duration: Duration(seconds: 2),
    content: Text(message),
  );

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<T?> showHoohDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String barrierLabel = "",
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? Colors.black.withOpacity(0.25),
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    pageBuilder: (ctx, anim1, anim2) => WillPopScope(child: builder(context), onWillPop: () => Future.value(barrierDismissible)),
    transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8 * anim1.value, sigmaY: 8 * anim1.value),
      child: FadeTransition(
        child: child,
        opacity: anim1,
      ),
    ),
  );
}

class LoadingDialog extends ConsumerStatefulWidget {
  final LoadingDialogController _controller;

  const LoadingDialog(
    this._controller, {
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends ConsumerState<LoadingDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
            value: widget._controller.progress(),
          ),
        ),
      ),
    );
  }
}

class LoadingDialogController {
  bool hasProgress;
  double value = 0;
  double max = 100;

  LoadingDialogController({this.hasProgress = false});

  double? progress() {
    return hasProgress ? (value / max) : null;
  }
}
