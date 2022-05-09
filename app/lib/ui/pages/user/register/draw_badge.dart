import 'dart:typed_data';

import 'package:app/providers.dart';
import 'package:app/ui/pages/user/register/draw_badge_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/draw_badge_view.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;

class DrawBadgeScreen extends ConsumerStatefulWidget {
  static const PALETTE_COLORS = [
    Color(0xFF212121),
    Color(0xFFFFFFFF),
    Color(0xFFFFD232),
    Color(0xFF5A2800),
    Color(0xFFFF7800),
    Color(0xFFCF3A08),
    Color(0xFF004DC4),
    Color(0xFFF03C00),
    Color(0xFF001478),
    Color(0xFFFF5064),
    Color(0xFF643CFF),
    Color(0xFF2C7FFF),
    Color(0xFFB414FF),
    Color(0xFF5AC8FA),
    Color(0xFFFF14D9),
    Color(0xFF50DC64),
    Color(0xFFC4C4C4),
  ];
  final StateNotifierProvider<DrawBadgeViewModel, DrawBadgeModelState> provider = StateNotifierProvider((ref) {
    List<PaletteItem> list =
        PALETTE_COLORS.map((e) => PaletteItem(color: e, type: PALETTE_COLORS.indexOf(e) < 2 ? PaletteItem.TYPE_OUTLINED : PaletteItem.TYPE_NORMAL)).toList();
    list.insert(0, PaletteItem(color: PALETTE_COLORS[0], type: PaletteItem.TYPE_ADD));
    list[1].selected = true;
    return DrawBadgeViewModel(DrawBadgeModelState(paletteItems: list, customColor: null, currentColor: list[1].color));
  });

  final List<Uint8List> imageLayerBytes;

