import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web/global.dart';
import 'package:web/utils/design_colors.dart';
import 'package:web/utils/ui_util.dart';

class LandingScreen extends ConsumerStatefulWidget {
  final String? appLink;

  const LandingScreen({
    this.appLink,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [buildContent(), buildBar()],
    ));
  }

  Visibility buildBar() {
    return Visibility(
      visible: widget.appLink != null,
      child: Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
          color: designColors.dark_01.auto(ref),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              HoohIcon(
                "assets/images/logo.png",
                width: 48,
                height: 48,
              ),
              SizedBox(
                width: 6,
              ),
              Expanded(
                child: Text(
                  globalLocalizations.landing_bar_title,
                  style: TextStyle(fontSize: 16, fontFamily: 'Baloo', color: designColors.light_01.auto(ref)),
                ),
              ),
              buildOpenInAppButton(
                  title: globalLocalizations.landing_open_app,
                  onClick: () {
                    UiUtil.jumpToUrl(widget.appLink!);
                  })
            ],
          ),
        ),
      ),
    );
  }

  CustomScrollView buildContent() {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Spacer(),
              SizedBox(
                height: 24,
              ),
              HoohIcon(
                "assets/images/logo.png",
                width: 160,
                height: 160,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                globalLocalizations.landing_title,
                style: TextStyle(
                  color: designColors.orange.auto(ref),
                  fontFamily: 'Baloo',
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 70,
              ),
              buildStoreDownloadButton(
                  assetName: "assets/images/icon_apple.svg",
                  iconColor: designColors.light_01.auto(ref),
                  title: globalLocalizations.landing_ios_title,
                  label: globalLocalizations.landing_ios_label,
                  onClick: () {}),
              SizedBox(
                height: 18,
              ),
              buildStoreDownloadButton(
                  assetName: "assets/images/icon_playstore.svg",
                  title: globalLocalizations.landing_android_title,
                  label: globalLocalizations.landing_android_label,
                  onClick: () {}),
              SizedBox(
                height: 18,
              ),
              buildCommonButton(title: globalLocalizations.landing_apk, onClick: () {}),
              SizedBox(
                height: 56,
              ),
              Spacer(),
            ],
          ),
        ),
      ],
    );
  }

  SizedBox buildStoreDownloadButton({required String assetName, Color? iconColor, required String title, required String label, required Function() onClick}) {
    return SizedBox(
      width: 216,
      height: 56,
      child: TextButton(
          style: TextButton.styleFrom(
              primary: designColors.light_01.auto(ref),
              backgroundColor: designColors.dark_01.auto(ref),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
          onPressed: onClick,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HoohIcon(
                  assetName,
                  width: 24,
                  color: iconColor,
                ),
                SizedBox(
                  width: 12,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 12.8, fontWeight: FontWeight.normal, fontFamily: 'Baloo', height: 1.0),
                    ),
                    Text(
                      title,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal, fontFamily: 'Baloo', height: 1.0),
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }

  SizedBox buildOpenInAppButton({required String title, required Function() onClick}) {
    return SizedBox(
      width: 120,
      height: 36,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: LinearGradient(colors: [Color(0xFFED2722), Color(0xFFFEFD02)], begin: Alignment.bottomRight, end: Alignment.topLeft)),
        child: TextButton(
            style: TextButton.styleFrom(
                primary: designColors.dark_01.light,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
            onPressed: onClick,
            child: Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, fontFamily: 'Baloo', height: 1.0),
            )),
      ),
    );
  }

  SizedBox buildCommonButton({required String title, required Function() onClick}) {
    return SizedBox(
      width: 216,
      height: 56,
      child: TextButton(
          style: TextButton.styleFrom(
              primary: designColors.light_01.auto(ref),
              backgroundColor: designColors.dark_01.auto(ref),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
          onPressed: onClick,
          child: Text(
            title,
            style: TextStyle(color: designColors.light_01.auto(ref), fontWeight: FontWeight.normal, fontFamily: 'Baloo', fontSize: 24),
          )),
    );
  }
}
