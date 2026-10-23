import '../../../core/api/routeros_api_exception.dart';
import '../domain/entities/router_entity.dart';

RouterOsApiException unsupportedVendorMutation(
  RouterEntity router,
  String command,
) => RouterOsApiException(
  '${router.vendor.label} cannot execute $command yet. '
  'Connection testing is available, but hotspot/voucher mutations require '
  'a vendor-specific authenticated API implementation.',
  category: 'unsupported_operation',
);

RouterOsApiException unsupportedVendorSnapshot(RouterEntity router) =>
    RouterOsApiException(
      '${router.vendor.label} does not expose a normalized live snapshot yet. '
      'Use the vendor controller integration or configure MikroTik RouterOS '
      'for live CPU, memory, interface, and session telemetry.',
      category: 'unsupported_operation',
    );
