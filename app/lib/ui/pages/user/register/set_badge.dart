import 'dart:typed_data';

import 'package:app/providers.dart';
import 'package:app/ui/pages/user/register/set_badge_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/design_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;

class SetBadgeScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<SetBadgeViewModel, SetBadgeModelState> provider;

  SetBadgeScreen({
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      String? userId = ref.watch(globalUserInfoProvider.state).state?.id;
      return SetBadgeViewModel(userId, SetBadgeModelState.init());
    });
  }

  @override
  ConsumerState createState() => _SetBadgeScreenState();
}

class _SetBadgeScreenState extends ConsumerState<SetBadgeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SetBadgeModelState modelState = ref.watch(widget.provider);
    SetBadgeViewModel model = ref.watch(widget.provider.notifier);
    final kGradientBoxDecoration = BoxDecoration(
      gradient: LinearGradient(colors: [
        Color(0xFFFFD840),
        Color(0xFFF3ACFF),
        Color(0xFF48E1FF),
      ], begin: Alignment.bottomLeft, end: Alignment.topRight),
      borderRadius: BorderRadius.circular(24),
    );
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {},
              style: RegisterStyles.appbarTextButtonStyle(ref),
              child: Text(
                'OK',
              )),
          // Icon(
          //     Icons.more_vert
          // ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Setting your social icon",
                        style: RegisterStyles.titleTextStyle(ref),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          "After following to each other, you can get each other's social icon. The social icon will be record of paying attention to history",
                          style: RegisterStyles.titleTextStyle(ref).copyWith(fontSize: 14),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: 160,
                  height: 180,
                  child: Container(
                    color: Colors.white,
                    child: Stack(
                        children: modelState.layers.map((e) {
                      return Image.memory(
                        getImageBytes(e.bytes, e.template.hue),
                        gaplessPlayback: true,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.none,
                        width: 160,
                        height: 180,
                      );
                    }).toList()),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        style: RegisterStyles.blueButtonStyle(ref).copyWith(
                            shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topRight: Radius.circular(22.0), bottomRight: Radius.circular(22.0)),
                        ))),
                        label: Text("Edit"),
                        icon: SvgPicture.asset('assets/images/magic.svg', height: 36, width: 36),
                        onPressed: () {},
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: TextButton.icon(
                        style: RegisterStyles.blueButtonStyle(ref).copyWith(
                            shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(22.0), bottomLeft: Radius.circular(22.0)),
                        ))),
                        label: Text("Change"),
                        icon: SvgPicture.asset('assets/images/shuffle.svg', height: 36, width: 36),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Center(
                      child: Container(
                        decoration: kGradientBoxDecoration,
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                                primary: designColors.dark_01.auto(ref),
                                onSurface: designColors.dark_01.auto(ref),
                                backgroundColor: designColors.light_01.auto(ref),
                                shape: RoundedRectangleBorder(
                                    borderRadius: const BorderRadius.all(Radius.circular(22.0)), side: BorderSide(color: Colors.transparent)),
                                minimumSize: const Size.fromHeight(64),
                                textStyle:
                                    ref.watch(globalThemeDataProvider.state).state.textTheme.button!.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                            onPressed: () {},
                            child: const Text('Create new'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Uint8List getImageBytes(Uint8List fileBytes, double hue) {
    img.Image? image = img.decodePng(fileBytes);
    Uint32List pixels = image!.data;
    for (int i = 0; i < pixels.length; i++) {
      int pixel = pixels[i];
      Color color = Color(pixel);
      int a = color.alpha;
      int b = color.red;
      int g = color.green;
      int r = color.blue;
      color = Color.fromARGB(a, r, g, b);
      HSLColor hslColor = HSLColor.fromColor(color);
      double hue2 = hslColor.hue + hue;
      if (hue2 > 360) {
        hue2 -= 360;
      }
      hslColor = hslColor.withHue(hue2);
      color = hslColor.toColor();
      pixels[i] = Color.fromARGB(color.alpha, color.blue, color.green, color.red).value;
    }
    return Uint8List.fromList(img.encodePng(image));
  }
}
