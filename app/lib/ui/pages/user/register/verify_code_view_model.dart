import 'dart:async';

import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'verify_code_view_model.g.dart';

@CopyWith()
class VerifyCodeModelState {
  final int seconds;
  final int countryCode;
  final String phoneNumber;
  final HoohApiErrorResponse? error;
  final bool sendCodeEnable;

  VerifyCodeModelState(
      {
      required this.seconds,
      required this.phoneNumber,
      required this.countryCode,
      required this.error,
      required this.sendCodeEnable});

  factory VerifyCodeModelState.init(int countryCode, String phoneNumber) =>
      VerifyCodeModelState(seconds: 0, phoneNumber: phoneNumber, countryCode: countryCode, error: null, sendCodeEnable: true);
}

class VerifyCodeViewModel extends StateNotifier<VerifyCodeModelState> {
  late Timer _timer;

  VerifyCodeViewModel(VerifyCodeModelState state) : super(state) {}

  Future<void> requestValidationCode() async {
    if (!state.sendCodeEnable) {
      return;
    }
    state = state.copyWith(sendCodeEnable: false);
    // network.requestAsync<RequestValidateCodeResponse>(network.requestValidationCodeForRegister(state.countryCode, state.phoneNumber), (data) {
    //   debugPrint("code=${data.code}");
    //   startTimer();
    // }, (error) {
    //   state = state.copyWith(sendCodeEnable: true);
    //   state = state.copyWith(error: error);
    // });
  }

  Future<void> validateCode(String code,Function(String token) onSuccess) async {
    // network.requestAsync<ValidateAccountResponse>(network.validationCodeForRegister(state.countryCode, state.phoneNumber,code), (data) {
    //   debugPrint("token=${data.token}");
    //   onSuccess(data.token);
    // }, (error) {
    //   state = state.copyWith(sendCodeEnable: true);
    //   state = state.copyWith(error: error);
    // });
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
