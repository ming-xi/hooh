import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HoohAppBar extends AppBar {
  final Widget? hoohLeading;

  HoohAppBar({
    Key? key,
    this.hoohLeading,
    super.automaticallyImplyLeading = true,
    super.title,
    super.actions,
    super.flexibleSpace,
    super.bottom,
    super.elevation,
    super.scrolledUnderElevation,
    super.shadowColor,
    super.surfaceTintColor,
    super.shape,
    super.backgroundColor,
    super.foregroundColor,
    super.iconTheme,
    super.actionsIconTheme,
    super.primary = true,
    super.centerTitle,
    super.excludeHeaderSemantics = false,
    super.titleSpacing,
    super.toolbarOpacity = 1.0,
    super.bottomOpacity = 1.0,
    super.toolbarHeight,
    super.leadingWidth,
    super.toolbarTextStyle,
    super.titleTextStyle,
    super.systemOverlayStyle,
  }) : super(key: key, leading: (hoohLeading == null && automaticallyImplyLeading) ? _HooHBackButton() : hoohLeading);
}

class HooHSliverAppBar extends SliverAppBar {
  final Widget? hoohLeading;

  HooHSliverAppBar({
    Key? key,
    this.hoohLeading,
    super.automaticallyImplyLeading = true,
    super.title,
    super.actions,
    super.flexibleSpace,
    super.bottom,
    super.elevation,
    super.scrolledUnderElevation,
    super.shadowColor,
    super.surfaceTintColor,
    super.forceElevated = false,
    super.backgroundColor,
    super.foregroundColor,
    super.iconTheme,
    super.actionsIconTheme,
    super.primary = true,
    super.centerTitle,
    super.excludeHeaderSemantics = false,
    super.titleSpacing,
    super.collapsedHeight,
    super.expandedHeight,
    super.floating = false,
    super.pinned = false,
    super.snap = false,
    super.stretch = false,
    super.stretchTriggerOffset = 100.0,
    super.onStretchTrigger,
    super.shape,
    super.toolbarHeight = kToolbarHeight,
    super.leadingWidth,
    super.toolbarTextStyle,
    super.titleTextStyle,
    super.systemOverlayStyle,
  }) : super(key: key, leading: (hoohLeading == null && automaticallyImplyLeading) ? _HooHBackButton() : hoohLeading);
}

class _HooHBackButton extends ConsumerWidget {
  const _HooHBackButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
        onPressed: () {
          Navigator.maybePop(context);
        },
        icon: HoohIcon(
          "assets/images/icon_arrow_back.svg",
          width: 24,
          height: 24,
          color: designColors.dark_01.auto(ref),
        ));
  }
}
