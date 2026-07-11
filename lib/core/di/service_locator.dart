import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/authentication/domain/services/auth_service.dart';
import '../../features/authentication/domain/services/biometric_auth_service.dart';
import '../../features/authentication/domain/services/pin_hash_service.dart';
import '../../features/hotspot/data/routeros_hotspot_service.dart';
import '../../features/hotspot/domain/services/hotspot_service.dart';
import '../../features/reports/data/report_local_repository.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/domain/services/report_export_service.dart';
import '../../features/reports/domain/services/report_summary_service.dart';
import '../../features/routers/data/routeros_connection_service.dart';
import '../../features/routers/data/router_local_repository.dart';
import '../../features/routers/domain/repositories/router_repository.dart';
import '../../features/routers/domain/services/router_connection_service.dart';
import '../../features/settings/data/settings_local_repository.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/services/app_settings_service.dart';
import '../../features/settings/domain/services/backup_service.dart';
import '../../features/voucher/data/voucher_local_repository.dart';
import '../../features/voucher/domain/repositories/voucher_repository.dart';
import '../../features/voucher/domain/services/voucher_code_generator.dart';
import '../../features/voucher/domain/services/voucher_generation_service.dart';
import '../../features/voucher/domain/services/voucher_qr_service.dart';
import '../../features/voucher/domain/services/voucher_receipt_template_service.dart';
import '../database/app_database.dart';
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
      () => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      ),
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
      () => RouterLocalRepository(
        sl<AppDatabase>(),
        sl<RouterCredentialStore>(),
      ),
    )
    ..registerLazySingleton<RouterConnectionService>(
      () => RouterOsConnectionService(
        clientFactory: sl<RouterOsClientFactory>(),
        credentialStore: sl<RouterCredentialStore>(),
        vpnStatusService: sl<VpnStatusService>(),
      ),
    )
    ..registerLazySingleton<HotspotService>(
      () => RouterOsHotspotService(sl<RouterConnectionService>()),
    )
    ..registerLazySingleton<VoucherRepository>(
      () => VoucherLocalRepository(
        sl<AppDatabase>(),
        sl<VoucherSecretStore>(),
      ),
    )
    ..registerLazySingleton<VoucherCodeGenerator>(VoucherCodeGenerator.new)
    ..registerLazySingleton<VoucherQrService>(VoucherQrService.new)
    ..registerLazySingleton<VoucherReceiptTemplateService>(
      () => VoucherReceiptTemplateService(sl<VoucherQrService>()),
    )
    ..registerLazySingleton<VoucherGenerationService>(
      () => VoucherGenerationService(
        repository: sl<VoucherRepository>(),
        codeGenerator: sl<VoucherCodeGenerator>(),
        hotspotService: sl<HotspotService>(),
      ),
    )
    ..registerLazySingleton<ReportRepository>(
      () => ReportLocalRepository(sl<AppDatabase>()),
    )
    ..registerLazySingleton<ReportSummaryService>(
      () => ReportSummaryService(sl<ReportRepository>()),
    )
    ..registerLazySingleton<ReportExportService>(ReportExportService.new)
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsLocalRepository(sl<AppDatabase>()),
    )
    ..registerLazySingleton<AppSettingsService>(
      () => AppSettingsService(sl<SettingsRepository>()),
    )
    ..registerLazySingleton<BackupService>(
      () => BackupService(sl<SettingsRepository>()),
    );
}
