import 'dart:math';
import 'dart:ui';

import 'package:common/extensions/extensions.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/template.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:crm/global.dart';
import 'package:crm/ui/pages/template/template_detail.dart';
import 'package:crm/ui/pages/template/templates_view_model.dart';
import 'package:crm/utils/constants.dart';
import 'package:crm/utils/design_colors.dart';
import 'package:crm/utils/styles.dart';
import 'package:crm/utils/ui_util.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final StateNotifierProvider<TemplatesPageViewModel, TemplatesPageModelState> templateReviewPageProvider = StateNotifierProvider((ref) {
  return TemplatesPageViewModel(TemplatesPageModelState.init());
});

class TemplateReviewPage extends ConsumerStatefulWidget {
  TemplateReviewPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TemplateReviewPageState();
}

class _TemplateReviewPageState extends ConsumerState<TemplateReviewPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  TextEditingController tagController = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TemplatesPageViewModel model = ref.read(templateReviewPageProvider.notifier);
    TemplatesPageModelState modelState = ref.watch(templateReviewPageProvider);
    Orientation? orientation = ref.watch(globalOrientationProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int gridColumn = 2;
          int minItemWidth = 200;
          gridColumn = max(constraints.maxWidth ~/ minItemWidth, gridColumn);
          SliverGridDelegateWithFixedCrossAxisCount gridDelegateWithFixedCrossAxisCount =
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridColumn, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.75);
          switch (orientation) {
            case Orientation.landscape:
              return buildHorizontalContainer(model, gridDelegateWithFixedCrossAxisCount, modelState);
            default:
              return buildVerticalContainer(model, gridDelegateWithFixedCrossAxisCount, modelState);
          }
        },
      ),
    );
  }

  SmartRefresher buildVerticalContainer(
      TemplatesPageViewModel model, SliverGridDelegateWithFixedCrossAxisCount gridDelegateWithFixedCrossAxisCount, TemplatesPageModelState modelState) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: MainStyles.getRefresherHeader(ref),
      onRefresh: () async {
        String tag = tagController.text.trim();
        model.getTemplates(
            tag: tag.isEmpty ? null : tag,
            isRefresh: true,
            onSuccess: (state) {
              // debugPrint("refresh state=$state");
              _refreshController.refreshCompleted();
              _refreshController.resetNoData();
            });
      },
      onLoading: () async {
        String tag = tagController.text.trim();
        model.getTemplates(
            tag: tag.isEmpty ? null : tag,
            onSuccess: (state) {
              if (state == PageState.noMore) {
                _refreshController.loadNoData();
              } else {
                _refreshController.loadComplete();
              }
            },
            isRefresh: false);
      },
      controller: _refreshController,
      child: CustomScrollView(
        // controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildPageTitle(),
                SizedBox(
                  height: 16,
                ),
                buildTagInputField(),
                SizedBox(
                  height: 8,
                ),

                Row(
                  children: [
                    Expanded(child: buildStateDropdownButton(expanded: true)),
                    Expanded(child: buildOrderCheckBox(expanded: true)),
                  ],
                ),
                // SizedBox(
                //   height: 16,
                // ),
                // buildSearchButton(),
                SizedBox(
                  height: 16,
                ),
                // gridView
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(4),
            sliver: SliverGrid(
              gridDelegate: gridDelegateWithFixedCrossAxisCount,
              delegate: SliverChildBuilderDelegate(
                (context, index) => buildTemplateView(modelState, index, model, context),
                childCount: modelState.templates.length,
              ),
            ),
          )
        ],
      ),
    );
  }

  Column buildHorizontalContainer(
      TemplatesPageViewModel model, SliverGridDelegateWithFixedCrossAxisCount gridDelegateWithFixedCrossAxisCount, TemplatesPageModelState modelState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, children: [
          buildPageTitle(),
          Spacer(),
        ]),
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            SizedBox(
              width: 160,
              child: buildTagInputField(),
            ),
            SizedBox(
              width: 8,
            ),
            buildStateDropdownButton(),
            SizedBox(
              width: 8,
            ),
            buildOrderCheckBox(),
            SizedBox(
              width: 8,
            ),
            SizedBox(
              width: 100,
              child: buildSearchButton(),
            )
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Expanded(
            child: LazyLoadScrollView(
          child: GridView.builder(
            controller: scrollController,
            gridDelegate: gridDelegateWithFixedCrossAxisCount,
            itemBuilder: (context, index) => buildTemplateView(modelState, index, model, context),
            padding: EdgeInsets.all(4),
            itemCount: modelState.templates.length,
          ),
          onEndOfPage: () {
            requestData(horizontalLayout: true, isRefresh: false);
          },
          scrollOffset: 300,
        ))
      ],
    );
  }

  TemplateView buildTemplateView(TemplatesPageModelState modelState, index, TemplatesPageViewModel model, context) {
    return TemplateView(
      template: modelState.templates[index],
      onApprove: (t) {
        showHoohDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return LoadingDialog(LoadingDialogController());
            });
        model.approveTemplate(t, onSuccess: () {
          Navigator.of(
            context,
          ).pop();
        }, onFailed: (error) {
          showCommonRequestErrorDialog(ref, context, error);
        });
      },
      onReject: (t) {
        showHoohDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return LoadingDialog(LoadingDialogController());
            });
        model.rejectTemplate(t, onSuccess: () {
          Navigator.of(
            context,
          ).pop();
        }, onFailed: (error) {
          showCommonRequestErrorDialog(ref, context, error);
        });
      },
    );
  }

  // Widget buildSizeMenu() {
  //   return
  // }
  Widget buildStateDropdownButton({bool expanded = false}) {
    TemplatesPageViewModel model = ref.read(templateReviewPageProvider.notifier);
    TemplatesPageModelState modelState = ref.watch(templateReviewPageProvider);
    DropdownButton<int> dropdownButton = DropdownButton<int>(
      value: modelState.templateState,
      dropdownColor: designColors.light_00.auto(ref),
      style: TextStyle(color: designColors.dark_01.auto(ref)),
      items: [
        Template.STATE_PENDING,
        Template.STATE_FEATURED,
        Template.STATE_REJECTED,
      ]
          .map((e) => DropdownMenuItem<int>(
                value: e,
                child: Text(Template.getStateText(e)),
              ))
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        model.setTemplateState(value);
        String tag = tagController.text.trim();
        if (expanded) {
          _refreshController.requestRefresh();
        } else {
          requestData(horizontalLayout: !expanded, isRefresh: true);
          // showHoohDialog(
          //     context: context,
          //     barrierDismissible: false,
          //     builder: (context) {
          //       return LoadingDialog(LoadingDialogController());
          //     });
          // model.getTemplates(
          //   tag: tag.isEmpty ? null : tag,
          //   isRefresh: true,
          //   onSuccess: (state) {
          //     Navigator.of(
          //       context,
          //     ).pop();
          //   },
          //   onFailed: (error) {
          //     Navigator.of(
          //       context,
          //     ).pop();
          //     showCommonRequestErrorDialog(ref, context, error);
          //   },
          // );
        }
      },
    );
    return Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Text("筛选状态", style: TextStyle(color: designColors.dark_01.auto(ref))),
        SizedBox(
          width: 8,
        ),
        expanded
            ? Expanded(
                child: dropdownButton,
              )
            : dropdownButton,
      ],
    );
  }

  Widget buildOrderCheckBox({bool expanded = false}) {
    TemplatesPageViewModel model = ref.read(templateReviewPageProvider.notifier);
    TemplatesPageModelState modelState = ref.watch(templateReviewPageProvider);
    Checkbox checkbox = Checkbox(
        value: modelState.desc,
        onChanged: (value) {
          model.setDesc(value ?? false);
        });
    return Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Text(
          "倒序排列",
          style: TextStyle(color: designColors.dark_01.auto(ref)),
        ),
        SizedBox(
          width: 8,
        ),
        expanded
            ? Expanded(
                child: checkbox,
              )
            : checkbox,
      ],
    );
  }

  Widget buildSearchButton() {
    // TemplatesPageViewModel model = ref.read(templateReviewPageProvider.notifier);
    return MainStyles.blueButton(ref, "搜索", () {
      // String tag = tagController.text.trim();
      // model.getTemplates(tag: tag.isEmpty ? null : tag, isRefresh: true);
      requestData(horizontalLayout: true, isRefresh: true);
    });
  }

  Widget buildTagInputField() {
    return TextField(
      decoration: RegisterStyles.commonInputDecoration("请输入tag...", ref).copyWith(
          isDense: true,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: designColors.dark_03.auto(ref),
            size: 24,
          )),
      style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref)),
      controller: tagController,
    );
  }

  Widget buildPageTitle() {
    return Text(
      Constants.PAGE_NAME_TEMPLATES,
      style: MainStyles.pageTitleStyle(ref),
    );
  }

  void requestData({bool horizontalLayout = false, bool isRefresh = true}) {
    TemplatesPageViewModel model = ref.read(templateReviewPageProvider.notifier);
    String tag = tagController.text.trim();
    if (!horizontalLayout) {
      if (isRefresh) {
        _refreshController.requestRefresh();
      } else {
        _refreshController.requestLoading();
      }
    } else {
      if (isRefresh) {
        showHoohDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return LoadingDialog(LoadingDialogController());
            });
      }
      model.getTemplates(
        tag: tag.isEmpty ? null : tag,
        isRefresh: isRefresh,
        onSuccess: (state) {
          if (isRefresh) {
            Navigator.of(
              context,
            ).pop();
          }
        },
        onFailed: (error) {
          if (isRefresh) {
            Navigator.of(
              context,
            ).pop();
          }
          showCommonRequestErrorDialog(ref, context, error);
        },
      );
    }
  }
}

