import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/routers/domain/services/mikrotik_script_generator_service.dart';

void main() {
  late MikroTikScriptGeneratorService service;

  setUp(() {
    service = const MikroTikScriptGeneratorService();
  });

  group('generateSetupScript', () {
    test('generates RouterOS v7 script with default API port', () {
      final script = service.generateSetupScript(
        username: 'wirespot',
        password: 'securePass123',
      );

      expect(script, contains('/user group add name=wirespot'));
      expect(script, contains('policy=api,read,write,test'));
      expect(script, contains('/user add name="wirespot"'));
      expect(script, contains('password="securePass123"'));
      expect(script, contains('/ip service set api disabled=no port=8728'));
      expect(script, contains('/ip service set rest disabled=no port=8080'));
      expect(
        script,
        contains('/ip hotspot user profile add name="wirespot-default"'),
      );
    });

    test('generates RouterOS v6 script without REST API', () {
      final script = service.generateSetupScript(
        username: 'wirespot',
        password: 'pass456',
        isRouterOsV7: false,
      );

      expect(script, contains('/ip service set api disabled=no port=8728'));
      expect(script, isNot(contains('/ip service set rest')));
    });

    test('enables API-SSL when requested', () {
      final script = service.generateSetupScript(
        username: 'wirespot',
        password: 'pass789',
        enableSsl: true,
      );

      expect(script, contains('/ip service set api-ssl disabled=no port=8729'));
    });

    test('uses custom API port', () {
      final script = service.generateSetupScript(
        username: 'wirespot',
        password: 'test',
        apiPort: 9000,
      );

      expect(script, contains('port=9000'));
    });

    test('escapes command-sensitive credentials', () {
      final script = service.generateSetupScript(
        username: 'wire"spot',
        password: r'p\$"ass',
      );

      expect(script, contains(r'name="wire\"spot"'));
      expect(script, contains(r'password="p\\\$\"ass"'));
    });

    test('rejects invalid API ports', () {
      expect(
        () => service.generateSetupScript(
          username: 'wirespot',
          password: 'securePass123',
          apiPort: 70000,
        ),
        throwsArgumentError,
      );
    });
  });

  group('generateOneLiner', () {
    test('produces a single-line RouterOS v7 command', () {
      final oneLiner = service.generateOneLiner(
        username: 'wirespot',
        password: 'securePass123',
      );

      expect(oneLiner, contains('/user group add name=wirespot'));
      expect(oneLiner, contains('/user add name="wirespot"'));
      expect(oneLiner, contains('/ip service set api disabled=no'));
      expect(oneLiner, contains('/ip service set rest disabled=no'));
      expect(oneLiner, isNot(contains('\n')));
    });

    test('produces a single-line RouterOS v6 command without REST', () {
      final oneLiner = service.generateOneLiner(
        username: 'wirespot',
        password: 'test',
        isRouterOsV7: false,
      );

      expect(oneLiner, isNot(contains('rest')));
      expect(oneLiner, isNot(contains('\n')));
    });
  });
}
