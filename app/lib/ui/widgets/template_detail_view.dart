import 'package:app/global.dart';
import 'package:app/ui/pages/creation/edit_post.dart';
import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/ui/pages/user/register/start.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/template_detail_view_model.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:blur/blur.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/template.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TemplateDetailBottomSheet extends ConsumerStatefulWidget {
  late final StateNotifierProvider<TemplateDetailViewModel, TemplateDetailModelState> provider;

  TemplateDetailBottomSheet({
    required Template template,
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return TemplateDetailViewModel(TemplateDetailModelState.init(template));
    });
  }

  @override
  ConsumerState createState() => _TemplateDetailBottomSheetState();
}

class _TemplateDetailBottomSheetState extends ConsumerState<TemplateDetailBottomSheet> {
  @override
  Widget build(BuildContext context) {
    TemplateDetailModelState modelState = ref.watch(widget.provider);

    return ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        child: TemplateDetailView(
          template: modelState.template,
          type: TemplateDetailView.TYPE_DIALOG,
          onFavorite: _callback,
          onFollow: _callback,
        ));
  }

  void _callback(Template template, HoohApiErrorResponse? e) {
    TemplateDetailViewModel model = ref.read(widget.provider.notifier);
    if (e == null) {
      model.updateTemplateData(template);
    } else {
      Toast.showSnackBar(context, e.devMessage);
    }
  }
}

