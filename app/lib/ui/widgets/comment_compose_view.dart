import 'package:app/ui/widgets/comment_compose_view_model.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CommentComposeView extends ConsumerStatefulWidget {
  final StateNotifierProvider<CommentComposeWidgetViewModel, CommentComposeWidgetModelState> provider;

  const CommentComposeView({
    required this.provider,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _CommentComposeViewState();
}

class _CommentComposeViewState extends ConsumerState<CommentComposeView> {
  @override
  Widget build(BuildContext context) {
    CommentComposeWidgetModelState modelState = ref.watch(widget.provider);
    CommentComposeWidgetViewModel model = ref.read(widget.provider.notifier);
    return Container(
      color: designColors.light_01.auto(ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: designColors.light_02.auto(ref), borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  maxLines: 5,
                  minLines: 1,
                  style: TextStyle(color: designColors.dark_01.auto(ref), fontSize: 12),
                  decoration: InputDecoration(
                    hintText: "say something",
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    isDense: true,
                    hintStyle: TextStyle(color: designColors.light_06.auto(ref), fontSize: 12),
                    border: InputBorder.none,
                    // border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 2,
            ),
            buildButton(assetPath: "assets/images/icon_post_like.svg", checked: modelState.liked, onPress: (newState) {}),
            SizedBox(
              width: 2,
            ),
            buildButton(assetPath: "assets/images/icon_post_favorite.svg", checked: modelState.favorited, onPress: (newState) {}),
            SizedBox(
              width: 2,
            ),
            buildButton(assetPath: "assets/images/icon_post_share.svg", checked: false, onPress: (newState) {}),
          ],
        ),
      ),
    );
  }

  Widget buildButton({required String assetPath, required bool checked, required void Function(bool) onPress}) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: designColors.light_02.auto(ref)),
          child: InkWell(
            onTap: () {
              onPress(!checked);
            },
            borderRadius: BorderRadius.circular(10),
            child: Center(
              child: HoohIcon(
                assetPath,
                width: 24,
                height: 24,
                color: checked ? designColors.feiyu_blue.auto(ref) : designColors.light_06.auto(ref),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
