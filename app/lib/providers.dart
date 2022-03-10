import 'package:common/models/user.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final globalUserInfoProvider = StateProvider<User?>((ref) => null);
