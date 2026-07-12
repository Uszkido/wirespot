import '../../../../core/utils/id_generator.dart';
import '../../../hotspot/domain/entities/hotspot_user_input.dart';
import '../../../hotspot/domain/services/hotspot_service.dart';
import '../../../routers/domain/entities/router_entity.dart';
import '../entities/voucher_encoding_settings.dart';
import '../entities/voucher_entity.dart';
import '../entities/voucher_generation_request.dart';
import '../repositories/voucher_repository.dart';
import 'voucher_code_generator.dart';

class VoucherGenerationService {
  const VoucherGenerationService({
    required VoucherRepository repository,
    required VoucherCodeGenerator codeGenerator,
    HotspotService? hotspotService,
  }) : _repository = repository,
       _codeGenerator = codeGenerator,
       _hotspotService = hotspotService;

  final VoucherRepository _repository;
  final VoucherCodeGenerator _codeGenerator;
  final HotspotService? _hotspotService;

  Future<List<VoucherEntity>> generate(
    VoucherGenerationRequest request, {
    RouterEntity? router,
  }) async {
    _validate(request);
    if (request.provisionOnRouter &&
        (router == null || _hotspotService == null)) {
      throw ArgumentError(
        'RouterOS provisioning requires a router and hotspot service.',
      );
    }

    final vouchers = <VoucherEntity>[];
    for (var index = 0; index < request.quantity; index++) {
      final username = _username(request);
      final password = _password(request);
      final voucher = VoucherEntity(
        id: IdGenerator.timestampId('voucher'),
        routerId: request.routerId,
        profileId: request.profileId,
        username: username,
        password: password,
        priceMinor: request.priceMinor ?? request.plan.priceMinor,
        currency: request.plan.currency,
        validityMinutes: request.plan.validityMinutes,
        generatedAt: DateTime.now(),
        note: request.note ?? request.plan.name,
      );
      await _repository.saveVoucher(voucher);
      if (request.provisionOnRouter) {
        await _hotspotService!.createUser(
          router!,
          HotspotUserInput(
            username: voucher.username,
            password: voucher.password ?? '',
            profile: request.routerOsProfile,
            comment: 'WireSpot voucher ${voucher.id}',
            limitUptime: _routerOsDuration(request.plan.validityMinutes),
            limitBytesTotal: request.limitBytesTotal,
          ),
        );
      }
      vouchers.add(voucher);
    }

    return vouchers;
  }

  void _validate(VoucherGenerationRequest request) {
    if (request.routerId.trim().isEmpty) {
      throw ArgumentError.value(request.routerId, 'routerId', 'Required');
    }
    if (request.quantity < 1 || request.quantity > 500) {
      throw ArgumentError.value(request.quantity, 'quantity', 'Use 1 to 500');
    }
    if (request.usernameLength <
            request.encodingSettings.safeUsernameMinLength ||
        request.usernameLength >
            request.encodingSettings.safeUsernameMaxLength) {
      throw ArgumentError.value(
        request.usernameLength,
        'usernameLength',
        'Use the configured username length range',
      );
    }
    if (request.encodingSettings.mode == VoucherCodeMode.usernamePassword &&
        (request.passwordLength <
                request.encodingSettings.safePasswordMinLength ||
            request.passwordLength >
                request.encodingSettings.safePasswordMaxLength)) {
      throw ArgumentError.value(
        request.passwordLength,
        'passwordLength',
        'Use the configured password length range',
      );
    }
  }

  String _username(VoucherGenerationRequest request) {
    final settings = request.encodingSettings;
    if (settings.mode == VoucherCodeMode.pinOnly) {
      return _codeGenerator.code(
        length: request.usernameLength,
        characterSet: VoucherCharacterSet.numeric,
        excludeConfusingCharacters: false,
      );
    }
    return _codeGenerator.username(
      prefix: request.usernamePrefix,
      length: request.usernameLength,
      characterSet: settings.characterSet,
      excludeConfusingCharacters: settings.excludeConfusingCharacters,
    );
  }

  String? _password(VoucherGenerationRequest request) {
    final settings = request.encodingSettings;
    if (settings.mode == VoucherCodeMode.usernameOnly ||
        settings.mode == VoucherCodeMode.pinOnly) {
      return null;
    }
    return _codeGenerator.password(
      length: request.passwordLength,
      characterSet: settings.characterSet,
      excludeConfusingCharacters: settings.excludeConfusingCharacters,
    );
  }

  String? _routerOsDuration(int? validityMinutes) {
    if (validityMinutes == null) {
      return null;
    }
    if (validityMinutes < 60) {
      return '${validityMinutes}m';
    }
    if (validityMinutes % 1440 == 0) {
      return '${validityMinutes ~/ 1440}d';
    }
    if (validityMinutes % 60 == 0) {
      return '${validityMinutes ~/ 60}h';
    }
    return '${validityMinutes}m';
  }
}
