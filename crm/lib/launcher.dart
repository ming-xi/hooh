import 'dart:async';
import 'dart:ui';

import 'package:common/utils/device_info.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:crm/global.dart';
import 'package:crm/ui/pages/splash.dart';
import 'package:crm/utils/design_colors.dart';
import 'package:flutter/foundation.dart';

// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// import 'package:jshare_flutter_plugin/jshare_flutter_plugin.dart';
import 'package:path_provider/path_provider.dart';

class Launcher {
  static const KEY_ADMIN_MODE = "KEY_ADMIN_MODE";

  Future<void> prepare() async {
    Network.SERVER_HOSTS[Network.TYPE_STAGING] = "stg-api.hooh.fun";
    WidgetsFlutterBinding.ensureInitialized();
    // enableImmersiveMode();
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    await _initUtils();
  }

  Future<void> _initUtils() async {
    await _initSyncUtils();
    _initASyncUtils();
  }

  ///需要同步初始化的工具类
  Future<void> _initSyncUtils() async {
    await preferences.init();
    await deviceInfo.init();
  }

  Future<String> _documentsDirectory() async {
    if (kIsWeb) return '.';
    return (await getApplicationDocumentsDirectory()).path;
  }

  Future<String> _cacheDirectory() async {
    if (kIsWeb) return '.';
    return (await getTemporaryDirectory()).path;
  }

  ///不需要同步初始化的工具类
  void _initASyncUtils() {}
}

class HoohCrm extends ConsumerStatefulWidget {
  const HoohCrm({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _HoohCrmState();
}

class _HoohCrmState extends ConsumerState<HoohCrm> with WidgetsBindingObserver, KeyboardLogic {
  @override
  void onKeyboardChanged(bool visible) {
    // globalIsKeyboardVisible = visible;
    ref.read(globalKeyboardVisibilityProvider.state).state = visible;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateOrientation();
    });
  }

