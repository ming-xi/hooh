import 'package:app/global.dart';
import 'package:app/ui/pages/user/register/start.dart';
import 'package:app/ui/widgets/comment_compose_view_model.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/post_comment.dart';
import 'package:common/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sprintf/sprintf.dart';

class CommentComposeView extends ConsumerStatefulWidget {
  final StateNotifierProvider<CommentComposeWidgetViewModel, CommentComposeWidgetModelState> provider;
  final FocusNode textFieldNode;
  final void Function(bool newState, void Function(HoohApiErrorResponse error)? onError)? onLikePress;
  final void Function(bool newState, void Function(HoohApiErrorResponse error)? onError)? onFavoritePress;
  final void Function()? onSharePress;
  final void Function(PostComment? repliedComment, String text, void Function()? onComplete, void Function(HoohApiErrorResponse error)? onError) onSendPress;

  const CommentComposeView({
    required this.provider,
    required this.textFieldNode,
    this.onLikePress,
    this.onFavoritePress,
    this.onSharePress,
    required this.onSendPress,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _CommentComposeViewState();
}

class _CommentComposeViewState extends ConsumerState<CommentComposeView> {
  FocusNode listenerNode = FocusNode();
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CommentComposeWidgetModelState modelState = ref.watch(widget.provider);
    CommentComposeWidgetViewModel model = ref.read(widget.provider.notifier);
    debugPrint("modelState.replyingComment=${modelState.replyingComment}");
    return Container(
      color: designColors.light_01.auto(ref),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: designColors.light_02.auto(ref), borderRadius: BorderRadius.circular(10)),
                  child: RawKeyboardListener(
                    focusNode: listenerNode,
                    onKey: (event) {
                      if (event.logicalKey == LogicalKeyboardKey.backspace) {
                        if (controller.text.isEmpty) {
                          model.setRepliedComment(null);
                        }
                      }
                    },
                    child: TextField(
                      focusNode: widget.textFieldNode,
                      controller: controller,
                      maxLines: 5,
                      minLines: 1,
                      maxLength: 1000,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                        return null;
                      },
                      textInputAction: TextInputAction.send,
                      onEditingComplete: () {
                        widget.onSendPress(modelState.replyingComment, controller.text.trim(), () {
                          controller.text = "";
                          model.setRepliedComment(null);
                        }, (error) {
                          // Toast.show(context: context, message: errorMsg);
                          showCommonRequestErrorDialog(ref, context, error);
                        });
                      },
                      style: TextStyle(color: designColors.dark_01.auto(ref), fontSize: 12),
                      decoration: InputDecoration(
                        hintText: modelState.replyingComment == null
                            ? globalLocalizations.post_detail_comment_say_something
                            : sprintf(globalLocalizations.post_detail_comment_reply_to, [modelState.replyingComment!.author.name]),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        isDense: true,
                        hintStyle: TextStyle(color: designColors.light_06.auto(ref), fontSize: 12),
                        border: InputBorder.none,
                        // border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 2,
              ),
              buildButton(assetPath: "assets/images/icon_post_like.svg", checked: modelState.liked, onPress: widget.onLikePress),
              SizedBox(
                width: 2,
              ),
              buildButton(
                  assetPath: "assets/images/icon_post_favorite.svg",
                  checked: modelState.favorited,
                  onPress: (newState, callback) {
                    User? user = ref.read(globalUserInfoProvider);
                    if (user == null) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
                      return;
                    }
                    if (widget.onFavoritePress != null) {
                      widget.onFavoritePress!(newState, callback);
                    }
                  }),
              SizedBox(
                width: 2,
              ),
              buildButton(
                  assetPath: "assets/images/icon_post_share.svg",
                  checked: false,
                  onPress: (_, e) {
                    if (widget.onSharePress != null) {
                      widget.onSharePress!();
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(
      {required String assetPath, required bool checked, required void Function(bool, void Function(HoohApiErrorResponse error)? onError)? onPress}) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: designColors.light_02.auto(ref)),
          child: InkWell(
            onTap: () {
              if (onPress != null) {
                onPress(!checked, (error) {
                  // Toast.show(context: context, message: errorMsg);
                  showCommonRequestErrorDialog(ref, context, error);
                });
              }
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
