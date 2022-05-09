import 'package:app/providers.dart';
import 'package:app/ui/pages/user/register/login.dart';
import 'package:app/ui/pages/user/register/register.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MePage extends ConsumerStatefulWidget {
  const MePage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _MePageState();
}

class _MePageState extends ConsumerState<MePage> {
  @override
  Widget build(BuildContext context) {
    User? user = ref.watch(globalUserInfoProvider.state).state;
    return user == null ? GuestPage() : UserCenterPage(user);
  }
}

class GuestPage extends ConsumerWidget {
  const GuestPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.yellow.withAlpha(100),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("not login"),
              SizedBox(
                height: 24,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                  },
                  style: RegisterStyles.blackButtonStyle(ref),
                  child: const Text('Sign Up')),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: const Text('Or Login'),
                style: RegisterStyles.blackOutlineButtonStyle(ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserCenterPage extends ConsumerStatefulWidget {
  final User user;

  const UserCenterPage(
    this.user, {
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _UserCenterPageState();
}

class _UserCenterPageState extends ConsumerState<UserCenterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.user.name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref)),
            ),
            Text(
              widget.user.username ?? "",
              style: TextStyle(fontSize: 12, color: designColors.light_06.auto(ref)),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: HoohIcon(
                "assets/images/icon_me_message.svg",
                width: 24,
                height: 24,
                color: designColors.dark_01.auto(ref),
              ))
        ],
        leading: IconButton(
            onPressed: () {},
            icon: HoohIcon(
              "assets/images/icon_me_setting.svg",
              width: 24,
              height: 24,
              color: designColors.dark_01.auto(ref),
            )),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 17,),
                SizedBox(
                  height: 72,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 24,
                      ),
                      HoohImage(
                        imageUrl: widget.user.avatarUrl ?? "",
                        cornerRadius: 36,
                        width: 72,
                        height: 72,
                      ),
                      const Spacer(),
                      Center(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.me_follower,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref)),
                          ),
                          Text(
                            '30000',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref)),
                          ),
                        ],
                      )),
                      const Spacer(),
                      Center(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.me_following,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref)),
                          ),
                          Text(
                            '30000',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref)),
                          ),
                        ],
                      )),
                      const Spacer(),
                      const SizedBox(
                        width: 17,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20,),
                SizedBox(height: 40,
                child: Row(
                  children: [const SizedBox(width: 20,),
                    Text(
                      AppLocalizations.of(context)!.me_personal_socoal_icon,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref)),
                    )],
                ),)

              ],
            ),
          )
        ],
      ),
    );
  }
}
