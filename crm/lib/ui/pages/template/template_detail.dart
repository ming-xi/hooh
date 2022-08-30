import 'package:common/models/template.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:crm/global.dart';
import 'package:crm/ui/pages/template/template_detail_view_model.dart';
import 'package:crm/utils/design_colors.dart';
import 'package:crm/utils/styles.dart';
import 'package:crm/utils/ui_util.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TemplateDetailScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<TemplateDetailScreenViewModel, TemplateDetailScreenModelState> provider;

  TemplateDetailScreen({
    required String templateId,
    Template? template,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return TemplateDetailScreenViewModel(TemplateDetailScreenModelState.init(templateId, template: template));
    });
  }

  @override
  ConsumerState createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends ConsumerState<TemplateDetailScreen> {
  TextEditingController tagController = TextEditingController();
  FocusNode tagNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TemplateDetailScreenViewModel model = ref.read(widget.provider.notifier);
      showHoohDialog(context: context, barrierDismissible: false, builder: (context) => LoadingDialog(LoadingDialogController()));
      model.getTemplateDetail(
        onSuccess: (state) {
          Navigator.of(
            context,
          ).pop();
        },
        onFailed: (error) {
          Navigator.of(
            context,
          ).pop();
          showCommonRequestErrorDialog(ref, context, error);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    TemplateDetailScreenViewModel model = ref.read(widget.provider.notifier);
    TemplateDetailScreenModelState modelState = ref.watch(widget.provider);
    Orientation? orientation = ref.watch(globalOrientationProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("模板详情"),
        actions: [
          IconButton(
              onPressed: () {
                showHoohDialog(context: context, barrierDismissible: false, builder: (context) => LoadingDialog(LoadingDialogController()));
                model.saveTemplate(
                  onSuccess: (state) {
                    Navigator.of(
                      context,
                    ).pop();
                    showSnackBar(context, "已保存");
                  },
                  onFailed: (error) {
                    Navigator.of(
                      context,
                    ).pop();
                    showCommonRequestErrorDialog(ref, context, error);
                  },
                );
              },
              icon: Icon(
                Icons.save_rounded,
                color: designColors.dark_01.auto(ref),
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            switch (orientation) {
              case Orientation.landscape:
                return CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            height: 24,
                          ),
                          Row(
                            children: [
                              Text(
                                "基本信息",
                                style: TextStyle(fontSize: 18, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 300,
                                child: buildTemplateInfo(),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          Row(
                            children: [
                              Text(
                                "标签",
                                style: TextStyle(fontSize: 18, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [Expanded(child: buildInputField())],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          buildTemplateTags(),
                          SizedBox(
                            height: 48,
                          ),
                        ],
                      ),
                    )
                  ],
                );
              default:
                return CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            height: 24,
                          ),
                          Row(
                            children: [
                              Text(
                                "基本信息",
                                style: TextStyle(fontSize: 18, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          buildTemplateInfo(),
                          SizedBox(
                            height: 24,
                          ),
                          Row(
                            children: [
                              Text(
                                "标签",
                                style: TextStyle(fontSize: 18, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [Expanded(child: buildInputField())],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          buildTemplateTags(),
                          SizedBox(
                            height: 48,
                          ),
                        ],
                      ),
                    )
                  ],
                );
            }
          },
        ),
      ),
    );
  }

  Widget buildInputField() {
    TemplateDetailScreenViewModel model = ref.read(widget.provider.notifier);
    return TextField(
      controller: tagController,
      focusNode: tagNode,
      style: TextStyle(color: designColors.dark_01.auto(ref)),
      decoration:
          RegisterStyles.commonInputDecoration("请输入", ref).copyWith(hintText: "添加标签，按回车键确认", hintStyle: TextStyle(color: designColors.dark_03.auto(ref))),
      onSubmitted: (value) {
        tagController.text = "";
        tagNode.requestFocus();
        String tag = value.trim();
        if (tag.isEmpty) {
          return;
        }
        model.addTag(
          tag,
          onDuplicated: () {
            showSnackBar(context, "标签已存在");
          },
        );
      },
    );
  }

  Widget buildTemplateTags() {
    TemplateDetailScreenViewModel model = ref.read(widget.provider.notifier);
    TemplateDetailScreenModelState modelState = ref.watch(widget.provider);
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: modelState.newTags
          .map((e) => AddTagView(
              tagName: e,
              onDelete: (name) {
                model.removeTag(name);
              }))
          .toList(),
    );
  }

  Widget buildTemplateInfo() {
    TemplateDetailScreenModelState modelState = ref.watch(widget.provider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(aspectRatio: 1, child: HoohImage(imageUrl: modelState.template?.imageUrl ?? "")),
        SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Expanded(
                child: Text(
              "作者昵称：${modelState.template?.author?.name}",
              style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref)),
            ))
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Expanded(
                child: Text(
              "作者用户名：${modelState.template?.author?.username}",
              style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref)),
            ))
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          children: [Expanded(child: Text("tag数：${modelState.newTags.length}", style: TextStyle(fontSize: 12, color: designColors.dark_01.auto(ref))))],
        ),
      ],
    );
  }
}

class AddTagView extends ConsumerWidget {
  final String tagName;
  final Function(String name) onDelete;

  const AddTagView({
    required this.tagName,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Chip(
      backgroundColor: designColors.light_02.auto(ref),
      label: Text(
        "# $tagName",
        style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref)),
      ),
      deleteIcon: Icon(
        Icons.clear_rounded,
        size: 16,
        color: designColors.dark_01.auto(ref),
      ),
      onDeleted: () {
        onDelete(tagName);
      },
    );
  }
}
