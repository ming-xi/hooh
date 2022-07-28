import 'dart:async';

import 'package:common/utils/preferences.dart';
import 'package:flutter/foundation.dart';

// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web/global.dart';
import 'package:web/ui/pages/landing.dart';
import 'package:web/ui/pages/start.dart';
import 'package:web/utils/design_colors.dart';

class Launcher {
  static const KEY_ADMIN_MODE = "KEY_ADMIN_MODE";

  Future<void> prepare() async {
    WidgetsFlutterBinding.ensureInitialized();
    // enableImmersiveMode();
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    // setUrlStrategy(PathUrlStrategy());

    await _initUtils();
  }

  Future<void> _initUtils() async {
    await _initSyncUtils();
    _initASyncUtils();
  }

  ///需要同步初始化的工具类
  Future<void> _initSyncUtils() async {
    await preferences.init();
  }

  ///不需要同步初始化的工具类
  void _initASyncUtils() {}
}

class HoohWeb extends ConsumerStatefulWidget {
  const HoohWeb({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _HoohWebState();
}

class _HoohWebState extends ConsumerState<HoohWeb> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int darkMode = ref.watch(globalDarkModeProvider);
    Locale? appLocale = ref.watch(globalLocaleProvider);
    debugPrint("appLocale=${appLocale?.languageCode}");
    return MaterialApp(
      initialRoute: 'start',
      onGenerateRoute: generateRoute,
      theme: buildThemeData(),
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
      title: 'HooH',
      // home: HomeScreen(),
      // home: StartScreen(),
      builder: (context, child) {
        debugPrint("app builder build");
        globalLocalizations = AppLocalizations.of(context)!;
        if (kDebugMode) {
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
        } else {
          return child!;
        }
      },
    );
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == null) {
      return MaterialPageRoute(builder: (_) => Container());
    }
    Uri uri = Uri.parse(settings.name!);
    String? baseHref = getBaseElementHrefFromDom();
    debugPrint("baseHref=$baseHref");
    debugPrint("uri=${uri.toString()}");
    String path = uri.path.replaceFirst("/", "");
    // debugPrint("path=$path");

    switch (path) {
      // case '/':
      //   return MaterialPageRoute(builder: (_) => Container());
      case 'start':
        return MaterialPageRoute(builder: (_) => StartScreen());
      case 'landing':
        return MaterialPageRoute(
            builder: (_) => LandingScreen(
                  appLink: uri.queryParameters['app_link'],
                ));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'No route defined for ${settings.name}',
                style: TextStyle(color: designColors.dark_01.auto(ref)),
              ),
            ),
          ),
        );
    }
  }

  ThemeData buildThemeData() {
    var oldThemeData = ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 16),
          actionsIconTheme: IconThemeData(color: Colors.black),
          iconTheme: IconThemeData(color: Colors.black),
          // shadowColor: Colors.transparent,
        ));
    return ThemeData(
        primaryColor: designColors.bar90_1.auto(ref),
        backgroundColor: designColors.light_00.auto(ref),
        dialogBackgroundColor: designColors.light_00.auto(ref),
        scaffoldBackgroundColor: designColors.light_00.auto(ref),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: designColors.bar90_1.auto(ref),
          titleTextStyle: TextStyle(color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold, fontSize: 16),
          actionsIconTheme: IconThemeData(color: designColors.dark_01.auto(ref)),
          iconTheme: IconThemeData(color: designColors.dark_01.auto(ref)),

          foregroundColor: designColors.feiyu_blue.generic,
          toolbarTextStyle: TextStyle(color: designColors.feiyu_blue.generic, fontWeight: FontWeight.bold, fontSize: 16),
          // shadowColor: Colors.transparent,
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
            ),
            contentTextStyle: TextStyle(
              color: designColors.dark_01.auto(ref),
              fontSize: 16,
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
            labelStyle: TextStyle(
              color: designColors.dark_01.auto(ref),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              color: designColors.dark_01.auto(ref),
              fontSize: 16,
            ),
            indicatorSize: TabBarIndicatorSize.label,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: designColors.dark_01.auto(ref), width: 2),
            )),
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
                textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16, color: designColors.feiyu_blue.generic, fontWeight: FontWeight.bold)))));
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
