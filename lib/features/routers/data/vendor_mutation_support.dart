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
