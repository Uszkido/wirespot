import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/routers/domain/entities/ruijie_cloud_device.dart';

void main() {
  test('maps common Ruijie Cloud device field variants', () {
    final device = RuijieCloudDevice.fromJson({
      'device_id': 'ap-1',
      'hostname': 'Lobby AP',
      'device_model': 'RG-RAP2260',
      'serial_number': 'SERIAL-1',
      'device_status': 'online',
      'site_name': 'Lobby',
    });

    expect(device.id, 'ap-1');
    expect(device.name, 'Lobby AP');
    expect(device.model, 'RG-RAP2260');
    expect(device.serialNumber, 'SERIAL-1');
    expect(device.status, 'online');
    expect(device.siteName, 'Lobby');
  });
}
