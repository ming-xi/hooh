import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:app/global.dart';
import 'package:app/ui/pages/splash.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/file_utils.dart';
import 'package:app/utils/push.dart';
import 'package:common/utils/device_info.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:file_local_storage_inspector/file_local_storage_inspector.dart';
import 'package:flutter/foundation.dart';

// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// import 'package:jshare_flutter_plugin/jshare_flutter_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:preferences_local_storage_inspector/preferences_local_storage_inspector.dart';
import 'package:secure_storage_local_storage_inspector/secure_storage_local_storage_inspector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage_inspector/storage_inspector.dart';

class Launcher {
  static const KEY_ADMIN_MODE = "KEY_ADMIN_MODE";

  Future<void> prepare() async {
    WidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = MyHttpOverrides();
    // enableImmersiveMode();
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    // 保留开屏页
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    await _initUtils();
  }

  void enableImmersiveMode() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: true,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: true,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _initUtils() async {
    await _initSyncUtils();
    _initASyncUtils();
  }

  ///需要同步初始化的工具类
  Future<void> _initSyncUtils() async {
    await preferences.init();
    await deviceInfo.init();
    await pushUtil.init();
    await initInspector();
  }

  Future<void> initInspector() async {
    if (kDebugMode) {
      final driver = StorageServerDriver(
        bundleId: 'xyz.hooh.app', //Used for identification
        port: 0, //Default 0, use 0 to automatically use a free port
        // icon: '...' //Optional icon to visually identify the server. Base64 png or plain svg string
      );

      final keyValueServer = PreferencesKeyValueServer(await SharedPreferences.getInstance(), 'Preferences', keySuggestions: {
        const ValueWithType(StorageType.string, 'testBool'),
        const ValueWithType(StorageType.string, 'testInt'),
        const ValueWithType(StorageType.string, 'testFloat'),
      });
      driver.addKeyValueServer(keyValueServer);

      final secureKeyValueServer = SecureStorageKeyValueServer(const FlutterSecureStorage(), 'Preferences', keySuggestions: {
        'testBool',
        'testInt',
        'testFloat',
      });
      driver.addKeyValueServer(secureKeyValueServer);

      var fileServer = DefaultFileServer(await _documentsDirectory(), 'App Documents');
      driver.addFileServer(fileServer);
      fileServer = DefaultFileServer(await _cacheDirectory(), 'Cache');
      driver.addFileServer(fileServer);

      await driver.start();
    }
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
  void _initASyncUtils() {
    FileUtil.loadUiImageFromAsset("assets/images/icon_template_text_frame_scale.png").then((image) {
      scaleButtonImage = image;
    });
  }
}

class HoohApp extends ConsumerStatefulWidget {
  const HoohApp({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _HoohAppState();
}

class _HoohAppState extends ConsumerState<HoohApp> with WidgetsBindingObserver, KeyboardLogic {
  late Brightness brightness;

  @override
  void onKeyboardChanged(bool visible) {
    // globalIsKeyboardVisible = visible;
    ref.read(globalKeyboardVisibilityProvider.state).state = visible;
  }

  @override
  void initState() {
    super.initState();
    SingletonFlutterWindow window = WidgetsBinding.instance.window;
    window.onPlatformBrightnessChanged = () {
      WidgetsBinding.instance.handlePlatformBrightnessChanged();
      // This callback is called every time the brightness changes.
      setState(() {
        // 强制build
        brightness = window.platformBrightness;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    // var oldThemeData = ThemeData(
    //     primarySwatch: Colors.blue,
    //     appBarTheme: const AppBarTheme(
    //       backgroundColor: Colors.white,
    //       titleTextStyle: TextStyle(color: Colors.black, fontSize: 16),
    //       actionsIconTheme: IconThemeData(color: Colors.black),
    //       iconTheme: IconThemeData(color: Colors.black),
    //       // shadowColor: Colors.transparent,
    //     ));
    int darkMode = ref.watch(globalDarkModeProvider);
    Locale? appLocale = ref.watch(globalLocaleProvider);
    debugPrint("appLocale=${appLocale?.languageCode}");
    brightness = SchedulerBinding.instance.window.platformBrightness;
    debugPrint("DesignColor brightness=$brightness");
    var themeData = ThemeData(
        primaryColor: designColors.bar90_1.auto(ref),
        backgroundColor: designColors.light_00.auto(ref),
        dialogBackgroundColor: designColors.light_00.auto(ref),
        scaffoldBackgroundColor: designColors.light_00.auto(ref),
        fontFamily: 'Linotte',
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
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
        listTileTheme: ListTileThemeData(textColor: designColors.dark_01.auto(ref)),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: designColors.light_00.auto(ref),
        ),
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
      localizationsDelegates: const [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: appLocale,
      localeResolutionCallback: (locale, locales) {
        if (locale != null) {
          for (Locale supportedLocale in locales) {
            if (locale.languageCode == supportedLocale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return locales.first;
      },
      supportedLocales: const [
        Locale('en', ''),
        Locale('zh', ''),
      ],
      title: 'HOOH',
      // home: HomeScreen(),
      home: const SplashScreen(),
      // debugShowCheckedModeBanner: false,
      builder: (context, child) {
        globalLocalizations = AppLocalizations.of(context)!;
        if (kReleaseMode) {
          return Scaffold(
            body: child!,
          );
        } else {
          return Scaffold(
            body: Stack(
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
            ),
          );
        }
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
