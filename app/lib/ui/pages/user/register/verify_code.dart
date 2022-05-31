import 'package:app/ui/pages/user/register/set_password.dart';
import 'package:app/ui/pages/user/register/verify_code_view_model.dart';
import 'package:app/utils/design_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VerifyCodeScreen extends ConsumerStatefulWidget {
  final int countryCode;
  final String phoneNumber;
  late final StateNotifierProvider<VerifyCodeViewModel, VerifyCodeModelState> provider;

  VerifyCodeScreen(
    this.countryCode,
    this.phoneNumber, {
    Key? key,
  }) : super(key: key) {
    provider = StateNotifierProvider((ref) {
      return VerifyCodeViewModel(VerifyCodeModelState.init(countryCode, phoneNumber));
    });
  }

  @override
  ConsumerState createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends ConsumerState<VerifyCodeScreen> {
  final TapGestureRecognizer _tapGestureRecognizer = TapGestureRecognizer();
  String _code = "";
  int _seconds = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tapGestureRecognizer.dispose();
    // debugPrint("sign up dispose");
  }

  @override
  Widget build(BuildContext context) {
    VerifyCodeViewModel viewModel = ref.read(widget.provider.notifier);
    var modelState = ref.watch(widget.provider);

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
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    autofocus: true,
                    onChanged: (text) {
                      debugPrint(text);
                      if (text.length == 6) {
                        viewModel.validateCode(text, (token) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SetPasswordScreen(token)));
                        });
                      }
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    viewModel.requestValidationCode();
                  },
                  child: modelState.seconds == 0 ? const Text('Send verification code') : const Text('Resend verification code'),
                ),
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                  child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                            color: designColors.feiyu_blue.auto(ref),
                            fontSize: 14,
                          ),
                          text: '${modelState.seconds} ',
                          children: const [
                        TextSpan(
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          text: 'seconds',
                        )
                      ])),
                  visible: !modelState.sendCodeEnable,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
