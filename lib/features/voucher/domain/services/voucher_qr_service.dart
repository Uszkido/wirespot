import '../entities/voucher_entity.dart';

class VoucherQrService {
  const VoucherQrService();

  String hotspotLoginPayload({
    required String loginUrl,
    required VoucherEntity voucher,
  }) {
    final normalized = loginUrl.trim();
    if (normalized.isEmpty) {
      return 'username=${voucher.username}&password=${voucher.password ?? ''}';
    }

    final separator = normalized.contains('?') ? '&' : '?';
    return '$normalized${separator}username=${Uri.encodeComponent(voucher.username)}'
        '&password=${Uri.encodeComponent(voucher.password ?? '')}';
  }
}
