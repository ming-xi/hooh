import 'dart:async';

import 'package:app/providers.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/splash.dart';
import 'package:app/ui/pages/user/register/start.dart';
import 'package:app/utils/design_colors.dart';
import 'package:common/utils/device_info.dart';
import 'package:common/utils/preferences.dart';

// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

class MyApp extends ConsumerStatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    var oldThemeData = ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 16),
          actionsIconTheme: IconThemeData(color: Colors.black),
          iconTheme: IconThemeData(color: Colors.black),
          // shadowColor: Colors.transparent,
        ));
    bool darkMode = ref.watch(globalDarkModeProvider.state).state;
    return MaterialApp(
      theme: globalLightTheme,
      darkTheme: globalDarkTheme,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('zh', ''),
      ],
      title: 'HooH',
      // home: HomeScreen(),
      home: const SplashScreen(),
      builder: (context, child) => Scaffold(
        body: Stack(
          children: [
            child!,
            Positioned(
              top: 8,
              left: MediaQuery.of(context).size.width * 0.3,
              child: SafeArea(
                child: ElevatedButton(
                    style: TextButton.styleFrom(
                      backgroundColor: designColors.light_01.auto(ref),
                      shape: CircleBorder(),
                    ),
                    onPressed: () {
                      bool dark = ref.read(globalDarkModeProvider.state).state;
                      ref.read(globalDarkModeProvider.state).state = !dark;
                    },
                    child: Icon(
                      darkMode ? Icons.light_mode : Icons.dark_mode,
                      color: designColors.dark_01.auto(ref),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
