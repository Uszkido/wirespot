import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'status': 'success',
      'routers': [
        {
          'name': 'Main-Gateway-MikroTik',
          'vendor': 'MikroTik RouterOS',
          'ip': '192.168.88.1',
          'port': 8728,
          'status': 'online',
        },
        {
          'name': 'Pool-Bar-Ruijie',
          'vendor': 'Ruijie / Reyee',
          'ip': '10.0.0.15',
          'port': 443,
          'status': 'online',
        },
        {
          'name': 'Lobby-AP-OpenWrt',
          'vendor': 'OpenWrt',
          'ip': '192.168.1.1',
          'port': 22,
          'status': 'online',
        },
        {
          'name': 'Hotel-Controller-Omada',
          'vendor': 'TP-Link Omada',
          'ip': '192.168.0.10',
          'port': 443,
          'status': 'online',
        },
        {
          'name': 'Campus-UniFi-CloudKey',
          'vendor': 'Ubiquiti UniFi',
          'ip': '192.168.20.5',
          'port': 443,
          'status': 'online',
        },
        {
          'name': 'Generic-Edge-Gateway',
          'vendor': 'Generic Router',
          'ip': '10.0.0.1',
          'port': 443,
          'status': 'online',
        },
      ],
    },
  );
}
