import 'dart:typed_data';

import 'package:app/providers.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/user/register/draw_badge.dart';
import 'package:app/ui/pages/user/register/set_badge_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/user.dart';
import 'package:flutter/foundation.dart';
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
    SetBadgeViewModel model = ref.read(widget.provider.notifier);

    List<TextButton> actions = [
      TextButton(
          onPressed: () async {
            showDialog(
                context: context,
                builder: (context) {
                  return LoadingDialog(LoadingDialogController());
                });
            dynamic result = await model.changeUserBadge();
            Navigator.pop(context);
            if (result is HoohApiErrorResponse) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(result.message),
                    );
                  });
            } else if (result is bool && !result) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text("uploading failed"),
                    );
                  });
            } else if (result is User) {
              ref.read(globalUserInfoProvider.state).state = result;
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
            }
          },
          style: RegisterStyles.appbarTextButtonStyle(ref),
          child: Text(
            'OK',
          )),
      // Icon(
      //     Icons.more_vert
      // ),
    ];
    if (kDebugMode) {
      actions.insert(
          0,
          TextButton(
              style: RegisterStyles.appbarTextButtonStyle(ref),
              onPressed: () {
                model.toggleOriginalColor();
              },
              child: Text(
                modelState.originalColor ? "显示变色" : "显示原颜色",
              )));
    }
    List<Uint8List> imageLayerBytes =
        modelState.layers.map((e) => getImageBytes(e.bytes, double.tryParse(e.template.hue) ?? 0, modelState.originalColor)).toList();
    var oldColumn = Column(
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
                  child: Stack(
                      children: imageLayerBytes.map((e) {
                    return Image.memory(
                      // getImageBytes(e.bytes, e.template.hue, modelState.originalColor),
                      e,
                      gaplessPlayback: true,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.none,
                      width: 160,
                      height: 180,
                    );
                  }).toList()),
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
                        icon: HoohIcon('assets/images/magic.svg', height: 36, width: 36),
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
                        icon: HoohIcon('assets/images/shuffle.svg', height: 36, width: 36),
                        onPressed: () {
                          String? userId = ref.read(globalUserInfoProvider.state).state?.id;
                          model.getRandomBadge(userId!);
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Center(
                      child: RegisterStyles.rainbowButton(ref,
                          icon: const Text('Create new'), label: HoohIcon('assets/images/arrow_right_blue.svg', height: 24, width: 24), onPress: () {
                        Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DrawBadgeScreen(
                              imageLayerBytes: imageLayerBytes,
                            )));
              }),
            ),
          ),
        ),
      ],
    );
    var newColumn = Column(
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
          child: Stack(
              children: imageLayerBytes.map((e) {
            return Image.memory(
              // getImageBytes(e.bytes, e.template.hue, modelState.originalColor),
              e,
              gaplessPlayback: true,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
              width: 160,
              height: 180,
            );
          }).toList()),
        ),
        SizedBox(
          height: 64,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Center(
              child: TextButton.icon(
                style: RegisterStyles.blueButtonStyle(ref).copyWith(
                    shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(22)),
                ))),
                label: Text("Change"),
                icon: HoohIcon('assets/images/shuffle.svg', height: 36, width: 36),
                onPressed: () {
                  String? userId = ref.read(globalUserInfoProvider.state).state?.id;
                  model.getRandomBadge(userId!);
                },
              ),
            ),
          ),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        actions: actions,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: newColumn,
          )
        ],
      ),
    );
  }

  Uint8List getImageBytes(Uint8List fileBytes, double hue, bool originalColor) {
    if (originalColor) {
      return fileBytes;
    }
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
