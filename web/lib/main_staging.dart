import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:web/launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  await Launcher().prepare();
  preferences.putInt(Preferences.KEY_SERVER, Network.TYPE_STAGING);
  network.reloadServerType();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const ProviderScope(child: HoohWeb()));
  });
}
