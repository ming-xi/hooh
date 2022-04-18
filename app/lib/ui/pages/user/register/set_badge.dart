import 'dart:typed_data';

import 'package:app/providers.dart';
import 'package:app/ui/pages/user/register/set_badge_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/design_colors.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Badge"),
        actions: [
          Center(
            child: SizedBox(
              width: 80,
              child: TextButton(
                  onPressed: () {},
                  child: Text('OK',
                      style: TextStyle(
                        color: designColors.feiyu_blue.auto(ref),
                      ))),
            ),
          ),
          // Icon(
          //     Icons.more_vert
          // ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "set badge",
                        style: RegisterStyles.titleTextStyle(ref),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    width: 200,
                    height: 225,
                    child: Container(
                      color: Colors.white,
                      child: Stack(
                          children: modelState.layers.map((e) {
                        return Image.memory(
                          getImageBytes(e.bytes, e.template.hue),
                          gaplessPlayback: true,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.none,
                          width: 220,
                          height: 225,
                        );
                      }).toList()),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  ElevatedButton(
                    style: RegisterStyles.flatBlackButtonStyle(ref),
                    onPressed: () {},
                    child: const Text('Create new'),
                  ),
                  ElevatedButton(
                    style: RegisterStyles.flatBlackButtonStyle(ref),
                    onPressed: () {},
                    child: const Text('Create new'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
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
