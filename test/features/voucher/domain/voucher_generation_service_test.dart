import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_user_input.dart';
import 'package:wirespot/features/hotspot/domain/services/hotspot_service.dart';
import 'package:wirespot/features/routers/domain/entities/router_entity.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_generation_request.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_entity.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_plan.dart';
import 'package:wirespot/features/voucher/domain/repositories/voucher_repository.dart';
import 'package:wirespot/features/voucher/domain/services/voucher_code_generator.dart';
import 'package:wirespot/features/voucher/domain/services/voucher_generation_service.dart';

void main() {
  late _VoucherRepository repository;
  late _HotspotService hotspotService;
  late VoucherGenerationService service;

  setUpAll(() {
    registerFallbackValue(_router);
    registerFallbackValue(
      const HotspotUserInput(username: 'fallback', password: ''),
    );
    registerFallbackValue(
      VoucherEntity(
        id: 'fallback',
        routerId: _router.id,
        username: 'fallback',
        priceMinor: 0,
        currency: 'NGN',
        generatedAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    repository = _VoucherRepository();
    hotspotService = _HotspotService();
    service = VoucherGenerationService(
      repository: repository,
      codeGenerator: VoucherCodeGenerator(),
      hotspotService: hotspotService,
    );
  });

  test('saves a voucher only after RouterOS provisioning succeeds', () async {
    final events = <String>[];
    when(
      () => hotspotService.createUser(any(), any()),
    ).thenAnswer((_) async => events.add('provisioned'));
    when(
      () => repository.saveVoucher(any()),
    ).thenAnswer((_) async => events.add('saved'));

    final vouchers = await service.generate(
      _request(provisionOnRouter: true),
      router: _router,
    );

    expect(vouchers, hasLength(1));
    expect(events, ['provisioned', 'saved']);
    verify(
      () => hotspotService.createUser(
        _router,
        any(
          that: isA<HotspotUserInput>().having(
            (input) => input.profile,
            'profile',
            'day-pass',
          ),
        ),
      ),
    ).called(1);
    verify(() => repository.saveVoucher(any())).called(1);
  });

  test(
    'does not save a local voucher when RouterOS provisioning fails',
    () async {
      when(
        () => hotspotService.createUser(any(), any()),
      ).thenThrow(StateError('Router unavailable'));

      await expectLater(
        () => service.generate(
          _request(provisionOnRouter: true),
          router: _router,
        ),
        throwsA(isA<StateError>()),
      );

      verifyNever(() => repository.saveVoucher(any()));
    },
  );
}

final _router = RouterEntity(
  id: 'router-1',
  name: 'Field Router',
  host: '192.168.88.1',
  username: 'admin',
  requireVpn: false,
  remoteAccessMode: RouterRemoteAccessMode.localLan,
);

VoucherGenerationRequest _request({required bool provisionOnRouter}) {
  return VoucherGenerationRequest(
    routerId: _router.id,
    plan: const VoucherPlan(
      id: 'day-pass',
      name: 'Day pass',
      validityMinutes: 1440,
      priceMinor: 50000,
    ),
    routerOsProfile: 'day-pass',
    provisionOnRouter: provisionOnRouter,
  );
}

class _VoucherRepository extends Mock implements VoucherRepository {}

class _HotspotService extends Mock implements HotspotService {}
