import 'routeros_api_client.dart';

class RouterOsClientFactory {
  const RouterOsClientFactory();

  RouterOsApiClient create({
    required String host,
    required int port,
    required bool useSsl,
  }) {
    return RouterOsApiClient(
      host: host,
      port: port,
      useSsl: useSsl,
    );
  }
}
