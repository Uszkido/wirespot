class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const routers = '/routers';
  static const newRouter = '/routers/new';
  static const hotspot = '/hotspot';
  static const vouchers = '/vouchers';
  static const reports = '/reports';
  static const settings = '/settings';
  static const wireGuard = '/wireguard';
  static const permissions = '/permissions';

  static String editRouter(String routerId) {
    return '/routers/$routerId/edit';
  }

  static String hotspotTab(String tab) {
    return Uri(path: hotspot, queryParameters: {'tab': tab}).toString();
  }

  static String get hotspotSessions => hotspotTab('sessions');

  static String wireGuardTunnel(String tunnelName) {
    return Uri(
      path: wireGuard,
      queryParameters: {'tunnel': tunnelName},
    ).toString();
  }
}
