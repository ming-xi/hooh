import 'dart:async';

import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'verify_code_view_model.g.dart';

@CopyWith()
class VerifyCodeModelState {
  final String verifyCode;
  final int seconds;
  final String phoneNumber;
  final HoohApiErrorResponse? error;
  final bool sendCodeEnable;

  VerifyCodeModelState({required this.verifyCode, required this.seconds, required this.phoneNumber, required this.error, required this.sendCodeEnable});

  factory VerifyCodeModelState.init() => VerifyCodeModelState(verifyCode: "", seconds: 0, phoneNumber: "", error: null, sendCodeEnable: true);
}

class VerifyCodeViewModel extends StateNotifier<VerifyCodeModelState> {
  late Timer _timer;

  VerifyCodeViewModel(VerifyCodeModelState state) : super(state) {}

  Future<void> sendCode(String code) async {
    if (!state.sendCodeEnable) {
      return;
    }
    state = state.copyWith(sendCodeEnable: false);
    network.requestAsync<User>(network.getUser("283bc4ee-e489-452f-9827-a15946cf9656"), (newData) {
      startTimer();
    }, (error) {
      state = state.copyWith(sendCodeEnable: true);
      state = state.copyWith(error: error);
      debugPrint("error");
    });
  }

  void startTimer() {
    state = state.copyWith(seconds: 15);
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (state.seconds == 0) {
          _timer.cancel();
          state = state.copyWith(sendCodeEnable: true);
        } else {
          var seconds = state.seconds - 1;
          state = state.copyWith(seconds: seconds);
        }
      },
    );
  }
}