class TemplateDetailView extends ConsumerStatefulWidget {
  static void showTemplateDialog(BuildContext context, WidgetRef ref, Template template) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          // return BackdropFilter(
          //     filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          //     child: clipRRect);
          return TemplateDetailBottomSheet(template: template);
        });
  }

  static const TYPE_FEEDS = 0;
  static const TYPE_DIALOG = 1;

  final Template template;
  final int type;

  final Function(Template template, HoohApiErrorResponse? error)? onFollow;
  final Function(Template template, HoohApiErrorResponse? error)? onFavorite;

  const TemplateDetailView({
    required this.template,
    required this.type,
    this.onFollow,
    this.onFavorite,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TemplateDetailViewState();
}

class _TemplateDetailViewState extends ConsumerState<TemplateDetailView> {
  @override
  Widget build(BuildContext context) {
    Template template = widget.template;

    List<Positioned> children = [
      Positioned.fill(child: HoohImage(imageUrl: template.imageUrl)),
      Positioned(
          bottom: 12,
          left: 12,
          child: buildFavoriteButton(template, onClick: (template) {
            User? user = ref.read(globalUserInfoProvider);
            if (user == null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
              return;
            }
            onFavoritePress(template);
          })),
      Positioned(
          bottom: 12,
          right: 12,
          child: buildCreateButton(template, onClick: (template) {
            User? user = ref.read(globalUserInfoProvider);
            if (user == null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
              return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditPostScreen(setting: PostImageSetting.withTemplate(template, text: ""))));
          })),
    ];
    User? user = ref.read(globalUserInfoProvider);
    if (user != null && widget.type == TemplateDetailView.TYPE_FEEDS) {
      // already login
      if (template.author!.id == user.id) {
        children.add(Positioned(top: 12, right: 12, child: buildMenuButton(template)));
      }
    }
    var column = Container(
      color: designColors.light_01.auto(ref),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: children,
              ),
            ),
            Material(
              // padding: const EdgeInsets.only( top: 16, bottom: 20),

              child: Builder(builder: (context) {
                List<Widget> widgets = [];
                widgets.add(buildUserInfoRow(template));
                widgets.add(SizedBox(
                  height: 12,
                ));
                widgets.add(buildButtons(template));
                return Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  // padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widgets,
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
    if (widget.type == TemplateDetailView.TYPE_FEEDS) {
      return Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Color(0x0C000000), offset: Offset(0, 8), blurRadius: 24)]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: column,
        ),
      );
    } else {
      return column;
    }
  }

  Widget buildFavoriteButton(Template template, {Function(Template template)? onClick}) {
    return buildButtonBackground(
        width: 36,
        onClick: onClick,
        Center(
          child: HoohIcon(
            "assets/images/icon_template_bookmark_on.png",
            width: 16,
            color: template.favorited ? null : designColors.dark_01.auto(ref),
          ),
        ));
  }

  Widget buildMenuButton(Template template, {Function(Template template)? onClick}) {
    return buildButtonBackground(
        width: 36,
        onClick: onClick,
        Center(
          child: Icon(
            Icons.more_horiz_rounded,
            color: designColors.dark_01.auto(ref),
          ),
        ));
  }

  Widget buildCreateButton(Template template, {Function(Template template)? onClick}) {
    return buildButtonBackground(
        onClick: onClick,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                globalLocalizations.template_detail_use_this_template,
                style: TextStyle(fontSize: 14, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 6,
              ),
              HoohIcon(
                "assets/images/icon_template_create.svg",
                width: 19,
                height: 19,
                color: designColors.dark_01.auto(ref),
              ),
            ],
          ),
        ));
  }

  Widget buildButtonBackground(Widget child, {double? width, Function(Template template)? onClick}) {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        width: width,
        height: 36,
        // decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: designColors.light_01.auto(ref).withOpacity(0.5)),
        child: InkWell(
          onTap: () {
            if (onClick != null) {
              onClick(widget.template);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    ).frosted(
      blur: 4,
      borderRadius: BorderRadius.circular(12),
      frostColor: designColors.light_01.auto(ref).withOpacity(0.5),
    );
  }

  Builder buildButtons(Template template) {
    return Builder(builder: (context) {
      List<Widget> widgets = [
        HoohIcon(
          "assets/images/common_ore.svg",
          width: 24,
          height: 24,
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          formatCurrency(template.profitInt),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref)),
        ),
        Spacer(),
        ...buildTitleAndAmount(globalLocalizations.template_detail_favorite_count, template.favoriteCount),
        SizedBox(
          width: 8,
        ),
        ...buildTitleAndAmount(globalLocalizations.template_detail_use_count, template.useCount),
      ];
      return Padding(
        padding: const EdgeInsets.only(left: 20, right: 8, bottom: 16),
        child: Row(
          children: widgets,
        ),
      );
    });
  }

  List<Widget> buildTitleAndAmount(String title, int amount) {
    return [
      Text(
        title,
        style: TextStyle(fontSize: 12, color: designColors.dark_03.auto(ref)),
      ),
      SizedBox(
        width: 6,
      ),
      SizedBox(
          width: 32,
          child: Text(
            formatAmount(amount),
            style: TextStyle(fontSize: 12, color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold),
          )),
    ];
  }

  Widget buildUserInfoRow(Template template) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Builder(builder: (context) {
        List<Widget> widgets = buildUserInfo(template);
        widgets.add(SizedBox(
          width: 8,
        ));
        Widget? followButton = buildFollowButton(template);
        if (followButton != null) {
          widgets.add(followButton);
        } else {
          widgets.add(SizedBox(
            height: 40,
          ));
        }
        return Row(
          children: widgets,
        );
      }),
    );
  }

  List<Widget> buildUserInfo(Template template) {
    User author = template.author!;
    return [
      AvatarView.fromUser(author, size: 32),
      // HoohImage(
      //   imageUrl: author.avatarUrl!,
      //   cornerRadius: 100,
      //   width: 32,
      //   height: 32,
      // ),
      SizedBox(
        width: 8,
      ),
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              author.name,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: designColors.dark_00.auto(ref)),
            ),
            Text(
              DateUtil.getZonedDateString(template.createdAt!),
              style: TextStyle(fontSize: 10, color: designColors.light_06.auto(ref)),
            ),
          ],
        ),
      ),
    ];
  }

  Widget? buildFollowButton(Template template) {
    User? user = ref.watch(globalUserInfoProvider.state).state;
    User author = template.author!;
    if ((author.followed ?? false) || (user?.id == author.id)) {
      return null;
    }
    return _buildButton(
        text: Text(
          globalLocalizations.common_follow,
          style: TextStyle(fontFamily: 'Linotte'),
        ),
        isEnabled: true,
        onPress: () {
          User? user = ref.read(globalUserInfoProvider);
          if (user == null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
            return;
          }
          onFollowPress(template);
        });
  }

  void onFollowPress(Template template) {
    if (template.author!.followed ?? false) {
      return;
    }
    network.requestAsync<void>(network.followUser(template.author!.id), (data) {
      template.author!.followed = true;
      if (widget.onFollow != null) {
        widget.onFollow!(template, null);
      }
    }, (error) {
      if (widget.onFollow != null) {
        widget.onFollow!(template, error);
      }
    });
  }

  void onFavoritePress(Template template) {
    Future<void> request;
    if (template.favorited) {
      request = network.cancelFavoriteTemplate(template.id);
    } else {
      request = network.favoriteTemplate(template.id);
    }
    network.requestAsync<void>(request, (data) {
      template.favorited = !template.favorited;
      if (widget.onFavorite != null) {
        widget.onFavorite!(template, null);
      }
    }, (error) {
      if (widget.onFavorite != null) {
        widget.onFavorite!(template, error);
      }
    });
  }

  Widget _buildButton({required Widget text, required bool isEnabled, required Function() onPress}) {
    ButtonStyle style = RegisterStyles.blueButtonStyle(ref, cornerRadius: 14).copyWith(
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        // fixedSize: MaterialStateProperty.all(Size(120,24)),
        minimumSize: MaterialStateProperty.all(Size(120, 40)),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap);
    if (!isEnabled) {
      style = style.copyWith(backgroundColor: MaterialStateProperty.all(designColors.dark_03.auto(ref)));
    }
    return TextButton(
      onPressed: onPress,
      child: text,
      style: style,
    );
  }
}