  void updateOrientation() {
    ref.read(globalOrientationProvider.state).state = window.physicalSize.width >= window.physicalSize.height ? Orientation.landscape : Orientation.portrait;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // setState(() {
    //   width = window.physicalSize.width;
    //   height = window.physicalSize.height;
    // });
    updateOrientation();
  }

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
    int darkMode = ref.watch(globalDarkModeProvider);
    Locale? appLocale = ref.watch(globalLocaleProvider);
    debugPrint("appLocale=${appLocale?.languageCode}");
    Brightness brightness = SchedulerBinding.instance.window.platformBrightness;
    // debugPrint("DesignColor brightness=$brightness");
    var themeData = ThemeData(
        primaryColor: designColors.bar90_1.auto(ref),
        backgroundColor: designColors.light_00.auto(ref),
        dialogBackgroundColor: designColors.light_00.auto(ref),
        scaffoldBackgroundColor: designColors.light_00.auto(ref),
        fontFamily: 'Linotte',
        appBarTheme: AppBarTheme(
          elevation: 0,
          shape: Border(bottom: BorderSide(color: designColors.light_02.auto(ref), width: 1)),
          centerTitle: false,
          backgroundColor: designColors.bar90_1.auto(ref),
          titleTextStyle: TextStyle(color: designColors.dark_01.auto(ref), fontFamily: 'Linotte', fontWeight: FontWeight.bold, fontSize: 16),
          actionsIconTheme: IconThemeData(color: designColors.dark_01.auto(ref)),
          iconTheme: IconThemeData(color: designColors.dark_01.auto(ref)),

          foregroundColor: designColors.feiyu_blue.generic,
          toolbarTextStyle: TextStyle(color: designColors.feiyu_blue.generic, fontFamily: 'Linotte', fontWeight: FontWeight.bold, fontSize: 16),
          // shadowColor: Colors.transparent,
        ),
        // scrollbarTheme: ScrollbarThemeData().copyWith(
        //   // thumbVisibility: MaterialStateProperty.all(true)
        //
        //   // thumbColor: MaterialStateProperty.all(Colors.grey[500]),
        // ),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        }),
        dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: designColors.dark_01.auto(ref),
              fontFamily: 'Linotte',
            ),
            contentTextStyle: TextStyle(
              color: designColors.dark_01.auto(ref),
              fontSize: 16,
              fontFamily: 'Linotte',
            )),
        checkboxTheme: CheckboxThemeData(
            checkColor: MaterialStateProperty.all(designColors.light_01.auto(ref)),
            fillColor: MaterialStateProperty.all(designColors.dark_01.auto(ref)),
            side: BorderSide(color: designColors.dark_01.auto(ref), width: 1),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(4),
              ),
            )),
        tabBarTheme: TabBarTheme(
            labelPadding: EdgeInsets.symmetric(horizontal: 8),
            labelStyle: TextStyle(
              color: designColors.dark_01.auto(ref),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Linotte',
            ),
            unselectedLabelStyle: TextStyle(
              color: designColors.dark_01.auto(ref),
              fontSize: 16,
              fontFamily: 'Linotte',
            ),
            indicatorSize: TabBarIndicatorSize.label,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: designColors.dark_01.auto(ref), width: 2),
            )),
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                    TextStyle(fontSize: 16, color: designColors.feiyu_blue.generic, fontFamily: 'Linotte', fontWeight: FontWeight.bold)))));
    return MaterialApp(
      navigatorObservers: [routeObserver],
      theme: themeData,
      // darkTheme: themeData.copyWith(brightness: Brightness.dark),
      themeMode: getThemeMode(darkMode),
      // locale: appLocale,
      // localeResolutionCallback: (locale, locales) {
      //   if (locale != null) {
      //     for (Locale supportedLocale in locales) {
      //       if (locale.languageCode == supportedLocale.languageCode) {
      //         return supportedLocale;
      //       }
      //     }
      //   }
      //   return locales.first;
      // },
      // supportedLocales: const [
      //   Locale('en', ''),
      //   Locale('zh', ''),
      // ],

      title: 'HooH CRM',
      home: SplashScreen(),
      builder: (context, child) {
        // globalLocalizations = AppLocalizations.of(context)!;
        // return Scaffold(body: child!,);
        var stack = Stack(
          children: [
            child!,
            Positioned(
              top: 0,
              left: 48,
              // left: MediaQuery.of(context).size.width * 0.3,
              child: SafeArea(
                child: ElevatedButton(
                    style: TextButton.styleFrom(
                      backgroundColor: designColors.light_01.auto(ref),
                      shape: CircleBorder(),
                    ),
                    onPressed: () {
                      int darkMode = ref.watch(globalDarkModeProvider);
                      darkMode = cycleDarkMode(darkMode);
                      ref.read(globalDarkModeProvider.state).state = darkMode;
                      preferences.putInt(Preferences.KEY_DARK_MODE, darkMode);
                    },
                    child: Icon(
                      getIcon(darkMode),
                      color: designColors.dark_01.auto(ref),
                    )),
              ),
            ),
          ],
        );
        return Scaffold(
          body: stack,
        );
      },
    );
  }

  IconData getIcon(int darkModeValue) {
    switch (darkModeValue) {
      case DARK_MODE_LIGHT:
        return Icons.light_mode;
      case DARK_MODE_DARK:
        return Icons.dark_mode;
      case DARK_MODE_SYSTEM:
      default:
        return Icons.brightness_medium;
    }
  }

  ThemeMode getThemeMode(int darkModeValue) {
    switch (darkModeValue) {
      case DARK_MODE_LIGHT:
        return ThemeMode.light;
      case DARK_MODE_DARK:
        return ThemeMode.dark;
      case DARK_MODE_SYSTEM:
      default:
        return ThemeMode.system;
    }
  }

  int cycleDarkMode(int current) {
    current += 1;
    if (current >= DARK_MODE_VALUES.length) {
      current = 0;
    }
    return current;
  }
}
