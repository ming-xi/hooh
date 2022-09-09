import 'package:common/extensions/extensions.dart';
import 'package:common/models/external_value.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/page_state.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'external_values_view_model.g.dart';

@CopyWith()
class ExternalValuesPageModelState {
  final List<ExternalValue> externalValues;
  final PageState pageState;

  ExternalValuesPageModelState({this.externalValues = const [], this.pageState = PageState.inited});

  factory ExternalValuesPageModelState.init() {
    return ExternalValuesPageModelState();
  }
}

class ExternalValuesPageViewModel extends StateNotifier<ExternalValuesPageModelState> {
  ExternalValuesPageViewModel(ExternalValuesPageModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    getAllValues();
  }

  void getAllValues({void Function(PageState state)? onSuccess, Function(HoohApiErrorResponse error)? onFailed}) {
    updateState(state.copyWith(pageState: PageState.loading));
    network.requestAsync<List<ExternalValue>>(
      network.crmGetAllExternalValues(),
      (newData) {
        updateState(state.copyWith(externalValues: newData, pageState: PageState.dataLoaded));
        if (onSuccess != null) {
          onSuccess(state.pageState);
        }
      },
      (error) {
        updateState(state.copyWith(pageState: PageState.inited));
        if (onFailed != null) {
          onFailed(error);
        }
      },
    );
  }

  void editValue(ExternalValue externalValue, String value, {void Function(ExternalValue value)? onSuccess, Function(HoohApiErrorResponse error)? onFailed}) {
    network.requestAsync<ExternalValue>(
      network.crmEditExternalValue(externalValue.key, value),
      (newData) {
        state.externalValues[state.externalValues.indexOf(externalValue)] = newData;
        updateState(state.copyWith(
          externalValues: [...state.externalValues],
        ));
        if (onSuccess != null) {
          onSuccess(newData);
        }
      },
      (error) {
        if (onFailed != null) {
          onFailed(error);
        }
      },
    );
  }
}
