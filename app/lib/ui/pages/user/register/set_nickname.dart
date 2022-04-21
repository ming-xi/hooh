import 'package:app/ui/pages/user/register/verify_code_view_model.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetNicknameScreen extends ConsumerStatefulWidget {

  SetNicknameScreen({
    Key? key,
  }) : super(key: key) {
    // provider = StateNotifierProvider((ref) {
    //   return VerifyCodeViewModel(VerifyCodeModelState.init(countryCode,phoneNumber));
    // });
  }

  @override
  ConsumerState createState() => _SetNicknameScreenState();
}

class _SetNicknameScreenState extends ConsumerState<SetNicknameScreen> {
  TextEditingController nicknameController = TextEditingController();
  FocusNode nicknameNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick a nickname"),
        automaticallyImplyLeading: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nicknameController, focusNode: nicknameNode, decoration: InputDecoration(label: Text("Enter your name"), hintText: "Maximum 10 characters")),
                SizedBox(
                  height: 36,
                ),
                TextButton(
                    onPressed: () {
                      String nickname = nicknameController.text;
                      // network.requestAsync<LoginResponse>(network.register(widget.token, password), (data) {
                      //   network.setUserToken(data.jwtResponse.accessToken);
                      //   preferences.putInt(Preferences.keyUserRegisterStep, 0);
                      //   debugPrint("success");
                      // }, (error) => null);
                    },
                    child: Text("Confirm"))
              ],
            ),
          )
        ],
      ),
    );
  }
}
