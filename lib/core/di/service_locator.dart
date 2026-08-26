import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/authentication/domain/services/auth_service.dart';
import '../../features/authentication/domain/services/biometric_auth_service.dart';
import '../../features/authentication/domain/services/pin_hash_service.dart';
import '../../features/cloud/data/cloud_api_client.dart';
import '../../features/cloud/data/cloud_sync_local_repository.dart';
import '../../features/cloud/domain/repositories/cloud_sync_repository.dart';
import '../../features/cloud/domain/services/cloud_backup_service.dart';
import '../../features/cloud/domain/services/cloud_settings_service.dart';
import '../../features/cloud/domain/services/cloud_sync_service.dart';
import '../../features/hotspot/data/routeros_hotspot_service.dart';
import '../../features/hotspot/data/hotspot_deployment_local_repository.dart';
import '../../features/hotspot/domain/repositories/hotspot_deployment_repository.dart';
import '../../features/hotspot/domain/services/hotspot_deployment_service.dart';
import '../../features/hotspot/domain/services/hotspot_service.dart';
import '../../features/reports/data/report_local_repository.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/domain/services/report_export_service.dart';
import '../../features/reports/domain/services/report_summary_service.dart';
import '../../features/diagnostics/domain/services/network_diagnostics_service.dart';
import '../../features/hotspot/domain/services/csv_import_service.dart';
import '../../features/alerts/domain/services/router_alert_service.dart';
import '../../core/notifications/notification_service.dart';
import '../../features/routers/data/generic_router_connection_service.dart';
import '../../features/routers/data/multi_vendor_router_connection_service.dart';
import '../../features/routers/data/omada_connection_service.dart';
import '../../features/routers/data/openwrt_connection_service.dart';
import '../../features/routers/data/routeros_connection_service.dart';
import '../../features/routers/data/router_local_repository.dart';
import '../../features/routers/data/ruijie_cloud_connection_service.dart';
import '../../features/routers/data/unifi_connection_service.dart';
import '../../features/routers/domain/repositories/router_repository.dart';
import '../../features/routers/domain/services/router_connection_service.dart';
import '../../features/routers/domain/services/router_fleet_connection_service.dart';
import '../../features/routers/domain/services/active_router_service.dart';
import '../../features/scheduler/domain/services/scheduler_execution_service.dart';
import '../../features/scheduler/domain/services/scheduler_settings_service.dart';
import '../../features/settings/data/settings_local_repository.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/services/app_settings_service.dart';
import '../../features/settings/domain/services/backup_service.dart';
import '../../features/vpn/domain/services/wireguard_settings_service.dart';
import '../../features/voucher/data/voucher_local_repository.dart';
import '../../features/voucher/domain/repositories/voucher_repository.dart';
import '../../features/voucher/domain/services/voucher_code_generator.dart';
import '../../features/voucher/domain/services/voucher_encoding_settings_service.dart';
import '../../features/voucher/domain/services/voucher_generation_service.dart';
import '../../features/voucher/domain/services/voucher_export_service.dart';
import '../../features/voucher/domain/services/voucher_pdf_service.dart';
import '../../features/voucher/domain/services/ticket_template_settings_service.dart';
import '../../features/voucher/domain/services/voucher_qr_service.dart';
import '../../features/voucher/domain/services/voucher_receipt_template_service.dart';
import '../database/app_database.dart';
import '../licensing/entitlement_service.dart';
import '../network/http_client_factory.dart';
import '../api/routeros_client_factory.dart';
import '../printer/platform_printer_service.dart';
import '../printer/printer_service.dart';
import '../share/platform_share_service.dart';
import '../share/share_service.dart';
import '../storage/router_credential_store.dart';
import '../storage/secure_storage_service.dart';
import '../storage/voucher_secret_store.dart';
import '../vpn/platform_wireguard_vpn_service.dart';
import '../vpn/vpn_status_service.dart';
import '../vpn/wireguard_auto_reconnect_service.dart';
import '../vpn/wireguard_vpn_service.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (sl.isRegistered<Dio>()) {
    return;
  }

  sl
    ..registerLazySingleton<Dio>(HttpClientFactory.create)
    ..registerLazySingleton<AppDatabase>(AppDatabase.new)
    ..registerLazySingleton<RouterOsClientFactory>(RouterOsClientFactory.new)
    ..registerLazySingleton<PrinterService>(PlatformPrinterService.new)
    ..registerLazySingleton<ShareService>(PlatformShareService.new)
    ..registerLazySingleton<PinHashService>(PinHashService.new)
    ..registerLazySingleton<BiometricAuthService>(BiometricAuthService.new)
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(aOptions: AndroidOptions()),
    )
    ..registerLazySingleton<SecureStorageService>(
      () => SecureStorageService(sl<FlutterSecureStorage>()),
    )
    ..registerLazySingleton<AuthService>(
      () => AuthService(
        secureStorage: sl<SecureStorageService>(),
        pinHashService: sl<PinHashService>(),
        biometricAuthService: sl<BiometricAuthService>(),
      ),
    )
    ..registerLazySingleton<CloudSettingsService>(
      () => CloudSettingsService(sl<SecureStorageService>()),
    )
    ..registerLazySingleton<CloudApiClient>(
      () => CloudApiClient(
        dio: sl<Dio>(),
        settingsService: sl<CloudSettingsService>(),
      ),
    )
    ..registerLazySingleton<CloudSyncRepository>(
      () => CloudSyncLocalRepository(sl<AppDatabase>()),
    )
    ..registerLazySingleton<CloudSyncService>(
      () => CloudSyncService(
        repository: sl<CloudSyncRepository>(),
        apiClient: sl<CloudApiClient>(),
      ),
    )
    ..registerLazySingleton<RouterCredentialStore>(
      () => RouterCredentialStore(sl<SecureStorageService>()),
    )
    ..registerLazySingleton<VoucherSecretStore>(
      () => VoucherSecretStore(sl<SecureStorageService>()),
    )
    ..registerLazySingleton<WireGuardVpnService>(
      () => PlatformWireGuardVpnService(
        secureStorage: sl<SecureStorageService>(),
      ),
    )
    ..registerLazySingleton<VpnStatusService>(
      () => VpnStatusService(sl<WireGuardVpnService>()),
    )
    ..registerLazySingleton<WireGuardAutoReconnectService>(
      () => WireGuardAutoReconnectService(sl<WireGuardVpnService>()),
    )
    ..registerLazySingleton<RouterRepository>(
      () =>
          RouterLocalRepository(sl<AppDatabase>(), sl<RouterCredentialStore>()),
    )
    ..registerLazySingleton<RuijieCloudConnectionService>(
      () => RuijieCloudConnectionService(
        credentialStore: sl<RouterCredentialStore>(),
      ),
    )
    ..registerLazySingleton<OpenWrtConnectionService>(
      OpenWrtConnectionService.new,
    )
    ..registerLazySingleton<OmadaConnectionService>(OmadaConnectionService.new)
    ..registerLazySingleton<UniFiConnectionService>(UniFiConnectionService.new)
    ..registerLazySingleton<GenericRouterConnectionService>(
      GenericRouterConnectionService.new,
    )
    ..registerLazySingleton<RouterConnectionService>(
      () => MultiVendorRouterConnectionService(
        connectors: [
          RouterOsConnectionService(
            clientFactory: sl<RouterOsClientFactory>(),
            credentialStore: sl<RouterCredentialStore>(),
            vpnStatusService: sl<VpnStatusService>(),
          ),
          sl<RuijieCloudConnectionService>(),
          sl<OpenWrtConnectionService>(),
          sl<OmadaConnectionService>(),
          sl<UniFiConnectionService>(),
          sl<GenericRouterConnectionService>(),
        ],
      ),
    )
    ..registerLazySingleton<RouterFleetConnectionService>(
      () => RouterFleetConnectionService(sl<RouterConnectionService>()),
    )
    ..registerLazySingleton<ActiveRouterService>(
      () => ActiveRouterService(sl<SettingsRepository>()),
    )
    ..registerLazySingleton<HotspotService>(
      () => RouterOsHotspotService(sl<RouterConnectionService>()),
    )
    ..registerLazySingleton<HotspotDeploymentRepository>(
      () => HotspotDeploymentLocalRepository(sl<AppDatabase>()),
    )
    ..registerLazySingleton<HotspotDeploymentService>(
      () => HotspotDeploymentService(
        hotspotService: sl<HotspotService>(),
        repository: sl<HotspotDeploymentRepository>(),
        cloudSyncService: sl<CloudSyncService>(),
      ),
    )
    ..registerLazySingleton<VoucherRepository>(
      () => VoucherLocalRepository(sl<AppDatabase>(), sl<VoucherSecretStore>()),
    )
    ..registerLazySingleton<VoucherCodeGenerator>(VoucherCodeGenerator.new)
    ..registerLazySingleton<VoucherEncodingSettingsService>(
      () => VoucherEncodingSettingsService(sl<SettingsRepository>()),
    )
    ..registerLazySingleton<TicketTemplateSettingsService>(
      () => TicketTemplateSettingsService(sl<SettingsRepository>()),
    )
    ..registerLazySingleton<VoucherQrService>(VoucherQrService.new)
    ..registerLazySingleton<VoucherReceiptTemplateService>(
      () => VoucherReceiptTemplateService(sl<VoucherQrService>()),
    )
    ..registerLazySingleton<VoucherGenerationService>(
      () => VoucherGenerationService(
        repository: sl<VoucherRepository>(),
        codeGenerator: sl<VoucherCodeGenerator>(),
        hotspotService: sl<HotspotService>(),
        cloudSyncService: sl<CloudSyncService>(),
      ),
    )
    ..registerLazySingleton<VoucherExportService>(VoucherExportService.new)
    ..registerLazySingleton<VoucherPdfService>(VoucherPdfService.new)
    ..registerLazySingleton<ReportRepository>(
      () => ReportLocalRepository(sl<AppDatabase>()),
    )
    ..registerLazySingleton<ReportSummaryService>(
      () => ReportSummaryService(sl<ReportRepository>()),
    )
    ..registerLazySingleton<NetworkDiagnosticsService>(
      () => NetworkDiagnosticsService(sl<RouterConnectionService>()),
    )
    ..registerLazySingleton<CsvImportService>(
      () => CsvImportService(sl<HotspotService>()),
    )
    ..registerLazySingleton<NotificationService>(NotificationService.new)
    ..registerLazySingleton<RouterAlertService>(
      () => RouterAlertService(
        connectionService: sl<RouterConnectionService>(),
        notificationService: sl<NotificationService>(),
      ),
    )
    ..registerLazySingleton<ReportExportService>(ReportExportService.new)
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsLocalRepository(sl<AppDatabase>()),
    )
    ..registerLazySingleton<AppSettingsService>(
      () => AppSettingsService(sl<SettingsRepository>()),
    )
    ..registerLazySingleton<BackupService>(
      () => BackupService(
        repository: sl<SettingsRepository>(),
        database: sl<AppDatabase>(),
        wireGuardVpnService: sl<WireGuardVpnService>(),
      ),
    )
    ..registerLazySingleton<CloudBackupService>(
      () => CloudBackupService(
        cloudApiClient: sl<CloudApiClient>(),
        backupService: sl<BackupService>(),
        settingsRepository: sl<SettingsRepository>(),
        database: sl<AppDatabase>(),
      ),
    )
    ..registerLazySingleton<SchedulerSettingsService>(
      () => SchedulerSettingsService(sl<SettingsRepository>()),
    )
    ..registerLazySingleton<SchedulerExecutionService>(
      () => SchedulerExecutionService(
        settingsService: sl<SchedulerSettingsService>(),
        backupService: sl<BackupService>(),
        reportSummaryService: sl<ReportSummaryService>(),
        routerRepository: sl<RouterRepository>(),
        hotspotService: sl<HotspotService>(),
        voucherRepository: sl<VoucherRepository>(),
        cloudSyncService: sl<CloudSyncService>(),
      ),
    )
    ..registerLazySingleton<WireGuardSettingsService>(
      () => WireGuardSettingsService(sl<SettingsRepository>()),
    )
    ..registerLazySingleton<EntitlementService>(
      () => EntitlementService(sl<SettingsRepository>()),
    );
}
