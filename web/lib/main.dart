import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/launcher.dart';

Future<void> main() async {
  await Launcher().prepare();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(ProviderScope(child: HoohWeb()));
  });
}
