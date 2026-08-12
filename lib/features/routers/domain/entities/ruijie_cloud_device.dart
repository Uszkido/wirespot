class RuijieCloudDevice {
  const RuijieCloudDevice({
    required this.id,
    required this.name,
    this.model,
    this.serialNumber,
    this.status,
    this.siteName,
  });

  final String id;
  final String name;
  final String? model;
  final String? serialNumber;
  final String? status;
  final String? siteName;

  factory RuijieCloudDevice.fromJson(Map<String, Object?> json) {
    return RuijieCloudDevice(
      id: _valueFor(json, ['id', 'deviceId', 'device_id', 'mac']),
      name: _valueFor(json, ['name', 'deviceName', 'device_name', 'hostname']),
      model: _optionalValue(json, ['model', 'deviceModel', 'device_model']),
      serialNumber: _optionalValue(json, [
        'sn',
        'serialNumber',
        'serial_number',
      ]),
      status: _optionalValue(json, ['status', 'deviceStatus', 'device_status']),
      siteName: _optionalValue(json, ['siteName', 'site_name', 'projectName']),
    );
  }

  static String _valueFor(Map<String, Object?> json, List<String> keys) {
    return _optionalValue(json, keys) ?? '';
  }

  static String? _optionalValue(Map<String, Object?> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }
}
