import 'dart:async';

import 'package:app/providers.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/user/register/login.dart';
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
  // @override
  // void initState() {
  //   super.initState();
  //   Timer(Duration(seconds: 2), () {
  //     addDarkModeButton();
  //   });
  // }

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

    // final lightTheme = ThemeData(
    //     primaryColor: designColors.bar90_1.light,
    //     brightness: Brightness.light,
    //     backgroundColor: designColors.light_00.light,
    //     fontFamily: 'Linotte',
    //     appBarTheme: AppBarTheme(
    //       backgroundColor: designColors.bar90_1.light,
    //       titleTextStyle: TextStyle(color: designColors.dark_01.light, fontSize: 16),
    //       actionsIconTheme: IconThemeData(color: designColors.dark_01.light),
    //       iconTheme: IconThemeData(color: designColors.dark_01.light),
    //       // shadowColor: Colors.transparent,
    //     ),
    //     textButtonTheme: TextButtonThemeData(style: ButtonStyle(textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))));
    //
    // final darkTheme = ThemeData(
    //     primaryColor: designColors.bar90_1.dark,
    //     brightness: Brightness.dark,
    //     backgroundColor: designColors.light_00.dark,
    //     fontFamily: 'Linotte',
    //     appBarTheme: AppBarTheme(
    //       backgroundColor: designColors.bar90_1.dark,
    //       titleTextStyle: TextStyle(color: designColors.dark_01.dark, fontSize: 16),
    //       actionsIconTheme: IconThemeData(color: designColors.dark_01.dark),
    //       iconTheme: IconThemeData(color: designColors.dark_01.dark),
    //       // shadowColor: Colors.transparent,
    //     ));

    bool darkMode = ref.watch(globalDarkModeProvider.state).state;
    return MaterialApp(
      theme: globalLightTheme,
      darkTheme: globalDarkTheme,
      // /* ThemeMode.system to follow system theme,
      //    ThemeMode.light for light theme,
      //    ThemeMode.dark for dark theme
      // */
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      // theme:oldThemeData,
      // darkTheme:oldThemeData,
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
      home: getLandingScreen(),
      builder: (context, child) => Scaffold(
        body: Stack(
          children: [
            child!,
            Positioned(
              top: 8,
              right: MediaQuery.of(context).size.width * 0.3,
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

  Widget getLandingScreen() {
    // preferences.putBool(Preferences.keyUserHasSkippedLogin, false);
    if (preferences.getBool(Preferences.keyUserHasLogin, def: false)! || preferences.getBool(Preferences.keyUserHasSkippedLogin, def: false)!) {
      return HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
