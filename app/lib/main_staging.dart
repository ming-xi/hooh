import 'package:app/launcher.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  FlavorConfig(name: "admin", color: Colors.red, location: BannerLocation.bottomStart, variables: {
    Launcher.KEY_ADMIN_MODE: true,
  });
  await Launcher().prepare();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(ProviderScope(child: FlavorBanner(child: const HoohApp())));
  });
}
