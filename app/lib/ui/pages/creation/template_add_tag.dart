import 'dart:io';

import 'package:app/ui/pages/creation/template_add_tag_view_model.dart';
import 'package:app/utils/design_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TemplateAddTagScreen extends ConsumerStatefulWidget {
  final File? imageFile;
  final StateNotifierProvider<TemplateAddTagPageViewModel, TemplateAddTagPageModelState> provider = StateNotifierProvider((ref) {
    return TemplateAddTagPageViewModel(TemplateAddTagPageModelState.init());
  });

  TemplateAddTagScreen({
    this.imageFile,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TemplateAddTagScreenState();
}

class _TemplateAddTagScreenState extends ConsumerState<TemplateAddTagScreen> with TickerProviderStateMixin {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TemplateAddTagPageModelState modelState = ref.watch(widget.provider);
    TemplateAddTagPageViewModel model = ref.watch(widget.provider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text("add tag"),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                AspectRatio(
                  child: widget.imageFile == null ? Placeholder() : Image.file(widget.imageFile!),
                  aspectRatio: 1,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 6),
                  child: Text(
                    "Tag photos for easier search and reference",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref)),
                  ),
                ),
                Container(
                  color: designColors.light_02.auto(ref),
                  child: TextField(
                    controller: controller,
                    maxLines: 3,
                    minLines: 1,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    textInputAction: TextInputAction.done,
                    maxLength: 100,
                    onSubmitted: (text) {
                      model.addTag(text);
                      controller.text = "";
                    },
                    decoration: InputDecoration(
                      prefixText: "# ",
                      contentPadding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 6),
                      hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children: modelState.tags.map((e) => buildTagClip(e, model)).toList(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildTagClip(String tag, TemplateAddTagPageViewModel model) {
    return Chip(
      label: Text(
        tag,
        style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref)),
      ),
      deleteIcon: Icon(
        Icons.cancel,
        color: designColors.feiyu_blue.auto(ref),
      ),
      onDeleted: () {
        model.deleteTag(tag);
      },
    );
  }
}
