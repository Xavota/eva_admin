import 'package:medicare/helpers/localizations/app_localization_delegate.dart';
import 'package:medicare/helpers/localizations/language.dart';
import 'package:medicare/helpers/services/navigation_service.dart';
import 'package:medicare/helpers/storage/local_storage.dart';
import 'package:medicare/helpers/theme/app_notifire.dart';
import 'package:medicare/helpers/theme/app_style.dart';
import 'package:medicare/helpers/theme/theme_customizer.dart';
import 'package:medicare/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
//import 'package:medicare/views/ui/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:blix_essentials/blix_essentials.dart';

//import 'dart:js_interop';
//import 'package:web/web.dart' as web;

final List<String> routeStack = [];

Future<void> main() async {
  /*if (web.window != null) {
    web.window.onPopState.listen((event) {
      Debug.log("POP", overrideColor: Colors.purpleAccent);
      /*final path = web.window.location.pathname;
      Debug.log("path: $path", overrideColor: Colors.purpleAccent);
      final isLoggedIn = AuthService.loginType != LoginType.kNone;
      Debug.log("isLoggedIn: $isLoggedIn", overrideColor: Colors.purpleAccent);
      if (!isLoggedIn && (path != "/auth/login" || path != "/panel/auth/login")) {
        Future.microtask(() {
          Get.rootDelegate.toNamed('/auth/login');
        });
      }*/

      /*final path = web.window.location.pathname;

      if (path != null && routeStack.contains(path)) {
        Debug.log("POP", overrideColor: Colors.purpleAccent);
        Get.back(); // Use back if we're going to a previous valid route
      } else {
        Debug.log("IGNORING POP TO INVALID OR UNKNOWN PATH: $path", type: eLogType.kWarning);
      }*/
    });
  }*/


  BlixDBManager.setBaseUrl("https://blixdev.com/eva/");
  BlixDBManager.setPhpLocalUrl("phps/");
  BlixDBManager.setDefaultDebugLogs(false);

  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await LocalStorage.init();
  AppStyle.init();
  await ThemeCustomizer.init();

  runApp(ChangeNotifierProvider<AppNotifier>(
    create: (context) => AppNotifier(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (_, notifier, ___) {
        //return GetMaterialApp.router(
        return GetMaterialApp(
          /*routerDelegate: GetDelegate(
            notFoundRoute: GetPage(
              name: '/not-found',
              page: () => const DashboardScreen(),
            ),
          ),
          routeInformationParser: GetInformationParser(),*/
          routingCallback: (routing) {
            Debug.log('Navigated to: ${routing?.current}', overrideColor: Colors.pinkAccent);
            Debug.log('Previous route: ${routing?.previous}', overrideColor: Colors.pinkAccent);
            Debug.log('Is back: ${routing?.isBack}', overrideColor: Colors.pinkAccent);

            if (routing != null) {
              if (routing.isBack == true && routeStack.isNotEmpty) {
                routeStack.removeLast();
              } else {
                routeStack.add(routing.current);
              }

              Debug.log('ROUTE STACK: $routeStack', overrideColor: Colors.tealAccent);
            }
          },
          //useInheritedMediaQuery: true,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeCustomizer.instance.theme,
          navigatorKey: NavigationService.navigatorKey,
          initialRoute: "/dashboard",
          getPages: getPageRoute(),
          /*unknownRoute: GetPage(
            name: '/not-found',
            page: () => const DashboardScreen(),
          ),*/
          builder: (context, child) {
            NavigationService.registerContext(context);
            return Directionality(
                textDirection: AppTheme.textDirection,
                child: child ?? Container());
          },
          localizationsDelegates: [
            AppLocalizationsDelegate(context),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: Language.getLocales(),
        );
      },
    );
  }
}
