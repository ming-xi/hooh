import 'dart:async';

import 'package:app/launcher.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  FlavorConfig(
      name: "",
      color: Colors.red,
      location: BannerLocation.bottomStart,
      variables: {
        Launcher.KEY_ADMIN_MODE: false,
      });
  await Launcher().prepare();
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runApp(const ProviderScope(child: HoohApp()));
      // runApp(const HoohApp());
    });
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}
