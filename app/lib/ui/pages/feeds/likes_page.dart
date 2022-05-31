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
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      gridDelegate:
          SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 40, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1, mainAxisExtent: 40),
      itemBuilder: (context, index) => AvatarView.fromUser(widget.users[index], size: 40),
      itemCount: widget.users.length,
    );
  }
}
