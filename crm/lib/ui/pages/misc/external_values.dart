import 'package:common/models/external_value.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:crm/ui/pages/base/base_panel.dart';
import 'package:crm/ui/pages/misc/external_values_view_model.dart';
import 'package:crm/utils/constants.dart';
import 'package:crm/utils/design_colors.dart';
import 'package:crm/utils/styles.dart';
import 'package:crm/utils/ui_util.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ExternalValuesPage extends BasePanel {
  final StateNotifierProvider<ExternalValuesPageViewModel, ExternalValuesPageModelState> provider = StateNotifierProvider((ref) {
    return ExternalValuesPageViewModel(ExternalValuesPageModelState.init());
  });

  ExternalValuesPage({super.key});

  @override
  BasePanelState<ExternalValuesPage> createBaseState() => _ExternalValuesPageState();
}

class _ExternalValuesPageState extends BasePanelState<ExternalValuesPage> {
  @override
  Widget buildHorizontalContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, children: [
          buildPageTitle(Constants.PAGE_NAME_CONFIGS),
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
              width: 100,
              child: buildRefreshButton(),
            )
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Expanded(
            child: Material(
                borderRadius: BorderRadius.circular(12),
                color: designColors.light_01.auto(ref),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: buildTable(),
                      )
                    ],
                  ),
                )))
      ],
    );
  }

  @override
  Widget buildVerticalContainer() {
    ExternalValuesPageViewModel model = ref.read(widget.provider.notifier);
    ExternalValuesPageModelState modelState = ref.watch(widget.provider);

    TextStyle normalTextStyle = TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref));
    TextStyle lightTextStyle = TextStyle(fontSize: 12, color: designColors.dark_03.auto(ref));
    TextStyle headerTextStyle = lightTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 14);

    return Material(
        borderRadius: BorderRadius.circular(12),
        color: designColors.light_01.auto(ref),
        child: buildDefaultRefresher(
            canLoadMore: false,
            sliverBody: SliverPadding(
              padding: EdgeInsets.all(8),
              sliver: SliverList(
                delegate: SliverChildListDelegate(modelState.externalValues.map(
                  (e) {
                    int index = modelState.externalValues.indexOf(e);
                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(color: designColors.dark_03.auto(ref).withOpacity(index % 2 == 1 ? 0 : 0.1)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "参数名",
                                  style: headerTextStyle,
                                ),
                              ),
                              buildOperationButton(normalTextStyle, e, model)
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          buildDes(e, normalTextStyle),
                          buildKey(e, lightTextStyle),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "参数类型",
                            style: headerTextStyle,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          buildType(e, normalTextStyle),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "值",
                            style: headerTextStyle,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          buildValue(e, normalTextStyle),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "最后修改",
                            style: headerTextStyle,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          buildLastModifier(e, normalTextStyle, lightTextStyle),
                        ],
                      ),
                    );
                  },
                ).toList()),
              ),
            )));
  }

  Table buildTable() {
    ExternalValuesPageViewModel model = ref.read(widget.provider.notifier);
    ExternalValuesPageModelState modelState = ref.watch(widget.provider);

    TextStyle normalTextStyle = TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref));
    TextStyle lightTextStyle = TextStyle(fontSize: 12, color: designColors.dark_03.auto(ref));
    TextStyle headerTextStyle = lightTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 14);

    TableRow headerRow = TableRow(children: [
      TableCell(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "参数名",
          style: headerTextStyle,
        ),
      )),
      TableCell(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "参数类型",
          style: headerTextStyle,
        ),
      )),
      TableCell(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "值",
          style: headerTextStyle,
        ),
      )),
      TableCell(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "最后修改",
          style: headerTextStyle,
        ),
      )),
      TableCell(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "操作",
          style: headerTextStyle,
        ),
      )),
    ]);
    List<TableRow> rows = modelState.externalValues.map((e) {
      int index = modelState.externalValues.indexOf(e);
      return TableRow(decoration: BoxDecoration(color: designColors.dark_03.auto(ref).withOpacity(index % 2 == 1 ? 0 : 0.1)), children: [
        TableCell(
            child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDes(e, normalTextStyle),
              buildKey(e, lightTextStyle),
            ],
          ),
        )),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildType(e, normalTextStyle),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildValue(e, normalTextStyle),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildLastModifier(e, normalTextStyle, lightTextStyle),
          ),
        ),
        TableCell(
          child: buildOperationButton(normalTextStyle, e, model),
        ),
      ]);
    }).toList();

    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(),
        1: FixedColumnWidth(96),
        2: FlexColumnWidth(),
        3: FixedColumnWidth(160),
        4: FixedColumnWidth(48),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [headerRow, ...rows],
    );
  }

  Widget buildLastModifier(ExternalValue e, TextStyle normalTextStyle, TextStyle lightTextStyle) {
    return e.user == null
        ? Container()
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.user!.name,
                style: normalTextStyle,
              ),
              Text(
                DateUtil.getZonedDateString(e.updatedAt),
                style: lightTextStyle,
              ),
            ],
          );
  }

  Text buildValue(ExternalValue e, TextStyle style) {
    return Text(
      e.value,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }

  Text buildType(ExternalValue e, TextStyle style) {
    return Text(
      getDisplayType(e.type),
      style: style,
    );
  }

  Text buildKey(ExternalValue e, TextStyle style) {
    return Text(
      e.key,
      style: style,
    );
  }

  Text buildDes(ExternalValue e, TextStyle style) {
    return Text(
      e.des,
      style: style,
    );
  }

  PopupMenuButton<dynamic> buildOperationButton(TextStyle normalTextStyle, ExternalValue e, ExternalValuesPageViewModel model) {
    return PopupMenuButton(
      color: designColors.light_00.auto(ref),
      iconSize: 32,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(const Radius.circular(8)),
      ),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          child: Text(
            "修改",
            style: normalTextStyle,
          ),
          onTap: () {
            Future.delayed(const Duration(milliseconds: 250), () {
              showEditValueDialog(context, e, normalTextStyle, model);
            });
          },
        )
      ],
      child: Icon(
        Icons.more_horiz_rounded,
        color: designColors.dark_01.auto(ref),
      ),
    );
  }

  void showEditValueDialog(BuildContext context, ExternalValue externalValue, TextStyle normalTextStyle, ExternalValuesPageViewModel model) {
    if (externalValue.type == ExternalValue.TYPE_OBJECT || externalValue.type == ExternalValue.TYPE_ARRAY) {
      showHoohDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("暂不支持修改对象和数组类型的数据"),
        ),
      );
      return;
    }
    TextInputType? keyboardType;
    if (externalValue.type == ExternalValue.TYPE_INT) {
      keyboardType = TextInputType.number;
    } else if (externalValue.type == ExternalValue.TYPE_DOUBLE) {
      keyboardType = TextInputType.numberWithOptions(decimal: true);
    }
    showHoohDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController(text: externalValue.value);
        return AlertDialog(
          title: Text("修改参数"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                externalValue.des,
                textAlign: TextAlign.start,
                style: normalTextStyle,
              ),
              SizedBox(
                height: 8,
              ),
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: TextStyle(color: designColors.dark_01.auto(ref)),
                decoration: RegisterStyles.commonInputDecoration("", ref),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pop();
                  showHoohDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return LoadingDialog(LoadingDialogController());
                      });
                  model.editValue(externalValue, controller.text, onSuccess: (value) {
                    Navigator.of(
                      context,
                    ).pop();
                    showSnackBar(context, "修改成功");
                  }, onFailed: (error) {
                    Navigator.of(
                      context,
                    ).pop();
                    showCommonRequestErrorDialog(ref, context, error);
                  });
                },
                child: Text("提交"))
          ],
        );
      },
    );
  }

  String getDisplayType(int type) {
    switch (type) {
      case ExternalValue.TYPE_INT:
        return "整数";
      case ExternalValue.TYPE_DOUBLE:
        return "小数";
      case ExternalValue.TYPE_STRING:
        return "字符串";
      case ExternalValue.TYPE_OBJECT:
        return "对象";
      case ExternalValue.TYPE_ARRAY:
        return "数组";
      default:
        return "未知";
    }
  }

  @override
  void requestData({bool horizontalLayout = false, bool isRefresh = true}) {
    ExternalValuesPageViewModel model = ref.read(widget.provider.notifier);
    model.getAllValues(
      onSuccess: (state) {
        if (isRefresh) {
          notifyRefreshComplete();
        } else {
          notifyLoadMoreComplete(state);
        }
      },
      onFailed: (error) {
        showCommonRequestErrorDialog(ref, context, error);
      },
    );
  }
}
