import 'dart:async';
import 'dart:convert';

import 'package:app/global.dart';
import 'package:app/launcher.dart';
import 'package:app/ui/pages/user/register/validate_code.dart';
import 'package:app/utils/constants.dart';
import 'package:common/extensions/extensions.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sprintf/sprintf.dart';

part 'validate_code_view_model.g.dart';

@CopyWith()
class ValidateCodeScreenModelState {
  final String target;
  final int type;
  final String? errorText;
  final String buttonText;
  final bool buttonEnabled;
  final String? lastSendDate;
  final int scene;

  ValidateCodeScreenModelState({
    this.errorText,
    this.lastSendDate,
    required this.target,
    required this.type,
    required this.buttonEnabled,
    required this.buttonText,
    required this.scene,
  });

  factory ValidateCodeScreenModelState.init(String target, int type, int scene) => ValidateCodeScreenModelState(
      target: target,
      type: type,
      scene: scene,
      buttonEnabled: false,
      buttonText: globalLocalizations.validate_code_resend,
      lastSendDate: _getLastTimeSendCodeDate(target, type));

  static String? _getLastTimeSendCodeDate(String target, int type) {
    String? string = preferences.getString(Preferences.KEY_SEND_VALIDATION_CODE_RECORD_JSON);
    if (string == null) {
      return null;
    } else {
      Map records = json.decode(string);
      String? record = records["${type}_$target"];
      if (record == null) {
        return null;
      } else {
        return record;
      }
    }
  }
}

class ValidateCodeScreenViewModel extends StateNotifier<ValidateCodeScreenModelState> {
  late Timer timer;
  int timeout = 60;

  ValidateCodeScreenViewModel(ValidateCodeScreenModelState state) : super(state) {
    startTimer();
    if (FlavorConfig.instance.variables[Launcher.KEY_ADMIN_MODE]) {
      timeout = 10;
    }
  }

  void validationCode(BuildContext context, String code, {required void Function(dynamic) onSuccess, required void Function() onFailed}) {
    Future? request;
    if (state.scene == ValidateCodeScreen.SCENE_BIND_EMAIL) {
      request = network.bindAccountValidateCode(state.target, code);
    } else if (state.scene == ValidateCodeScreen.SCENE_RESET_PASSWORD) {
      request = network.resetPasswordValidateCode(state.target, code);
    }
    if (request == null) {
      onFailed();
      return;
    }
    network.requestAsync(request, (data) {
      onSuccess(data);
    }, (error) {
      if (error.errorCode == Constants.INVALID_VALIDATION_CODE) {
        updateState(state.copyWith(errorText: globalLocalizations.validate_code_invalid_code));
      } else if (error.errorCode == Constants.EMAIL_ALREADY_VALIDATED) {
        updateState(state.copyWith(errorText: globalLocalizations.bind_email_already_validated));
      } else {
        updateState(state.copyWith(errorText: error.message));
      }
      onFailed();
    });
  }

  void resendCode(BuildContext context, String email, {required void Function() onSuccess, required void Function() onFailed}) {
    Future<void>? request;
    if (state.scene == ValidateCodeScreen.SCENE_BIND_EMAIL) {
      request = network.bindAccountRequestValidationCode(email, RequestValidationCodeResponse.TYPE_EMAIL);
    } else if (state.scene == ValidateCodeScreen.SCENE_RESET_PASSWORD) {
      request = network.resetPasswordRequestValidationCode(email, RequestValidationCodeResponse.TYPE_EMAIL);
    }
    if (request == null) {
      onFailed();
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
      records["${state.type}_${state.target}"] = newSendDate;
      preferences.putString(Preferences.KEY_SEND_VALIDATION_CODE_RECORD_JSON, json.encode(records));
      updateState(state.copyWith(lastSendDate: newSendDate, buttonEnabled: false));
      startTimer();
      onSuccess();
    }, (error) {
      if (error.errorCode == Constants.EMAIL_ALREADY_VALIDATED) {
        updateState(state.copyWith(errorText: globalLocalizations.bind_email_already_validated));
      }
      onFailed();
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (t != timer) {
        t.cancel();
        return;
      }
      updateCountDown();
    });
  }

  void updateCountDown() {
    if (state.lastSendDate == null || state.buttonEnabled) {
      return;
    }
    Duration difference = DateUtil.getCurrentUtcDate().difference(DateUtil.getUtcDate(state.lastSendDate!));
    int seconds = 10 - difference.inSeconds;
    debugPrint("seconds=$seconds");
    if (seconds <= 0) {
      updateState(state.copyWith(buttonText: globalLocalizations.validate_code_resend, buttonEnabled: true));
      timer.cancel();
    } else {
      updateState(state.copyWith(buttonText: sprintf(globalLocalizations.validate_code_resend_count_down, ["${seconds}s"]), buttonEnabled: false));
    }
  }
}
