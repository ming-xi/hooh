import 'dart:convert';

import 'package:app/global.dart';
import 'package:app/utils/constants.dart';
import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'bind_email_view_model.g.dart';

@CopyWith()
class BindEmailScreenModelState {
  final String? errorText;
  final bool buttonEnabled;

  BindEmailScreenModelState({
    this.errorText,
    required this.buttonEnabled,
  });

  factory BindEmailScreenModelState.init() => BindEmailScreenModelState(buttonEnabled: false);
}

class BindEmailScreenViewModel extends StateNotifier<BindEmailScreenModelState> {
  BindEmailScreenViewModel(BindEmailScreenModelState state) : super(state) {}

  void requestBindEmailValidationCode(BuildContext context, String email,
      {required void Function() onSuccess, required void Function(HoohApiErrorResponse error) onFailed}) {
    Future<void> request = network.bindAccountRequestValidationCode(email, RequestValidationCodeResponse.TYPE_EMAIL);
    _requestValidationCode(context, request, email, onSuccess: onSuccess, onFailed: onFailed);
  }

  void requestResetPasswordValidationCode(BuildContext context, String email,
      {required void Function() onSuccess, required void Function(HoohApiErrorResponse error) onFailed}) {
    Future<void> request = network.resetPasswordRequestValidationCode(email, RequestValidationCodeResponse.TYPE_EMAIL);
    _requestValidationCode(context, request, email, onSuccess: onSuccess, onFailed: onFailed);
  }

  void _requestValidationCode(BuildContext context, Future<void> request, String email,
      {required void Function() onSuccess, required void Function(HoohApiErrorResponse error) onFailed}) {
    if (!checkEmail(email)) {
      return;
    }
    network.requestAsync<void>(request, (_) {
      Map records;
      String? string = preferences.getString(Preferences.KEY_SEND_VALIDATION_CODE_RECORD_JSON);
      if (string != null) {
        records = json.decode(string);
      } else {
        records = {};
      }
      String newSendDate = DateUtil.getUtcDateString(DateUtil.getCurrentUtcDate());
      records["${RequestValidationCodeResponse.TYPE_EMAIL}_$email"] = newSendDate;
      preferences.putString(Preferences.KEY_SEND_VALIDATION_CODE_RECORD_JSON, json.encode(records));
      onSuccess();
    }, (error) {
      if (error.errorCode == Constants.EMAIL_ALREADY_VALIDATED) {
        updateState(state.copyWith(errorText: globalLocalizations.bind_email_already_validated));
      } else {
        updateState(state.copyWith(errorText: error.message));
      }
      onFailed(error);
    });
  }

  bool checkEmail(String email) {
    email = email.trim();
    if (email.isEmpty) {
      //不修改错误提示
      return false;
    }
    if (RegExp(Constants.EMAIL_REGEX).stringMatch(email) == email) {
      updateState(state.copyWith(errorText: null, buttonEnabled: true));
      return true;
    }
    updateState(state.copyWith(errorText: globalLocalizations.bind_email_invalid_email, buttonEnabled: false));
    return false;
  }
}
