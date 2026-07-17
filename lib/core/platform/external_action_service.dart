import 'package:flutter/services.dart';

class ExternalActionService {
  const ExternalActionService._();

  static const _channel = MethodChannel('com.wirespot.app/external_actions');

  static Future<bool> openEmail(String email) {
    return _open(action: 'email', value: email);
  }

  static Future<bool> openPhone(String phone) {
    return _open(action: 'phone', value: phone);
  }

  static Future<bool> openWebsite(String website) {
    return _open(action: 'website', value: website);
  }

  static Future<bool> _open({
    required String action,
    required String value,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('open', {
            'action': action,
            'value': value,
          }) ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
