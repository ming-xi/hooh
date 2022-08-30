import 'package:app/global.dart';
import 'package:app/ui/pages/user/register/start.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/app_link.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:page_indicator/page_indicator.dart';

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    List<IntroPage> pages = [
      IntroPage(
        backgroundAssetName: "assets/images/figure_intro_p1_background.png",
        foregroundAssetName: "assets/images/figure_intro_p1_foreground.png",
        backgroundColors: [Color(0xFF3BE7E7), Color(0xFF00B4C4)],
        title: globalLocalizations.intro_p1_title,
        plainContent: globalLocalizations.intro_p1_content,
      ),
      IntroPage(
        backgroundAssetName: "assets/images/figure_intro_p2_background.png",
        foregroundAssetName: "assets/images/figure_intro_p2_foreground.png",
        backgroundColors: [Color(0xFFFF7769), Color(0xFFE85B33)],
        title: globalLocalizations.intro_p2_title,
        plainContent: globalLocalizations.intro_p2_content,
      ),
      IntroPage(
        backgroundAssetName: "assets/images/figure_intro_p3_background.png",
        foregroundAssetName: "assets/images/figure_intro_p3_foreground.png",
        backgroundColors: [Color(0xFFFF70E8), Color(0xFFE23DAF)],
        title: globalLocalizations.intro_p3_title,
        plainContent: globalLocalizations.intro_p3_content,
      ),
      IntroPage(
        backgroundAssetName: "assets/images/figure_intro_p4_background.png",
        foregroundAssetName: "assets/images/figure_intro_p4_foreground.png",
        backgroundColors: [Color(0xFF7E7AFE), Color(0xFF624AD8)],
        title: globalLocalizations.intro_p4_title,
        showButton: true,
        richContent: HoohLocalizedRichText(
          text: globalLocalizations.intro_p4_content,
          textAlign: TextAlign.center,
          keys: [
            HoohLocalizedTextKey(
                key: globalLocalizations.intro_p4_link,
                text: globalLocalizations.intro_p4_link,
                style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Baloo', height: 1),
                onTap: () {
                  openAppLink(context, "https://twitter.com/HOOH_Official");
                }),
          ],
          defaultTextStyle: TextStyle(fontSize: 18, color: Color(0xFFFEF800), fontFamily: 'Baloo', height: 1),
        ),
      ),
    ];
    return PageIndicatorContainer(
      align: IndicatorAlign.bottom,
      length: pages.length,
      indicatorSpace: 8.0,
      padding: const EdgeInsets.only(bottom: 48),
      indicatorColor: Color(0xFFFFFFFF).withOpacity(0.4),
      indicatorSelectorColor: Color(0xFFFEF800),
      shape: IndicatorShape.circle(size: 16),
      // shape: IndicatorShape.roundRectangleShape(size: Size.square(12),cornerSize: Size.square(3)),
      // shape: IndicatorShape.oval(size: Size(12, 8)),
      child: PageView(
        physics: ClampingScrollPhysics(),
        children: pages,
      ),
    );
  }
}

class IntroPage extends ConsumerStatefulWidget {
  final String backgroundAssetName;
  final String foregroundAssetName;
  final List<Color> backgroundColors;
  final String title;
  final String? plainContent;
  final bool showButton;
  final HoohLocalizedRichText? richContent;

  const IntroPage({
    required this.backgroundAssetName,
    required this.foregroundAssetName,
    required this.backgroundColors,
    required this.title,
    this.plainContent,
    this.richContent,
    this.showButton = false,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _IntroPageState();
}

class _IntroPageState extends ConsumerState<IntroPage> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    List<Widget> children = [
      Text(
        widget.title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 34, color: Colors.white, fontFamily: 'Baloo', height: 1),
      ),
      SizedBox(
        height: 24,
      ),
      widget.richContent != null
          ? widget.richContent!
          : Text(
              widget.plainContent!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Color(0xFFFEF800), fontFamily: 'Baloo', height: 1),
            ),
    ];
    if (widget.showButton) {
      children.addAll([
        SizedBox(
          height: 24,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: TextButton(
            onPressed: () {
              preferences.putBool(Preferences.KEY_INTRO_PAGES_READ, true);
              Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    settings: null,
                    pageBuilder: (context, anim1, anim2) => StartScreen(
                      scene: StartScreen.SCENE_START,
                    ),
                  ));
            },
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    globalLocalizations.intro_p4_button,
                    style: const TextStyle(fontFamily: 'Baloo'),
                  ),
                  Icon(
                    Icons.play_arrow_rounded,
                    size: 28,
                    color: Color(0xFF5039BD),
                  )
                ],
              ),
            ),
            style: RegisterStyles.blueButtonStyle(ref, cornerRadius: 100).copyWith(
                overlayColor: MaterialStateProperty.all(Colors.black.withOpacity(0.05)),
                foregroundColor: MaterialStateProperty.all(Color(0xFF5039BD)),
                backgroundColor: MaterialStateProperty.all(Color(0xFFFEF800)),
                textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16))),
          ),
        )
      ]);
    }
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: widget.backgroundColors, begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: Stack(
        children: [
          Image.asset(
            widget.backgroundAssetName,
            width: screenSize.width,
            fit: BoxFit.cover,
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: screenSize.height / 2,
              child: Image.asset(
                widget.foregroundAssetName,
                width: screenSize.width,
              )),
          Positioned(
            left: 0,
            right: 0,
            top: screenSize.height / 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
