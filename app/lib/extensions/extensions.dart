import 'package:hooks_riverpod/hooks_riverpod.dart';

extension UpdateStateExtension<T> on StateNotifier<T> {
  void updateState(T s) {
    state = s;
  }
}

