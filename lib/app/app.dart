import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/i18n/app_localizations.dart';     // ⬅️ add this
import '../core/settings/app_settings.dart';     // ⬅️ and this

class AstroApp extends ConsumerWidget {
  const AstroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(appSettingsProvider); // ⬅️ read theme/locale

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,                 // ⬅️ provide dark theme
      themeMode: settings.themeMode,            // ⬅️ from Settings
      locale: settings.locale,                  // ⬅️ from Settings
      supportedLocales: AppLocalizations.supportedLocales, // ⬅️ en + ta
      localizationsDelegates: const [
        appLocalizationsDelegate,               // ⬅️ your delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
