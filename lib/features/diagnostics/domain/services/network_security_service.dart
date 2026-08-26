import '../../../hotspot/domain/entities/hotspot_active_session_entity.dart';
import '../../../routers/domain/entities/router_entity.dart';

class BandwidthHogReport {
  const BandwidthHogReport({
    required this.session,
    required this.consumedMb,
    required this.isAbusive,
  });

  final HotspotActiveSessionEntity session;
  final double consumedMb;
  final bool isAbusive;
}

class NetworkSecurityService {
  const NetworkSecurityService();

  List<BandwidthHogReport> detectBandwidthHogs(
    List<HotspotActiveSessionEntity> sessions, {
    double thresholdMb = 500.0,
  }) {
    final reports = <BandwidthHogReport>[];
    for (final session in sessions) {
      final bytesIn = session.bytesIn ?? 0;
      final bytesOut = session.bytesOut ?? 0;
      final totalMb = (bytesIn + bytesOut) / (1024 * 1024);

      if (totalMb >= thresholdMb) {
        reports.add(
          BandwidthHogReport(
            session: session,
            consumedMb: totalMb,
            isAbusive: totalMb >= (thresholdMb * 2),
          ),
        );
      }
    }
    return reports;
  }

  List<String> detectRogueAccessPoints(
    List<RouterEntity> routers,
    List<String> discoveredBssids,
  ) {
    final knownMacs = routers.map((r) => r.host.toLowerCase()).toSet();

    final rogueBssids = <String>[];
    for (final bssid in discoveredBssids) {
      if (!knownMacs.contains(bssid.toLowerCase())) {
        rogueBssids.add(bssid);
      }
    }
    return rogueBssids;
  }
}
