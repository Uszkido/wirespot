import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/auth_controller.dart';
import '../../features/authentication/presentation/login_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/hotspot/presentation/hotspot_page.dart';
import '../../features/reports/presentation/reports_page.dart';
import '../../features/routers/presentation/router_form_page.dart';
import '../../features/routers/presentation/routers_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/voucher/presentation/vouchers_page.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authController = ref.watch(authControllerProvider);
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authController,
    redirect: (context, state) {
      if (!authController.isBootstrapped) {
        return state.matchedLocation == AppRoutes.splash
            ? null
            : AppRoutes.splash;
      }

      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.splash;
      if (!authController.isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }
      if (authController.isAuthenticated && isAuthRoute) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.routers,
        name: 'routers',
        builder: (context, state) => const RoutersPage(),
      ),
      GoRoute(
        path: AppRoutes.hotspot,
        name: 'hotspot',
        builder: (context, state) => const HotspotPage(),
      ),
      GoRoute(
        path: AppRoutes.vouchers,
        name: 'vouchers',
        builder: (context, state) => const VouchersPage(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        builder: (context, state) => const ReportsPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.newRouter,
        name: 'new-router',
        builder: (context, state) => const RouterFormPage(),
      ),
      GoRoute(
        path: '/routers/:routerId/edit',
        name: 'edit-router',
        builder: (context, state) {
          return RouterFormPage(
            routerId: state.pathParameters['routerId'],
          );
        },
      ),
    ],
  );
});
