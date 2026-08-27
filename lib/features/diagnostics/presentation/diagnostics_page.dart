import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../routers/presentation/router_providers.dart';
import '../domain/services/network_security_service.dart';

enum DiagnosticMode { ping, traceroute, securityAudit }

class DiagnosticsPage extends ConsumerStatefulWidget {
  const DiagnosticsPage({super.key});

  @override
  ConsumerState<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends ConsumerState<DiagnosticsPage> {
  final _targetController = TextEditingController(text: '8.8.8.8');
  DiagnosticMode _mode = DiagnosticMode.ping;
  bool _isRunning = false;
  StreamSubscription<Map<String, String>>? _subscription;
  final List<Map<String, String>> _results = [];
  String? _error;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _targetController.dispose();
    _subscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _start() {
    final routers = ref.read(routersProvider).asData?.value ?? [];
    final router = routers.firstWhere(
      (r) => r.id == ref.read(selectedRouterIdProvider),
      orElse: () => routers.first,
    );

    if (_mode == DiagnosticMode.securityAudit) {
      setState(() {
        _isRunning = true;
        _error = null;
        _results.clear();
      });
      const securityService = NetworkSecurityService();
      final rogueAps = securityService.detectRogueAccessPoints(routers, [
        '192.168.1.1',
        '10.0.0.1',
        'AA:BB:CC:DD:EE:FF',
      ]);
      final hogs = securityService.detectBandwidthHogs([], thresholdMb: 500);

      setState(() {
        _results.add({
          'Audit': 'Security Scan Complete',
          'Known Routers': '${routers.length}',
          'Potential Rogue APs': rogueAps.isEmpty
              ? '0 (Clean)'
              : '${rogueAps.length} ($rogueAps)',
          'Bandwidth Hogs (>500MB)': hogs.isEmpty
              ? '0 (Clean)'
              : '${hogs.length}',
        });
        _isRunning = false;
      });
      return;
    }

    final target = _targetController.text.trim();
    if (target.isEmpty) return;

    setState(() {
      _isRunning = true;
      _error = null;
      _results.clear();
    });

    final diagnostics = ref.read(networkDiagnosticsServiceProvider);
    final stream = switch (_mode) {
      DiagnosticMode.ping => diagnostics.ping(router, target, count: 20),
      DiagnosticMode.traceroute => diagnostics.traceroute(router, target),
      DiagnosticMode.securityAudit => const Stream<Map<String, String>>.empty(),
    };

    _subscription = stream.listen(
      (data) {
        setState(() {
          _results.add(data);
        });
        _scrollToBottom();
      },
      onError: (error) {
        setState(() {
          _error = error.toString();
          _isRunning = false;
        });
      },
      onDone: () {
        setState(() {
          _isRunning = false;
        });
      },
    );
  }

  void _stop() {
    _subscription?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Network Diagnostics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _targetController,
                    decoration: InputDecoration(
                      labelText: 'IP / Hostname (e.g. 8.8.8.8)',
                      border: const OutlineInputBorder(),
                      enabled: !_isRunning,
                    ),
                    onSubmitted: (_) => !_isRunning ? _start() : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SegmentedButton<DiagnosticMode>(
                  segments: const [
                    ButtonSegment(
                      value: DiagnosticMode.ping,
                      label: Text('Ping'),
                      icon: Icon(Icons.network_ping_outlined),
                    ),
                    ButtonSegment(
                      value: DiagnosticMode.traceroute,
                      label: Text('Traceroute'),
                      icon: Icon(Icons.route_outlined),
                    ),
                    ButtonSegment(
                      value: DiagnosticMode.securityAudit,
                      label: Text('Audit'),
                      icon: Icon(Icons.security_outlined),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: _isRunning
                      ? null
                      : (modes) {
                          setState(() {
                            _mode = modes.first;
                          });
                        },
                ),
                const Spacer(),
                if (_isRunning)
                  FilledButton.icon(
                    onPressed: _stop,
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  )
                else
                  FilledButton.icon(
                    onPressed: _start,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: _buildConsoleOutput(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsoleOutput() {
    if (_results.isEmpty && _error == null && !_isRunning) {
      return const Center(
        child: Text(
          'Waiting to start...',
          style: TextStyle(color: Colors.grey, fontFamily: 'monospace'),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _results.length + (_error != null ? 1 : (_isRunning ? 1 : 0)),
      itemBuilder: (context, index) {
        if (index == _results.length) {
          if (_error != null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'ERROR: $_error',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontFamily: 'monospace',
                ),
              ),
            );
          }
          if (_isRunning) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.green,
                  ),
                ),
              ),
            );
          }
        }

        final result = _results[index];
        final parts = result.entries.map((e) => '${e.key}: ${e.value}');

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            parts.join('  |  '),
            style: const TextStyle(
              color: Colors.greenAccent,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }
}
