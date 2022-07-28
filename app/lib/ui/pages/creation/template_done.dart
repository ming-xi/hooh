import 'dart:io';

import 'package:app/global.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/ui/pages/creation/template_add_tag_view_model.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/home/home_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/pages/user/templates.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TemplateDoneScreen extends ConsumerStatefulWidget {
  final File? imageFile;

  TemplateDoneScreen({
    this.imageFile,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TemplateDoneScreenState();
}

class _TemplateDoneScreenState extends ConsumerState<TemplateDoneScreen> with SingleTickerProviderStateMixin {
  // late AnimationController controller;
  // late Animation<Offset> offset;

  @override
  void initState() {
    super.initState();
    // controller = AnimationController(vsync: this, duration: Duration(milliseconds: 250));

    // offset = Tween<Offset>(begin: Offset(0, -1), end: Offset(0, 1)).animate(controller);

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Future.delayed(Duration(milliseconds: 500), () {
    //     controller.forward();
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    // var center = buildEarningToast();
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: HoohAppBar(
          hoohLeading: null,
          automaticallyImplyLeading: false,
          title: Text(globalLocalizations.common_done),
        ),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  AspectRatio(
                    child: widget.imageFile == null ? Placeholder() : Image.file(widget.imageFile!),
                    aspectRatio: 1,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 0),
                    child: Text(
                      globalLocalizations.template_done_description,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(
                      children: [
                        MainStyles.blueButton(
                          ref,
                          globalLocalizations.template_done_to_my_templates,
                          () {
                            popToHomeScreen(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserTemplateScreen(
                                          userId: ref.read(globalUserInfoProvider)!.id,
                                        )));
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        MainStyles.gradientButton(ref, globalLocalizations.template_done_to_feeds, () {
                          HomePageViewModel model = ref.read(homePageProvider.notifier);
                          model.updateTabIndex(HomeScreen.PAGE_INDEX_FEEDS);
                          // model.updateFeedsTabIndex(FeedsPage.PAGE_INDEX_WAITING, notifyController: true);
                          popToHomeScreen(context);
                        })
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Center buildEarningToast() {
    TextStyle toastStyle = TextStyle(fontSize: 20, color: Colors.white);
    return Center(
      child: Container(
        height: 36,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              globalLocalizations.template_done_rewards_part1,
              style: toastStyle,
            ),
            SizedBox(
              width: 8,
            ),
            HoohIcon(
              "assets/images/common_ore.svg",
              width: 16,
              height: 16,
            ),
            SizedBox(
              width: 4,
            ),
            Text(globalLocalizations.template_done_rewards_part2, style: toastStyle.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: MainStyles.gradientButtonDecoration(ref, cornerRadius: 18),
      ),
    );
  }

  Widget buildTagClip(String tag, TemplateAddTagPageViewModel model) {
    return Chip(
      backgroundColor: Colors.transparent,
      label: Text(
        "# $tag",
        style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref)),
      ),
      deleteIcon: HoohIcon(
        "assets/images/icon_delete_tag.svg",
        width: 16,
        height: 16,
        color: designColors.feiyu_blue.auto(ref),
      ),
      onDeleted: () {
        model.deleteTag(tag);
      },
    );
  }
}
