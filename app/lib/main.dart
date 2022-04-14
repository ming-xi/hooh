import 'dart:async';

import 'package:app/providers.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/user/register/login.dart';
import 'package:common/utils/device_info.dart';
import 'package:common/utils/preferences.dart';

// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initUtils();
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> initUtils() async {
  await initSyncUtils();
  initASyncUtils();
}

///需要同步初始化的工具类
Future<void> initSyncUtils() async {
  await preferences.init();
  await deviceInfo.init();
}

///不需要同步初始化的工具类
void initASyncUtils() {}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var oldThemeData = ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 16),
          actionsIconTheme: IconThemeData(color: Colors.black),
          iconTheme: IconThemeData(color: Colors.black),
          // shadowColor: Colors.transparent,
        ));
    final darkTheme = ThemeData(
      primarySwatch: Colors.grey,
      primaryColor: Colors.black,
      brightness: Brightness.dark,
      backgroundColor: const Color(0xFF212121),
      dividerColor: Colors.black12,
    );

    final lightTheme = ThemeData(
      primarySwatch: Colors.grey,
      primaryColor: Colors.white,
      brightness: Brightness.light,
      backgroundColor: const Color(0xFFE5E5E5),
      dividerColor: Colors.white54,
    );
    bool darkMode = ref.watch(globalDarkModeProvider.state).state;
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      /* ThemeMode.system to follow system theme,
         ThemeMode.light for light theme,
         ThemeMode.dark for dark theme
      */

      title: 'HooH',
      // home: HomeScreen(),
      home: getLandingScreen(),
    );
  }
}

Widget getLandingScreen() {
  // preferences.putBool(Preferences.keyUserHasSkippedLogin, false);
  if (preferences.getBool(Preferences.keyUserHasLogin, def: false)! || preferences.getBool(Preferences.keyUserHasSkippedLogin, def: false)!) {
    return HomeScreen();
  } else {
    return const LoginScreen();
  }
}
