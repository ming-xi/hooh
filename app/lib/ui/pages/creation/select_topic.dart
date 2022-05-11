import 'package:app/ui/pages/creation/select_topic_view_model.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

  @override
  Widget build(BuildContext context) {
    SelectTopicScreenModelState modelState = ref.watch(widget.provider);
    SelectTopicScreenViewModel model = ref.read(widget.provider.notifier);
    List<String> unselectedRecommendedTags = [...modelState.recommendedTags]..removeWhere((element) => modelState.userTags.contains(element));
    return Scaffold(
      appBar: AppBar(
        title: Text("Topics"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context, modelState.userTags);
              },
              icon: Icon(Icons.done_rounded))
        ],
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.clear_rounded)),
      ),
      body: Column(
        children: [
          Container(
            color: designColors.light_02.auto(ref),
            child: TextField(
              controller: controller,
              maxLines: 3,
              minLines: 1,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              textInputAction: TextInputAction.done,
              onSubmitted: (text) {
                addTag(text);
                controller.text = "";
              },
              // onEditingComplete: () {
              //   // keep keyboard open
              // },
              inputFormatters: [LengthLimitingTextInputFormatter(24), FilteringTextInputFormatter.deny(RegExp("\n"))],
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
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: designColors.light_02.auto(ref), width: 1))),
                  child: Wrap(
                    spacing: 0,
                    runSpacing: 0,
                    children: modelState.userTags.map((e) => buildTagClip(e, model)).toList(),
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
    );
  }

  void addTag(String tag) {
    SelectTopicScreenModelState modelState = ref.read(widget.provider);
    if (modelState.userTags.length >= SelectTopicScreenViewModel.MAX_SELECTED_TAGS) {
      Toast.showSnackBar(context, "max tag count is ${SelectTopicScreenViewModel.MAX_SELECTED_TAGS}");
      return;
    }
    SelectTopicScreenViewModel model = ref.read(widget.provider.notifier);
    model.addTag(tag);
  }

  Widget buildTagClip(String tag, SelectTopicScreenViewModel model) {
    return Chip(
      backgroundColor: Colors.transparent,
      label: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          "# $tag",
          style: TextStyle(
            fontSize: 14,
            color: designColors.dark_01.auto(ref),
          ),
        ),
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
