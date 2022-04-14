import 'package:common/models/user.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final StateProvider<User?> globalUserInfoProvider = StateProvider<User?>((ref) => null);

final StateProvider<bool> globalDarkModeProvider = StateProvider((ref) {
  return false;
});