  DrawBadgeScreen({
    required this.imageLayerBytes,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _DrawBadgeScreenState();
}

class _DrawBadgeScreenState extends ConsumerState<DrawBadgeScreen> {
  @override
  void initState() {
    super.initState();
    DrawBadgeViewModel model = ref.read(widget.provider.notifier);
    model.loadImage(widget.imageLayerBytes);
  }

  @override
  Widget build(BuildContext context) {
    DrawBadgeViewModel model = ref.read(widget.provider.notifier);
    DrawBadgeModelState modelState = ref.watch(widget.provider);
    debugPrint("modelState.paletteItems.length=${modelState.paletteItems.length}");

    var children = [
      Padding(
        padding: EdgeInsets.only(top: 0, bottom: 18),
        // padding: EdgeInsets.only(top: 50, bottom: 18),
        child: SizedBox(
          height: 98,
          child: buildGridView(modelState, model),
        ),
      ),
      Expanded(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: DrawBadgeView(
              image: modelState.image,
              paintColor: modelState.currentColor,
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            "scroll blablablabla",
            style: TextStyle(color: designColors.light_06.auto(ref), fontSize: 16),
          ),
        ),
      ),
      Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Spacer(flex: 2),
          RegisterStyles.rainbowButton(ref, icon: HoohIcon('assets/images/badge_clear.svg', height: 30), onPress: () {}),
          SizedBox(
            width: 24,
          ),
          RegisterStyles.rainbowButton(ref, icon: HoohIcon('assets/images/badge_revert.svg', height: 28), onPress: () {}),
          Spacer(
            flex: 1,
          ),
          Ink(
              height: 64,
              width: 64,
              child: InkWell(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(22), bottomLeft: Radius.circular(22)),
                onTap: () {},
                child: Icon(
                  Icons.done,
                  size: 36,
                  color: Colors.white,
                ),
              ),
              decoration: BoxDecoration(
                color: designColors.feiyu_blue.auto(ref),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(22), bottomLeft: Radius.circular(22)),
              ))
          // TextButton.icon(
          //   style: RegisterStyles.blueButtonStyle(ref).copyWith(
          //       shape: MaterialStateProperty.all(const RoundedRectangleBorder(
          //     borderRadius: BorderRadius.only(topLeft: Radius.circular(22.0), bottomLeft: Radius.circular(22.0)),
          //   ))),
          //   label: Text("a"),
          //   icon: Icon(Icons.done),
          //   onPressed: () {},
          // )
        ],
      ),
      SizedBox(
        height: 16,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text("Create social icon"),
      ),
      // body: ListView(children: children,),
      body: Column(
        children: children,
      ),
    );
    // return Scaffold(
    //   // appBar: AppBar(
    //   //   title: Text("Create social icon"),
    //   // ),
    //   // body: CustomScrollView(
    //   //   slivers: [
    //   //     SliverFillRemaining(
    //   //       hasScrollBody: false,
    //   //       child: body,
    //   //     )
    //   //   ],
    //   // ),
    //   body: NestedScrollView(
    //     body: SliverToBoxAdapter(
    //       child: Column( children: children),
    //     ),
    //     floatHeaderSlivers: false,
    //     headerSliverBuilder: (context, b) => [
    //       SliverAppBar(
    //         pinned: true,
    //         title: Text("Create social icon"),
    //       ),
    //     ],
    //   ),
    // );
  }

  // Uint8List? combineLayers(List<Uint8List>? fileBytes) {
  //   if (fileBytes == null) {
  //     return null;
  //   }
  //   img.Image first = img.decodePng(fileBytes[0])!;
  //   for (int i = 1; i < fileBytes.length; i++) {
  //     img.Image image = img.decodePng(fileBytes[i])!;
  //     img.copyInto(first, image);
  //   }
  //   return Uint8List.fromList(img.encodePng(first));
  // }

  Widget buildGridView(DrawBadgeModelState modelState, DrawBadgeViewModel model) {
    BorderRadius borderRadius = BorderRadius.circular(16);
    return GridView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: 38, right: 38),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        PaletteItem item = modelState.paletteItems[index];
        Widget res;
        Border selectedBorder = Border.all(color: item.selected ? designColors.feiyu_blue.auto(ref) : Colors.transparent, width: 0.5);

        switch (item.type) {
          case PaletteItem.TYPE_ADD:
            {
              res = Ink(
                decoration: BoxDecoration(
                    color: modelState.customColor != null ? modelState.customColor : null,
                    gradient: modelState.customColor != null
                        ? null
                        : const LinearGradient(colors: [
                            Color(0xFFFFD840),
                            Color(0xFFF3ACFF),
                            Color(0xFF48E1FF),
                          ], begin: Alignment.bottomLeft, end: Alignment.topRight),
                    borderRadius: borderRadius,
                    border: selectedBorder),
                child: InkWell(
                  onTap: () async {
                    Color? pickedColor = await showColorPicker(pickedColor: modelState.currentColor);
                    if (modelState.currentColor == pickedColor) {
                      return;
                    }
                    model.setCustomColor(pickedColor);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: 32,
                      color: designColors.light_01.auto(ref),
                    ),
                  ),
                ),
              );
              break;
            }
          case PaletteItem.TYPE_NORMAL:
            {
              res = Ink(
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: borderRadius,
                  ),
                  child: InkWell(
                    onTap: () {
                      model.setSelectedColor(index);
                    },
                    borderRadius: BorderRadius.circular(16),
                  ));
              break;
            }
          case PaletteItem.TYPE_OUTLINED:
          default:
            {
              res = Ink(
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: borderRadius,
                    border: Border.all(color: designColors.dark_01.auto(ref), width: 0.5),
                  ),
                  child: InkWell(
                    onTap: () {
                      model.setSelectedColor(index);
                    },
                    borderRadius: BorderRadius.circular(16),
                  ));
              break;
            }
        }
        return Container(padding: EdgeInsets.all(2), decoration: BoxDecoration(border: selectedBorder, borderRadius: BorderRadius.circular(18)), child: res);
      },
      itemCount: modelState.paletteItems.length,
    );
  }

  Future<Color?> showColorPicker({Color? pickedColor}) {
    return showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              colorPickerWidth: 300,
              pickerAreaHeightPercent: 0.7,
              labelTypes: [ColorLabelType.hsl],
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hueWheel,
              pickerAreaBorderRadius: BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(2)),
              hexInputBar: false,
              pickerColor: pickedColor ?? Colors.blue,
              onColorChanged: (color) {
                pickedColor = color;
              },
            ),
            // Use Material color picker:
            //
            // child: MaterialPicker(
            //   pickerColor: pickerColor,
            //   onColorChanged: changeColor,
            //   showLabel: true, // only on portrait mode
            // ),
            //
            // Use Block color picker:
            //
            // child: BlockPicker(
            //   pickerColor: currentColor,
            //   onColorChanged: changeColor,
            // ),
            //
            // child: MultipleChoiceBlockPicker(
            //   pickerColors: currentColors,
            //   onColorsChanged: changeColors,
            // ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ok'),
              onPressed: () {
                Navigator.of(context).pop(pickedColor);
              },
            ),
          ],
        );
      },
    );
  }
}
