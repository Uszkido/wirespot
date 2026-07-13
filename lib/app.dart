import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/presentation/settings_providers.dart';

class WireSpotApp extends ConsumerWidget {
  const WireSpotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(appSettingsProvider).asData?.value;

    return MaterialApp.router(
      title: 'WireSpot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode(settings?.themePreference),
      locale: _materialLocale(settings?.languageCode),
      supportedLocales: const [Locale('en'), Locale('fr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }

  ThemeMode _themeMode(AppThemePreference? preference) {
    return switch (preference) {
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
      AppThemePreference.system || null => ThemeMode.system,
    };
  }

  Locale _materialLocale(String? languageCode) {
    return switch (languageCode) {
      'fr' => const Locale('fr'),
      _ => const Locale('en'),
    };
  }
}
