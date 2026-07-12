enum VoucherCodeMode { usernamePassword, usernameOnly, pinOnly }

enum VoucherCharacterSet { numeric, alphabetic, alphanumeric }

class VoucherEncodingSettings {
  const VoucherEncodingSettings({
    this.mode = VoucherCodeMode.usernamePassword,
    this.characterSet = VoucherCharacterSet.alphanumeric,
    this.defaultPrefix = 'WS',
    this.usernameMinLength = 4,
    this.usernameMaxLength = 10,
    this.passwordMinLength = 4,
    this.passwordMaxLength = 10,
    this.excludeConfusingCharacters = true,
  });

  final VoucherCodeMode mode;
  final VoucherCharacterSet characterSet;
  final String defaultPrefix;
  final int usernameMinLength;
  final int usernameMaxLength;
  final int passwordMinLength;
  final int passwordMaxLength;
  final bool excludeConfusingCharacters;

  int get safeUsernameMinLength =>
      usernameMinLength < 4 ? 4 : usernameMinLength;

  int get safeUsernameMaxLength => usernameMaxLength < safeUsernameMinLength
      ? safeUsernameMinLength
      : usernameMaxLength;

  int get safePasswordMinLength =>
      passwordMinLength < 4 ? 4 : passwordMinLength;

  int get safePasswordMaxLength => passwordMaxLength < safePasswordMinLength
      ? safePasswordMinLength
      : passwordMaxLength;

  int get defaultUsernameLength => safeUsernameMinLength;

  int get defaultPasswordLength => safePasswordMinLength;

  Map<String, String> toSettingsMap() {
    return {
      'voucher.encoding.mode': mode.name,
      'voucher.encoding.characterSet': characterSet.name,
      'voucher.encoding.defaultPrefix': defaultPrefix,
      'voucher.encoding.usernameMinLength': '$usernameMinLength',
      'voucher.encoding.usernameMaxLength': '$usernameMaxLength',
      'voucher.encoding.passwordMinLength': '$passwordMinLength',
      'voucher.encoding.passwordMaxLength': '$passwordMaxLength',
      'voucher.encoding.excludeConfusingCharacters': excludeConfusingCharacters
          ? 'true'
          : 'false',
    };
  }

  static VoucherEncodingSettings fromSettings(Map<String, String?> values) {
    return VoucherEncodingSettings(
      mode: VoucherCodeMode.values.firstWhere(
        (item) => item.name == values['voucher.encoding.mode'],
        orElse: () => VoucherCodeMode.usernamePassword,
      ),
      characterSet: VoucherCharacterSet.values.firstWhere(
        (item) => item.name == values['voucher.encoding.characterSet'],
        orElse: () => VoucherCharacterSet.alphanumeric,
      ),
      defaultPrefix: values['voucher.encoding.defaultPrefix'] ?? 'WS',
      usernameMinLength: _intValue(
        values['voucher.encoding.usernameMinLength'],
        fallback: 4,
      ),
      usernameMaxLength: _intValue(
        values['voucher.encoding.usernameMaxLength'],
        fallback: 10,
      ),
      passwordMinLength: _intValue(
        values['voucher.encoding.passwordMinLength'],
        fallback: 4,
      ),
      passwordMaxLength: _intValue(
        values['voucher.encoding.passwordMaxLength'],
        fallback: 10,
      ),
      excludeConfusingCharacters:
          values['voucher.encoding.excludeConfusingCharacters'] != 'false',
    );
  }

  static int _intValue(String? value, {required int fallback}) {
    return int.tryParse(value ?? '') ?? fallback;
  }
}
