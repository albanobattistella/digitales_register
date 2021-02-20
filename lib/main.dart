import 'dart:io';

import 'package:built_redux/built_redux.dart';
import 'package:dr/container/settings_page.dart';
import 'package:dr/desktop.dart';
import 'package:dr/ui/grade_calculator.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_built_redux/flutter_built_redux.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_scaffold/responsive_scaffold.dart';
import 'package:uni_links/uni_links.dart';

import 'actions/app_actions.dart';
import 'app_state.dart';
import 'container/change_email_container.dart';
import 'container/home_page.dart';
import 'container/login_page.dart';
import 'container/notifications_page_container.dart';
import 'container/pass_reset_container.dart';
import 'container/profile_container.dart';
import 'container/request_pass_reset_container.dart';
import 'middleware/middleware.dart';
import 'reducer/reducer.dart';
import 'ui/grades_chart_page.dart';

GlobalKey<NavigatorState>? navigatorKey;
GlobalKey<NavigatorState> nestedNavKey = GlobalKey();
GlobalKey<ResponsiveScaffoldState<Pages>>? scaffoldKey;
GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

typedef SingleArgumentVoidCallback<T> = void Function(T arg);

void main() {
  // This is required to access the secure storage
  // (crash report from a desktop user, possible race?)
  WidgetsFlutterBinding.ensureInitialized();
  navigatorKey = GlobalKey();
  scaffoldKey = GlobalKey();
  scaffoldMessengerKey = GlobalKey();
  secureStorage = getFlutterSecureStorage();
  final store = Store<AppState, AppStateBuilder, AppActions>(
    appReducerBuilder.build(),
    AppState(),
    AppActions(),
    middleware: middleware,
  );
  runApp(
    ReduxProvider(
      store: store,
      child: Listener(
        onPointerDown: (_) => store.actions.loginActions.updateLogout(),
        child: DynamicTheme(
          data: (brightness, overridePlatform) {
            TargetPlatform? platform;
            if (overridePlatform && Platform.isAndroid) {
              platform = TargetPlatform.iOS;
            }
            return brightness == Brightness.dark
                ? ThemeData(
                    primarySwatch: Colors.teal,
                    brightness: brightness,
                    platform: platform,
                  )
                : ThemeData(
                    primarySwatch: Colors.deepOrange,
                    brightness: brightness,
                    platform: platform,
                  );
          },
          themedWidgetBuilder: (context, theme) => MaterialApp(
            localizationsDelegates: const [
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale("de"),
            ],
            navigatorKey: navigatorKey,
            scaffoldMessengerKey: scaffoldMessengerKey,
            initialRoute: "/",
            onGenerateRoute: (RouteSettings settings) {
              final List<String> pathElements = settings.name!.split("/");
              if (pathElements[0] != "") return null;
              switch (pathElements[1]) {
                case "":
                  return MaterialPageRoute<void>(
                    builder: (_) => HomePage(),
                  );
                case "login":
                  return MaterialPageRoute<void>(
                    builder: (_) => LoginPage(),
                  );
                case "request_pass_reset":
                  return MaterialPageRoute<void>(
                    builder: (_) => RequestPassResetContainer(),
                  );
                case "pass_reset":
                  return MaterialPageRoute<void>(
                    builder: (_) => PassResetContainer(),
                  );
                case "change_email":
                  return MaterialPageRoute<void>(
                    builder: (_) => ChangeEmailContainer(),
                  );
                case "profile":
                  return MaterialPageRoute<void>(
                    builder: (_) => ProfileContainer(),
                  );
                case "notifications":
                  return MaterialPageRoute<void>(
                    builder: (_) => NotificationPageContainer(),
                    fullscreenDialog: true,
                  );
                case "gradesChart":
                  return MaterialPageRoute<void>(
                    builder: (_) => const GradesChartPage(),
                    fullscreenDialog: true,
                  );
                case "gradeCalculator":
                  return MaterialPageRoute<void>(
                    builder: (_) => const GradeCalculator(),
                    fullscreenDialog: true,
                  );
                case "settings":
                  return MaterialPageRoute<void>(
                    builder: (_) => SettingsPageContainer(),
                    fullscreenDialog: true,
                  );
                default:
                  throw Exception("Unknown Route ${pathElements[1]}");
              }
            },
            theme: theme,
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    ),
  );
  WidgetsBinding.instance!.addPostFrameCallback(
    (_) async {
      Uri? uri;
      if (Platform.isAndroid) {
        uri = await getInitialUri();
        uriLinkStream.listen((event) {
          store.actions.start(event);
        });
      }
      store.actions.start(uri);
      WidgetsBinding.instance!.addObserver(
        LifecycleObserver(
          () {
            store.actions.restarted();
          },
          // this might not finish in time:
          store.actions.saveState,
        ),
      );
    },
  );
}

class LifecycleObserver with WidgetsBindingObserver {
  final VoidCallback onReload;
  final VoidCallback onLogout;

  LifecycleObserver(this.onReload, this.onLogout);
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onReload();
    }
    if (state == AppLifecycleState.paused) {
      onLogout();
    }
  }
}

/// Utility to show a global Snack Bar
void showSnackBar(String message) {
  scaffoldMessengerKey!.currentState!.showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

/*
ThemeData _getDarkTheme(MaterialColor primarySwatch) {
  final colorScheme = ColorScheme(
    primary: primarySwatch,
    primaryVariant: primarySwatch[700],
    secondary: primarySwatch,
    secondaryVariant: primarySwatch[700],
    surface: Colors.grey[800],
    background: Colors.grey[700],
    error: Colors.red[700],
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onBackground: Colors.white,
    onError: Colors.black,
    brightness: Brightness.dark,
  );
  return ThemeData(
    brightness: Brightness.dark,
    primarySwatch: primarySwatch,
    primaryColor: primarySwatch,
    primaryColorLight: primarySwatch[100],
    primaryColorDark: primarySwatch[700],
    toggleableActiveColor: primarySwatch[600],
    accentColor: primarySwatch[500],
    secondaryHeaderColor: primarySwatch[200],
    backgroundColor: primarySwatch[200],
    indicatorColor: primarySwatch[500],
    buttonColor: primarySwatch[600],
    colorScheme: colorScheme,
  );
}
*/
