class RouterOsSystemResource {
  const RouterOsSystemResource({
    required this.uptime,
    required this.version,
    required this.boardName,
    required this.cpuLoad,
    required this.freeMemory,
    required this.totalMemory,
    this.temperature,
  });

  final String uptime;
  final String version;
  final String boardName;
  final int cpuLoad;
  final int freeMemory;
  final int totalMemory;
  final int? temperature;

  factory RouterOsSystemResource.fromApi(Map<String, String> record) {
    return RouterOsSystemResource(
      uptime: record['uptime'] ?? '',
      version: record['version'] ?? '',
      boardName: record['board-name'] ?? '',
      cpuLoad: int.tryParse(record['cpu-load'] ?? '') ?? 0,
      freeMemory: int.tryParse(record['free-memory'] ?? '') ?? 0,
      totalMemory: int.tryParse(record['total-memory'] ?? '') ?? 0,
      temperature: int.tryParse(
        record['temperature'] ?? record['cpu-temperature'] ?? '',
      ),
    );
  }
}

class RouterOsInterface {
  const RouterOsInterface({
    required this.name,
    required this.type,
    required this.running,
    required this.disabled,
    this.macAddress,
    this.rxByte,
    this.txByte,
  });

  final String name;
  final String type;
  final bool running;
  final bool disabled;
  final String? macAddress;
  final int? rxByte;
  final int? txByte;

  factory RouterOsInterface.fromApi(Map<String, String> record) {
    return RouterOsInterface(
      name: record['name'] ?? '',
      type: record['type'] ?? '',
      running: record['running'] == 'true',
      disabled: record['disabled'] == 'true',
      macAddress: record['mac-address'],
      rxByte: int.tryParse(record['rx-byte'] ?? ''),
      txByte: int.tryParse(record['tx-byte'] ?? ''),
    );
  }
}

class RouterOsRouterSnapshot {
  const RouterOsRouterSnapshot({
    required this.identity,
    required this.resource,
    required this.interfaces,
  });

  final String identity;
  final RouterOsSystemResource resource;
  final List<RouterOsInterface> interfaces;
}
