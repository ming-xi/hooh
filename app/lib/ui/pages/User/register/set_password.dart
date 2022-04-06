import 'package:app/ui/pages/User/register/verify_code_view_model.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetPasswordScreen extends ConsumerStatefulWidget {
  final String token;
  late StateNotifierProvider<VerifyCodeViewModel, VerifyCodeModelState> provider;

  SetPasswordScreen(
    this.token, {
    Key? key,
  }) : super(key: key) {
    // provider = StateNotifierProvider((ref) {
    //   return VerifyCodeViewModel(VerifyCodeModelState.init(countryCode,phoneNumber));
    // });
  }

  @override
  ConsumerState createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmController = TextEditingController();
  FocusNode passwordNode = FocusNode();
  FocusNode confirmNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Verification Code"),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: passwordController,
                    focusNode: passwordNode,
                    decoration: InputDecoration(label: Text("Password"), hintText: "Enter password"),
                    obscureText: true),
                SizedBox(
                  height: 24,
                ),
                TextField(
                    controller: confirmController,
                    focusNode: confirmNode,
                    decoration: InputDecoration(label: Text("Confirm Password"), hintText: "Enter password again"),
                    obscureText: true),
                SizedBox(
                  height: 36,
                ),
                ElevatedButton(
                    onPressed: () {
                      String password = passwordController.text;
                      String confirmedPassword = confirmController.text;
                      if (password != confirmedPassword) {
                        debugPrint("not same password");
                        return;
                      }
                      network.requestAsync<LoginResponse>(network.register(widget.token, password), (data) {
                        network.setUserToken(data.jwtResponse.accessToken);
                        debugPrint("success");
                      }, (error) => null);
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
