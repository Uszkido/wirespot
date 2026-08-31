import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/authentication/domain/services/auth_service.dart';
import '../../features/cloud/data/cloud_api_client.dart';
import '../../features/cloud/domain/repositories/cloud_sync_repository.dart';
import '../../features/cloud/domain/services/cloud_backup_service.dart';
import '../../features/cloud/domain/services/cloud_settings_service.dart';
import '../../features/cloud/domain/services/cloud_sync_service.dart';
import '../../features/hotspot/domain/services/hotspot_service.dart';
import '../../features/hotspot/domain/services/hotspot_deployment_service.dart';
import '../../features/hotspot/domain/repositories/hotspot_deployment_repository.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/domain/services/report_export_service.dart';
import '../../features/reports/domain/services/report_summary_service.dart';
import '../../features/diagnostics/domain/services/network_diagnostics_service.dart';
import '../../features/hotspot/domain/services/csv_import_service.dart';
import '../../features/alerts/domain/services/router_alert_service.dart';
import '../../features/voucher/domain/services/voucher_export_service.dart';
import '../../features/voucher/domain/services/voucher_pdf_service.dart';
import '../../features/routers/domain/repositories/router_repository.dart';
import '../../features/routers/data/ruijie_cloud_connection_service.dart';
import '../../features/routers/domain/services/router_connection_service.dart';
import '../../features/routers/domain/services/router_fleet_connection_service.dart';
import '../../features/routers/domain/services/active_router_service.dart';
import '../../features/scheduler/domain/services/scheduler_execution_service.dart';
import '../../features/scheduler/domain/services/scheduler_settings_service.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/services/app_settings_service.dart';
import '../../features/settings/domain/services/backup_service.dart';
import '../../features/vpn/domain/services/wireguard_settings_service.dart';
import '../../features/voucher/domain/repositories/voucher_repository.dart';
import '../../features/voucher/domain/services/voucher_encoding_settings_service.dart';
import '../../features/voucher/domain/services/voucher_generation_service.dart';
import '../../features/voucher/domain/services/ticket_template_settings_service.dart';
import '../../features/voucher/domain/services/voucher_qr_service.dart';
import '../../features/voucher/domain/services/voucher_receipt_template_service.dart';
import '../database/app_database.dart';
import '../licensing/entitlement_service.dart';
import '../printer/printer_service.dart';
import '../share/share_service.dart';
import '../vpn/unified_vpn_service.dart';
import '../vpn/wireguard_auto_reconnect_service.dart';
import '../vpn/wireguard_vpn_service.dart';
import 'service_locator.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) => sl<AppDatabase>());

final authServiceProvider = Provider<AuthService>((ref) => sl<AuthService>());

final cloudSettingsServiceProvider = Provider<CloudSettingsService>(
  (ref) => sl<CloudSettingsService>(),
);

final cloudApiClientProvider = Provider<CloudApiClient>(
  (ref) => sl<CloudApiClient>(),
);

final cloudSyncRepositoryProvider = Provider<CloudSyncRepository>(
  (ref) => sl<CloudSyncRepository>(),
);

final cloudSyncServiceProvider = Provider<CloudSyncService>(
  (ref) => sl<CloudSyncService>(),
);

final cloudBackupServiceProvider = Provider<CloudBackupService>(
  (ref) => sl<CloudBackupService>(),
);

final printerServiceProvider = Provider<PrinterService>(
  (ref) => sl<PrinterService>(),
);

final shareServiceProvider = Provider<ShareService>(
  (ref) => sl<ShareService>(),
);

final wireGuardVpnServiceProvider = Provider<WireGuardVpnService>(
  (ref) => sl<WireGuardVpnService>(),
);

final unifiedVpnServiceProvider = Provider<UnifiedVpnService>(
  (ref) => sl<UnifiedVpnService>(),
);

