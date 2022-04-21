import 'package:app/providers.dart';
import 'package:app/ui/pages/user/register/login.dart';
import 'package:app/ui/pages/user/register/register.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:common/models/user.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MePage extends ConsumerStatefulWidget {
  const MePage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _InputPageState();
}

class _InputPageState extends ConsumerState<MePage> {
  @override
  Widget build(BuildContext context) {
    User? user = ref.watch(globalUserInfoProvider.state).state;
    return Container(
      color: Colors.yellow.withAlpha(100),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: user == null
              ? Column(
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
                )
              : Text("logged in as ${user.name}"),
        ),
      ),
    );
  }
}
