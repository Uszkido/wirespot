import 'package:test/test.dart';
import 'package:wirespot_backend/auth.dart';

void main() {
  test('production configuration accepts server-owned operator tokens', () {
    final gaps = productionConfigurationGapsFor({
      'WIRESPOT_ENV': 'production',
      'WIRESPOT_OPERATOR_TOKENS': 'secret|org-a|owner',
      'WIRESPOT_STORE_PATH': '/var/data/wirespot/store.json',
    });

    expect(gaps, isEmpty);
    expect(
      localAuthEnabledFor({
        'WIRESPOT_ENV': 'production',
        'WIRESPOT_OPERATOR_TOKENS': 'secret|org-a|owner',
        'WIRESPOT_STORE_PATH': '/var/data/wirespot/store.json',
      }),
      isFalse,
    );
  });

  test('production pilot can opt into local account authentication', () {
    final environment = {
      'WIRESPOT_ENV': 'production',
      'WIRESPOT_ENABLE_LOCAL_AUTH': 'true',
      'WIRESPOT_STORE_PATH': '/var/data/wirespot/store.json',
    };

    expect(productionConfigurationGapsFor(environment), isEmpty);
    expect(localAuthEnabledFor(environment), isTrue);
  });

  test('production configuration rejects missing auth and storage controls',
      () {
    expect(
      productionConfigurationGapsFor({'WIRESPOT_ENV': 'production'}),
      containsAll(<String>[
        'WIRESPOT_OPERATOR_TOKENS or WIRESPOT_ENABLE_LOCAL_AUTH=true',
        'WIRESPOT_STORE_PATH',
      ]),
    );
  });
}
