import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Thin wrapper around [FlutterLocalNotificationsPlugin].
class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: initSettings);
    _initialized = true;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'router_alerts',
      'Router Alerts',
      channelDescription: 'Alerts for monitored router thresholds',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }
}
