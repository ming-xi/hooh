import 'package:app/global.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/user.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LikesPage extends ConsumerStatefulWidget {
  final List<User> users;

  const LikesPage({
    required this.users,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _LikesPageState();
}

class _LikesPageState extends ConsumerState<LikesPage> {
  @override
  Widget build(BuildContext context) {
    double avatarSize = 40;
    return Visibility(
      visible: widget.users.isNotEmpty,
      replacement: buildEmptyView(),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: avatarSize,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) => AvatarView.fromUser(widget.users[index], size: avatarSize),
        itemCount: widget.users.length,
      ),
    );
  }

  Widget buildEmptyView() {
    return MainStyles.buildEmptyView(
      ref: ref,
      text: globalLocalizations.post_detail_likes_empty_hint,
    );
  }
}
