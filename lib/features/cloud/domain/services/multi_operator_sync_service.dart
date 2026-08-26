import 'dart:async';

enum MultiOperatorEventType {
  voucherSold,
  sessionDisconnected,
  routerOffline,
  backupCompleted,
}

class MultiOperatorEvent {
  const MultiOperatorEvent({
    required this.id,
    required this.tenantId,
    required this.operatorId,
    required this.type,
    required this.payload,
    required this.timestamp,
  });

  final String id;
  final String tenantId;
  final String operatorId;
  final MultiOperatorEventType type;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
}

class MultiOperatorSyncService {
  MultiOperatorSyncService();

  final _eventController = StreamController<MultiOperatorEvent>.broadcast();

  Stream<MultiOperatorEvent> get eventStream => _eventController.stream;

  Future<void> broadcastEvent({
    required String tenantId,
    required String operatorId,
    required MultiOperatorEventType type,
    required Map<String, dynamic> payload,
  }) async {
    final event = MultiOperatorEvent(
      id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
      tenantId: tenantId,
      operatorId: operatorId,
      type: type,
      payload: payload,
      timestamp: DateTime.now(),
    );
    _eventController.add(event);
  }

  void dispose() {
    _eventController.close();
  }
}
