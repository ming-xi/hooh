import 'dart:convert';
import 'dart:math';

import 'package:app/global.dart';
import 'package:app/ui/pages/creation/select_topic_view_model.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sprintf/sprintf.dart';

class SelectTopicScreen extends ConsumerStatefulWidget {
  late final StateNotifierProvider<SelectTopicScreenViewModel, SelectTopicScreenModelState> provider;

  SelectTopicScreen({
    List<String>? selectedTags,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return SelectTopicScreenViewModel(SelectTopicScreenModelState.init(selectedTags));
    });
  }

  @override
  ConsumerState createState() => _SelectTopicScreenState();
}

class _SelectTopicScreenState extends ConsumerState<SelectTopicScreen> {
  TextEditingController controller = TextEditingController();
  FocusNode listenerNode = FocusNode();
  FocusNode inputNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    SelectTopicScreenModelState modelState = ref.watch(widget.provider);
    SelectTopicScreenViewModel model = ref.read(widget.provider.notifier);
    List<String> unselectedRecommendedTags = [...modelState.recommendedTags]..removeWhere((element) => modelState.userTags.contains(element));
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        hideKeyboard();
      },
      child: Scaffold(
        appBar: HoohAppBar(
          title: Text(globalLocalizations.select_topic_title),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context, modelState.userTags);
                },
                icon: HoohIcon(
                  "assets/images/icon_ok.svg",
                  width: 24,
                  height: 24,
                  color: designColors.dark_01.auto(ref),
                ))
          ],
          hoohLeading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: HoohIcon(
                "assets/images/icon_no.svg",
                width: 24,
                height: 24,
                color: designColors.dark_01.auto(ref),
              )),
        ),
        body: Column(
          children: [
            Container(
              color: designColors.light_02.auto(ref),
              child: RawKeyboardListener(
                focusNode: listenerNode,
                onKey: (event) {
                  if (event.logicalKey == LogicalKeyboardKey.enter) {
                    addTag(controller.text);
                    controller.text = "";
                    inputNode.requestFocus();
                  }
                },
                child: TextField(
                  controller: controller,
                  focusNode: inputNode,
                  maxLines: 1,
                  minLines: 1,

                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  textInputAction: TextInputAction.done,
                  // onSubmitted: (text) {
                  //   addTag(text);
                  //   controller.text = "";
                  // },
                  onEditingComplete: () {
                    addTag(controller.text);
                    controller.text = "";
                  },
                  // buildCounter: (
                  //     context, {required currentLength,required isFocused, maxLength }) {
                  //   int utf8Length = utf8.encode(controller.text).length;
                  //   return Container(
                  //     child: Text(
                  //       '$utf8Length/$maxLength',
                  //       style: Theme.of(context).textTheme.caption,
                  //     ),
                  //   );
                  // },

                  inputFormatters: [LengthLimitingTextInputFormatter(24), FilteringTextInputFormatter.deny(RegExp("\n"))],
                  // inputFormatters: [_Utf8LengthLimitingTextInputFormatter(4), FilteringTextInputFormatter.deny(RegExp("\n"))],
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
                  child: Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: designColors.light_02.auto(ref), width: 1))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        spacing: 0,
                        runSpacing: -20,
                        children: modelState.userTags.map((e) => buildTagClip(e, model)).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  String tag = unselectedRecommendedTags[index];
                  return ListTile(
                    visualDensity: VisualDensity(vertical: VisualDensity.minimumDensity),
                    title: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        "# $tag",
                        style: TextStyle(color: designColors.light_06.auto(ref), fontSize: 14),
                      ),
                    ),
                    onTap: () {
                      addTag(tag);
                    },
                  );
                },
                itemCount: unselectedRecommendedTags.length,
              ),
            )
          ],
        ),
      ),
    );
  }

  void addTag(String tag) {
    SelectTopicScreenModelState modelState = ref.read(widget.provider);
    if (modelState.userTags.length >= SelectTopicScreenViewModel.MAX_SELECTED_TAGS) {
      Toast.showSnackBar(context, sprintf(globalLocalizations.select_topic_reach_max_tag_limit, [SelectTopicScreenViewModel.MAX_SELECTED_TAGS]));
      return;
    }
    SelectTopicScreenViewModel model = ref.read(widget.provider.notifier);
    model.addTag(
      tag,
      onDuplicateTagAdded: (tag) {
        Toast.showSnackBar(context, globalLocalizations.select_topic_duplicated_tag);
      },
    );
  }

  Widget buildTagClip(String tag, SelectTopicScreenViewModel model) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "# $tag",
          style: TextStyle(
            fontSize: 14,
            color: designColors.dark_01.auto(ref),
          ),
        ),
        IconButton(
          onPressed: () {
            model.deleteTag(tag);
          },
          icon: HoohIcon(
            "assets/images/icon_delete_tag.svg",
            width: 16,
            height: 16,
            color: designColors.feiyu_blue.auto(ref),
          ),
          splashRadius: 16,
        )
      ],
    );
  }
}

class _Utf8LengthLimitingTextInputFormatter extends TextInputFormatter {
  _Utf8LengthLimitingTextInputFormatter(this.maxLength) : assert(maxLength == null || maxLength == -1 || maxLength > 0);

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (maxLength != null && maxLength > 0 && bytesLength(newValue.text) > maxLength) {
      // If already at the maximum and tried to enter even more, keep the old value.
      if (bytesLength(oldValue.text) == maxLength) {
        return oldValue;
      }
      return truncate(newValue, maxLength);
    }
    return newValue;
  }

  static TextEditingValue truncate(TextEditingValue value, int maxLength) {
    var newValue = '';
    if (bytesLength(value.text) > maxLength) {
      var length = 0;

      value.text.characters.takeWhile((char) {
        var nbBytes = bytesLength(char);
        if (length + nbBytes <= maxLength) {
          newValue += char;
          length += nbBytes;
          return true;
        }
        return false;
      });
    }
    return TextEditingValue(
      text: newValue,
      selection: value.selection.copyWith(
        baseOffset: min(value.selection.start, newValue.length),
        extentOffset: min(value.selection.end, newValue.length),
      ),
      composing: TextRange.empty,
    );
  }

  static int bytesLength(String value) {
    return utf8.encode(value).length;
  }
}
