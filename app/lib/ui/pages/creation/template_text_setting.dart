import 'dart:io';

import 'package:app/global.dart';
import 'package:app/ui/pages/creation/template_add_tag.dart';
import 'package:app/ui/pages/creation/template_text_setting_view_model.dart';
import 'package:app/ui/pages/user/register/draw_badge_view_model.dart';
import 'package:app/ui/widgets/template_text_setting_view.dart';
import 'package:app/ui/widgets/template_text_setting_view_model.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TemplateTextSettingScreen extends ConsumerStatefulWidget {
  // static const PALETTE_COLORS = [
  //   Color(0xFFFFFFFF),
  //   Color(0xFF000000),
  //   Color(0xFFD2D2D2),
  //   Color(0xFF424242),
  //   Color(0xFF2C7FFF),
  //   Color(0xFF004DC4),
  //   Color(0xFF5A2800),
  //   Color(0xFF5AC8FA),
  //   Color(0xFF001478),
  //   Color(0xFFCF3A08),
  //   Color(0xFF50DC64),
  //   Color(0xFF643CFF),
  //   Color(0xFFF03C00),
  //   Color(0xFFFFD232),
  //   Color(0xFFB414FF),
  //   Color(0xFFFF5064),
  //   Color(0xFFFF7800),
  //   Color(0xFFFF14D9),
  // ];
  static const PALETTE_COLORS = [
    Color(0xFFFFFFFF),
    Color(0xFF000000),
    Color(0xFFD2D2D2),
    Color(0xFFCF3A08),
    Color(0xFF2C7FFF),
    Color(0xFFFF7800),
    Color(0xFF1E942F),
    Color(0xFF643CFF),
    Color(0xFFF03C00),
    Color(0xFF004DC4),
    Color(0xFFFFD232),
    Color(0xFF50DC64),
    Color(0xFFB414FF),
    Color(0xFFFF5064),
    Color(0xFF5AC8FA),
    Color(0xFF5A2800),
    Color(0xFF50DCC6),
    Color(0xFFFF14D9),
  ];
  final File? imageFile;
  final StateNotifierProvider<TemplateTextSettingScreenViewModel, TemplateTextSettingScreenModelState> provider = StateNotifierProvider((ref) {
    List<PaletteItem> list =
        PALETTE_COLORS.map((e) => PaletteItem(color: e, type: PALETTE_COLORS.indexOf(e) < 2 ? PaletteItem.TYPE_OUTLINED : PaletteItem.TYPE_NORMAL)).toList();
    list[2].selected = true;
    return TemplateTextSettingScreenViewModel(TemplateTextSettingScreenModelState.init(list));
  });
  final StateNotifierProvider<TemplateTextSettingViewModel, TemplateTextSettingModelState> textSettingProvider = StateNotifierProvider((ref) {
    return TemplateTextSettingViewModel(TemplateTextSettingModelState.init(PALETTE_COLORS[2]));
  });

  TemplateTextSettingScreen({
    this.imageFile,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TemplateTextSettingScreenState();
}

class _TemplateTextSettingScreenState extends ConsumerState<TemplateTextSettingScreen> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      TemplateTextSettingScreenViewModel model = ref.read(widget.provider.notifier);
      model.changeTab(tabController.index);
      TemplateTextSettingViewModel textSettingModel = ref.read(widget.textSettingProvider.notifier);
      textSettingModel.setFrameLocked(tabController.index != 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    TemplateTextSettingScreenModelState modelState = ref.watch(widget.provider);
    TemplateTextSettingScreenViewModel model = ref.read(widget.provider.notifier);
    TemplateTextSettingViewModel textSettingModel = ref.read(widget.textSettingProvider.notifier);
    TemplateTextSettingModelState textSettingModelState = ref.watch(widget.textSettingProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(globalLocalizations.template_text_setting_title),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TemplateAddTagScreen(
                              imageFile: widget.imageFile,
                              textSettingProvider: StateNotifierProvider((ref) {
                                return TemplateTextSettingViewModel(textSettingModelState.copyWith(frameLocked: true));
                              }),
                            )));
              },
              icon: Icon(Icons.arrow_forward))
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Stack(
            children: [
              AspectRatio(
                child: Image.file(widget.imageFile!),
                aspectRatio: 1,
              ),
              AspectRatio(aspectRatio: 1, child: TemplateTextSettingView(widget.textSettingProvider))
            ],
          ),
          TabBar(
            controller: tabController,
            tabs: [
              Tab(
                icon: HoohIcon(
                  "assets/images/icon_text_setting_selected.svg",
                  width: 36,
                  height: 36,
                  color: modelState.selectedTab == 0 ? designColors.dark_01.auto(ref) : designColors.dark_03.auto(ref),
                ),
              ),
              Tab(
                icon: HoohIcon(
                  "assets/images/icon_text_color_selected.svg",
                  width: 36,
                  height: 36,
                  color: modelState.selectedTab == 1 ? designColors.dark_01.auto(ref) : designColors.dark_03.auto(ref),
                ),
              ),
            ],
            indicatorColor: designColors.dark_01.auto(ref),
            indicatorSize: TabBarIndicatorSize.label,
          ),
          Expanded(
            child: TabBarView(controller: tabController, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 56.0),
                child: Center(
                  child: Builder(builder: (context) {
                    return HoohLocalizedRichText(
                        text: globalLocalizations.template_text_setting_description,
                        keys: [
                          HoohLocalizedWidgetKey(
                            key: globalLocalizations.template_text_setting_description_button,
                            widget: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: HoohIcon(
                                "assets/images/icon_template_text_frame_scale.png",
                                width: 18,
                                height: 18,
                              ),
                            ),
                          )
                        ],
                        defaultTextStyle: TextStyle(fontSize: 16, fontFamily: 'Linotte', fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref)));
                    // return Text(
                    //   globalLocalizations.template_text_setting_description,
                    //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref)),
                    // );
                  }),
                ),
              ),
              LayoutBuilder(builder: (context, constraints) {
                double itemSize = 48;
                double spacing = 2;
                double minPadding = 2;
                int rowCount = (constraints.maxHeight - 2 * minPadding + spacing) ~/ (itemSize + spacing);
                if (rowCount > 3) {
                  rowCount = 3;
                }
                BorderRadius borderRadius = BorderRadius.circular(16);
                BorderRadius outlineBorderRadius = BorderRadius.circular(18);
                double padding = (constraints.maxHeight - itemSize * rowCount - spacing * (rowCount - 1)) / 2;
                return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: padding),
                  itemCount: modelState.paletteItems.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    PaletteItem item = modelState.paletteItems[index];
                    Widget res;
                    Border selectedBorder = Border.all(color: item.selected ? designColors.feiyu_blue.auto(ref) : Colors.transparent, width: 0.5);

                    switch (item.type) {
                      case PaletteItem.TYPE_NORMAL:
                        {
                          res = Ink(
                              decoration: BoxDecoration(
                                color: item.color,
                                borderRadius: borderRadius,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Color setSelectedColor = model.setSelectedColor(index);
                                  textSettingModel.setSelectedColor(setSelectedColor);
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
                                  Color setSelectedColor = model.setSelectedColor(index);
                                  textSettingModel.setSelectedColor(setSelectedColor);
                                },
                                borderRadius: BorderRadius.circular(16),
                              ));
                          break;
                        }
                    }
                    return Container(
                        width: itemSize,
                        height: itemSize,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(border: selectedBorder, borderRadius: outlineBorderRadius),
                        child: res);
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: rowCount, crossAxisSpacing: spacing, mainAxisSpacing: spacing),
                );
              }),
            ]),
          )
        ],
      ),
    );
  }
}