final wireGuardAutoReconnectServiceProvider =
    Provider<WireGuardAutoReconnectService>(
      (ref) => sl<WireGuardAutoReconnectService>(),
    );

final wireGuardSettingsServiceProvider = Provider<WireGuardSettingsService>(
  (ref) => sl<WireGuardSettingsService>(),
);

final routerRepositoryProvider = Provider<RouterRepository>(
  (ref) => sl<RouterRepository>(),
);

final routerConnectionServiceProvider = Provider<RouterConnectionService>(
  (ref) => sl<RouterConnectionService>(),
);

final routerFleetConnectionServiceProvider =
    Provider<RouterFleetConnectionService>(
      (ref) => sl<RouterFleetConnectionService>(),
    );

final activeRouterServiceProvider = Provider<ActiveRouterService>(
  (ref) => sl<ActiveRouterService>(),
);

final ruijieCloudConnectionServiceProvider =
    Provider<RuijieCloudConnectionService>(
      (ref) => sl<RuijieCloudConnectionService>(),
    );

final hotspotServiceProvider = Provider<HotspotService>(
  (ref) => sl<HotspotService>(),
);

final hotspotDeploymentServiceProvider = Provider<HotspotDeploymentService>(
  (ref) => sl<HotspotDeploymentService>(),
);

final hotspotDeploymentRepositoryProvider =
    Provider<HotspotDeploymentRepository>(
      (ref) => sl<HotspotDeploymentRepository>(),
    );

final voucherRepositoryProvider = Provider<VoucherRepository>(
  (ref) => sl<VoucherRepository>(),
);

final voucherGenerationServiceProvider = Provider<VoucherGenerationService>(
  (ref) => sl<VoucherGenerationService>(),
);

final voucherEncodingSettingsServiceProvider =
    Provider<VoucherEncodingSettingsService>(
      (ref) => sl<VoucherEncodingSettingsService>(),
    );

final ticketTemplateSettingsServiceProvider =
    Provider<TicketTemplateSettingsService>(
      (ref) => sl<TicketTemplateSettingsService>(),
    );

final voucherQrServiceProvider = Provider<VoucherQrService>(
  (ref) => sl<VoucherQrService>(),
);

final voucherReceiptTemplateServiceProvider =
    Provider<VoucherReceiptTemplateService>(
      (ref) => sl<VoucherReceiptTemplateService>(),
    );

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => sl<ReportRepository>(),
);

final reportSummaryServiceProvider = Provider<ReportSummaryService>(
  (ref) => sl<ReportSummaryService>(),
);

final networkDiagnosticsServiceProvider = Provider<NetworkDiagnosticsService>(
  (ref) => sl<NetworkDiagnosticsService>(),
);

final csvImportServiceProvider = Provider<CsvImportService>(
  (ref) => sl<CsvImportService>(),
);

final routerAlertServiceProvider = Provider<RouterAlertService>(
  (ref) => sl<RouterAlertService>(),
);

final reportExportServiceProvider = Provider<ReportExportService>(
  (ref) => sl<ReportExportService>(),
);

final voucherExportServiceProvider = Provider<VoucherExportService>(
  (ref) => sl<VoucherExportService>(),
);

final voucherPdfServiceProvider = Provider<VoucherPdfService>(
  (ref) => sl<VoucherPdfService>(),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => sl<SettingsRepository>(),
);

final appSettingsServiceProvider = Provider<AppSettingsService>(
  (ref) => sl<AppSettingsService>(),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => sl<BackupService>(),
);

final schedulerSettingsServiceProvider = Provider<SchedulerSettingsService>(
  (ref) => sl<SchedulerSettingsService>(),
);

final schedulerExecutionServiceProvider = Provider<SchedulerExecutionService>(
  (ref) => sl<SchedulerExecutionService>(),
);

final entitlementServiceProvider = Provider<EntitlementService>(
  (ref) => sl<EntitlementService>(),
);
