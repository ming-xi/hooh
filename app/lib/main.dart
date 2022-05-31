import 'dart:async';

import 'package:app/global.dart';
import 'package:app/ui/pages/splash.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/file_utils.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/utils/device_info.dart';
import 'package:common/utils/preferences.dart';
import 'package:file_local_storage_inspector/file_local_storage_inspector.dart';
import 'package:flutter/foundation.dart';

// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:preferences_local_storage_inspector/preferences_local_storage_inspector.dart';
import 'package:secure_storage_local_storage_inspector/secure_storage_local_storage_inspector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage_inspector/storage_inspector.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // enableImmersiveMode();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // 保留开屏页
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await _initUtils();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const ProviderScope(child: HoohApp()));
  });
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
  await initInspector();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

class HoohApp extends ConsumerStatefulWidget {
  const HoohApp({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<HoohApp> with WidgetsBindingObserver, KeyboardLogic {
  @override
  void onKeyboardChanged(bool visible) {
    // globalIsKeyboardVisible = visible;
    ref.read(globalKeyboardInfoProvider.state).state = visible;
  }

  @override
  void initState() {
    super.initState();
    // SchedulerBinding.instance.window.onPlatformBrightnessChanged=(){
    //   Brightness brightness = SchedulerBinding.instance.window.platformBrightness;
    //
    // };
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
    int darkMode = ref.watch(globalDarkModeProvider.state).state;
    Brightness brightness = SchedulerBinding.instance.window.platformBrightness;
    // debugPrint("DesignColor brightness=$brightness");
    return MaterialApp(
      theme: globalLightTheme,
      darkTheme: globalDarkTheme,
      themeMode: getThemeMode(darkMode),
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
      builder: (context, child) {
        globalLocalizations = AppLocalizations.of(context)!;
        return Scaffold(
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
                      int darkMode = ref.watch(globalDarkModeProvider.state).state;
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
