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

  static String editRouter(String routerId) {
    return '/routers/$routerId/edit';
  }
}
