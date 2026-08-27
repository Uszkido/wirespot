import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final shouldLock = mode == AppLockMode.onBackground ||
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

    return MaterialApp.router(
      title: 'WireSpot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode(settings?.themePreference),
      locale: _materialLocale(settings?.languageCode),
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('ha')],
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
      'ha' => const Locale('ha'),
      _ => const Locale('en'),
    };
  }
}
