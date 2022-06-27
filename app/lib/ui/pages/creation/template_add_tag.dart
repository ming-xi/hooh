import 'dart:io';

import 'package:app/extensions/extensions.dart';
import 'package:app/global.dart';
import 'package:app/ui/pages/creation/template_add_tag_view_model.dart';
import 'package:app/ui/pages/creation/template_done.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/template_text_setting_view.dart';
import 'package:app/ui/widgets/template_text_setting_view_model.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TemplateAddTagScreen extends ConsumerStatefulWidget {
  final File? imageFile;
  final StateNotifierProvider<TemplateAddTagPageViewModel, TemplateAddTagPageModelState> provider = StateNotifierProvider((ref) {
    return TemplateAddTagPageViewModel(TemplateAddTagPageModelState.init());
  });
  final StateNotifierProvider<TemplateTextSettingViewModel, TemplateTextSettingModelState> textSettingProvider;

  TemplateAddTagScreen({
    this.imageFile,
    required this.textSettingProvider,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TemplateAddTagScreenState();
}

class _TemplateAddTagScreenState extends ConsumerState<TemplateAddTagScreen> with TickerProviderStateMixin {
  TextEditingController controller = TextEditingController();
  FocusNode listenerNode = FocusNode();
  FocusNode inputNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TemplateAddTagPageModelState modelState = ref.watch(widget.provider);
    TemplateAddTagPageViewModel model = ref.read(widget.provider.notifier);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        hideKeyboard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(globalLocalizations.template_add_tag_title),
        ),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
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
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 6),
                    child: Text(
                      globalLocalizations.template_add_tag_description,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref)),
                    ),
                  ),
                  Container(
                    color: designColors.light_02.auto(ref),
                    child: RawKeyboardListener(
                      focusNode: listenerNode,
                      onKey: (event) {
                        if (event.logicalKey == LogicalKeyboardKey.enter) {
                          addTag(model, controller.text);
                          controller.text = "";
                          inputNode.requestFocus();
                        }
                      },
                      child: TextField(
                        focusNode: inputNode,
                        controller: controller,
                        maxLines: 3,
                        minLines: 1,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textInputAction: TextInputAction.done,
                        // onSubmitted: (text) {
                        //   model.addTag(text);
                        //   controller.text = "";
                        // },
                        onEditingComplete: () {
                          addTag(model, controller.text);
                          controller.text = "";
                        },
                        inputFormatters: [LengthLimitingTextInputFormatter(200), FilteringTextInputFormatter.deny(RegExp("\n"))],
                        style: TextStyle(fontSize: 14, color: designColors.light_06.auto(ref)),
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 20.0, right: 8, top: 4),
                            child: Text(
                              "#",
                              style: TextStyle(fontSize: 14, color: designColors.light_06.auto(ref)),
                            ),
                          ),
                          prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                          contentPadding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 6),
                          hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 0),
                          child: Wrap(
                            spacing: 0,
                            runSpacing: 0,
                            children: modelState.tags.map((e) => buildTagClip(e, model)).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(48),
                          child: MainStyles.gradientButton(
                              ref,
                              "OK",
                              modelState.uploading
                                  ? null
                                  : () {
                                      hideKeyboard();
                                      Toast.showSnackBar(context, globalLocalizations.common_uploading);
                                      TemplateTextSettingModelState textSettingState = ref.read(widget.textSettingProvider);
                                      model.saveTemplate(
                                          frameX: textSettingState.frameX,
                                          frameY: textSettingState.frameY,
                                          frameWidth: textSettingState.frameW,
                                          frameHeight: textSettingState.frameH,
                                          imageFile: widget.imageFile!,
                                          textColor: textSettingState.textColor.toHex(),
                                          onSuccess: (template) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => TemplateDoneScreen(
                                                          imageFile: widget.imageFile,
                                                        )));
                                          },
                                          onError: (msg) {
                                            // Toast.showSnackBar(context, msg);
                                            showCommonRequestErrorDialog(ref, context, msg);
                                          });
                                    }),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void addTag(TemplateAddTagPageViewModel model, String text) {
    model.addTag(
      text,
      onDuplicateTagAdded: (tag) {
        Toast.showSnackBar(context, globalLocalizations.select_topic_duplicated_tag);
      },
    );
  }

  Widget buildTagClip(String tag, TemplateAddTagPageViewModel model) {
    return Chip(
      backgroundColor: Colors.transparent,
      label: Text(
        "# $tag",
        style: TextStyle(
          fontSize: 14,
          color: designColors.dark_01.auto(ref),
        ),
        overflow: TextOverflow.ellipsis,
      ),
      deleteIcon: Icon(
        Icons.cancel,
        size: 14,
        color: designColors.feiyu_blue.auto(ref),
      ),
      onDeleted: () {
        model.deleteTag(tag);
      },
    );
  }
}
