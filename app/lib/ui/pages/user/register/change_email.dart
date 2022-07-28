import 'package:app/global.dart';
import 'package:app/ui/pages/user/register/bind_email.dart';
import 'package:app/ui/pages/user/register/check_password.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/user.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChangeEmailScreen extends ConsumerStatefulWidget {
  ChangeEmailScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends ConsumerState<ChangeEmailScreen> {
  TextEditingController emailController = TextEditingController();
  FocusNode emailNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      User user = ref.watch(globalUserInfoProvider)!;
      emailController.text = user.email ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint("_ChangeEmailScreenState build");
    User user = ref.watch(globalUserInfoProvider)!;
    BorderRadius radius = BorderRadius.all(Radius.circular(18.0));
    BorderSide borderSide = BorderSide(width: 1, color: designColors.light_02.auto(ref));
    return Scaffold(
      appBar: HoohAppBar(
        // leading: Text("test"),
        title: const Text(""),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                Text(
                  globalLocalizations.change_email_title,
                  style: RegisterStyles.titleTextStyle(ref),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: emailController,
              focusNode: emailNode,
              enabled: false,
              style: RegisterStyles.inputTextStyle(ref),
              decoration: RegisterStyles.commonInputDecoration(
                globalLocalizations.bind_email_hint,
                ref,
              ).copyWith(
                  disabledBorder: OutlineInputBorder(borderSide: borderSide, borderRadius: radius),
                  prefixIcon: SizedBox(
                    width: 36,
                    child: Center(
                      child: HoohIcon(
                        "assets/images/icon_forget_password_email.svg",
                        color: designColors.dark_03.auto(ref),
                        width: 24,
                      ),
                    ),
                  )),
            ),
            Spacer(),
            TextButton(
              style: RegisterStyles.blackButtonStyle(ref),
              onPressed: () {
                Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => CheckPasswordScreen())).then((result) {
                  if (result != null && result) {
                    Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BindEmailScreen(
                                  scene: BindEmailScreen.SCENE_CHANGE,
                                ))).then((result) {
                      if (result != null && result) {
                        Navigator.of(context, rootNavigator: true).pop(true);
                      }
                    });
                  }
                });
              },
              child: Text(globalLocalizations.change_email_button),
            ),
            Spacer()
          ],
        ),
      ),
    );
  }
}
