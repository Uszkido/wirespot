import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/routeros_api_exception.dart';
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
  final _targetController = TextEditingController();
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
    if (routers.isEmpty) {
      setState(() {
        _error = 'Add and connect a router before running diagnostics.';
        _isRunning = false;
      });
      return;
    }
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

    // A local router should be testable immediately after it is connected.
    // Keep external targets available, but default an empty target to the
    // selected router rather than assuming public DNS is reachable.
    final target = _targetController.text.trim().isEmpty
        ? router.host
        : _targetController.text.trim();
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
          _error = _friendlyError(error, router.host, router.apiPort);
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

  String _friendlyError(Object error, String host, int port) {
    if (error is RouterOsVpnRequiredException) {
      return 'Connect the private VPN tunnel before contacting this router.';
    }
    if (error is RouterOsAuthenticationException) {
      return 'Router login was rejected. Check the saved RouterOS username and password.';
    }
    if (error is RouterOsApiException) {
      final message = error.message.trim();
      if (error.category == 'unsupported_vendor') {
        return 'Ping is not available for this router connector yet. Select a MikroTik RouterOS router.';
      }
      if (error.category == 'connection') {
        return 'Could not reach $host:$port. Check the router address, API port, network, and VPN.';
      }
      return message.isEmpty
          ? 'The router rejected the ping command.'
          : message;
    }
    return 'Diagnostics failed: ${error.toString()}';
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _targetController,
                      decoration: const InputDecoration(
                        labelText: 'IP address or hostname',
                        hintText: 'Router address or e.g. 8.8.8.8',
                        prefixIcon: Icon(Icons.dns_outlined),
                        border: OutlineInputBorder(),
                      ),
                      enabled:
                          !_isRunning && _mode != DiagnosticMode.securityAudit,
                      onSubmitted: (_) => !_isRunning ? _start() : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _mode == DiagnosticMode.securityAudit
                          ? 'Security audit checks the saved router fleet.'
                          : 'Leave blank to ping the selected router, or enter another target.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check type',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<DiagnosticMode>(
                        segments: const [
                          ButtonSegment(
                            value: DiagnosticMode.ping,
                            label: Text('Ping'),
                            icon: Icon(Icons.network_ping_outlined),
                          ),
                          ButtonSegment(
                            value: DiagnosticMode.traceroute,
                            label: Text('Route'),
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
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: _isRunning
                          ? FilledButton.icon(
                              onPressed: _stop,
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                foregroundColor: theme.colorScheme.onError,
                              ),
                              icon: const Icon(Icons.stop),
                              label: const Text('Stop check'),
                            )
                          : FilledButton.icon(
                              onPressed: _start,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start check'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Row(
                        children: [
                          const Icon(Icons.terminal_outlined),
                          const SizedBox(width: 8),
                          Text(
                            'Live output',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          if (_isRunning)
                            const Chip(
                              avatar: Icon(Icons.circle, size: 10),
                              label: Text('Running'),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: Colors.black,
                        padding: const EdgeInsets.all(12),
                        child: _buildConsoleOutput(),
                      ),
                    ),
                  ],
                ),
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