class TemplateView extends ConsumerStatefulWidget {
  final Template template;
  final Function(Template template) onApprove;
  final Function(Template template) onReject;

  const TemplateView({
    required this.template,
    required this.onApprove,
    required this.onReject,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TemplateViewState();
}

class _TemplateViewState extends ConsumerState<TemplateView> {
  double radius = 16;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: designColors.light_01.auto(ref),
      elevation: 2,
      borderRadius: BorderRadius.circular(radius),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TemplateDetailScreen(
                            templateId: widget.template.id,
                            template: widget.template,
                          )));
            },
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(radius), topRight: Radius.circular(radius)),
                      child: HoohImage(imageUrl: widget.template.imageUrl),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      willChange: true,
                      painter: _CanvasPainter(
                        ref,
                        frameX: double.tryParse(widget.template.frameX) ?? 0,
                        frameY: double.tryParse(widget.template.frameY) ?? 0,
                        frameW: double.tryParse(widget.template.frameWidth) ?? 0,
                        frameH: double.tryParse(widget.template.frameHeight) ?? 0,
                        textColor: HexColor.fromHex(widget.template.textColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: Text(
          //           widget.template.author!.name,
          //           style: TextStyle(fontSize: 12, color: designColors.dark_03.auto(ref), overflow: TextOverflow.ellipsis),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Visibility(
              visible: widget.template.state == Template.STATE_PENDING,
              replacement: Center(
                child: Text(
                  Template.getStateText(widget.template.state),
                  style: TextStyle(fontSize: 16, color: designColors.dark_03.auto(ref)),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      widget.onApprove(widget.template);
                    },
                    icon: Icon(Icons.done_rounded),
                    color: widget.template.state == Template.STATE_FEATURED ? Colors.green : designColors.dark_03.auto(ref),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      widget.onReject(widget.template);
                    },
                    icon: Icon(Icons.clear_rounded),
                    color: widget.template.state == Template.STATE_REJECTED ? Colors.red : designColors.dark_03.auto(ref),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final double textPadding = 8;

  final double frameX;
  final double frameY;
  final double frameW;
  final double frameH;
  final Color textColor;

  final Paint p = Paint();
  Offset? pointer;

  _CanvasPainter(
    WidgetRef ref, {
    required this.frameX,
    required this.frameY,
    required this.frameW,
    required this.frameH,
    required this.textColor,
  }) {
    p.strokeCap = StrokeCap.square;
    p.strokeWidth = 1;
    p.style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawFrame(canvas, size);
    drawText(canvas, size);
  }

  void drawFrame(Canvas canvas, Size size) {
    p.color = textColor;
    canvas.drawRect(
        Rect.fromLTWH(translate(frameX, size.width), translate(frameY, size.height), translate(frameW, size.width), translate(frameH, size.height)), p);
  }

  void drawText(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: textColor,
      fontSize: 16,
    );
    final textSpan = TextSpan(
      text: "输入文字...",
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: translate(frameW, size.width) - textPadding * 2,
    );
    final offset = Offset(translate(frameX, size.width) + textPadding, translate(frameY, size.height) + textPadding);
    textPainter.paint(canvas, offset);
  }

  double translate(double value, double size) {
    return value / 100 * size;
  }

  @override
  bool shouldRepaint(_CanvasPainter oldDelegate) {
    return this != oldDelegate;
  }
}
