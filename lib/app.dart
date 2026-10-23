import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/providers.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/presentation/auth_controller.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/presentation/settings_providers.dart';

class WireSpotApp extends ConsumerStatefulWidget {
  const WireSpotApp({super.key});

  @override
  ConsumerState<WireSpotApp> createState() => _WireSpotAppState();
}

class _WireSpotAppState extends ConsumerState<WireSpotApp>
    with WidgetsBindingObserver {
  DateTime? _backgroundAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _backgroundAt ??= DateTime.now();
      _lockIfRequired();
    } else if (state == AppLifecycleState.resumed) {
      _lockIfRequired();
    }
  }

  Future<void> _lockIfRequired() async {
    final auth = ref.read(authControllerProvider);
    if (!auth.isAuthenticated || _backgroundAt == null) return;
    final setting = await ref
        .read(settingsRepositoryProvider)
        .readSetting(AppSettingsKeys.appLockMode);
    final mode = AppLockMode.values.firstWhere(
      (value) => value.name == setting,
      orElse: () => AppLockMode.never,
    );
    final elapsed = DateTime.now().difference(_backgroundAt!);
    final shouldLock =
        mode == AppLockMode.onBackground ||
        (mode == AppLockMode.afterFiveMinutes &&
            elapsed >= const Duration(minutes: 5));
    if (!shouldLock) return;
    _backgroundAt = null;
    await auth.signOut();
    if (mounted) ref.read(appRouterProvider).go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(appSettingsProvider).asData?.value;

    final preference = settings?.themePreference;
    return MaterialApp.router(
      title: 'WireSpot',
      debugShowCheckedModeBanner: false,
      theme: _theme(preference),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode(settings?.themePreference),
      locale: _materialLocale(settings?.languageCode),
      // Hausa is translated by WireSpot's AppText layer. Flutter's bundled
      // MaterialLocalizations does not currently provide a Hausa delegate,
      // so keeping it in this list would leave Material controls (dropdowns,
      // dialogs, date pickers, etc.) without localizations and can make the
      // Settings screen fail after switching languages. The Material chrome
      // falls back to English while the app content remains Hausa.
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
      AppThemePreference.ocean => ThemeMode.light,
      AppThemePreference.glass => ThemeMode.light,
      AppThemePreference.colorful => ThemeMode.light,
      AppThemePreference.hacker => ThemeMode.dark,
      AppThemePreference.playful => ThemeMode.light,
      AppThemePreference.system || null => ThemeMode.system,
    };
  }

  ThemeData _theme(AppThemePreference? preference) {
    return switch (preference) {
      AppThemePreference.ocean => AppTheme.ocean(),
      AppThemePreference.glass => AppTheme.glass(),
      AppThemePreference.colorful => AppTheme.colorful(),
      AppThemePreference.hacker => AppTheme.hacker(),
      AppThemePreference.playful => AppTheme.playful(),
      _ => AppTheme.light(),
    };
  }

  Locale _materialLocale(String? languageCode) {
    return switch (languageCode) {
      'fr' => const Locale('fr'),
      // Hausa is intentionally handled by AppText, not MaterialLocalizations.
      'ha' => const Locale('en'),
      _ => const Locale('en'),
    };
  }
}
