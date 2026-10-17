import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../domain/entities/radius_subscriber.dart';

class RadiusSubscribersPage extends ConsumerStatefulWidget {
  const RadiusSubscribersPage({super.key});

  @override
  ConsumerState<RadiusSubscribersPage> createState() =>
      _RadiusSubscribersPageState();
}

class _RadiusSubscribersPageState extends ConsumerState<RadiusSubscribersPage> {
  static const _key = 'radius_subscribers';
  List<RadiusSubscriber> _subscribers = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await ref.read(settingsRepositoryProvider).readSetting(_key);
    if (!mounted || raw == null) return;
    final list = jsonDecode(raw);
    if (list is! List) return;
    setState(() {
      _subscribers = list
          .whereType<Map>()
          .map(
            (item) => RadiusSubscriber(
              username: '${item['username'] ?? ''}',
              password: '${item['password'] ?? ''}',
              planName: '${item['planName'] ?? ''}',
              rateLimit: '${item['rateLimit'] ?? ''}',
              sessionTimeoutSeconds: item['sessionTimeoutSeconds'] as int?,
              expiration: item['expiration'] == null
                  ? null
                  : DateTime.tryParse('${item['expiration']}'),
              disabled: item['disabled'] == true,
            ),
          )
          .toList();
    });
  }

  Future<void> _save() async {
    await ref
        .read(settingsRepositoryProvider)
        .writeSetting(
          _key,
          jsonEncode(
            _subscribers
                .map(
                  (item) => {
                    'username': item.username,
                    'password': item.password,
                    'planName': item.planName,
                    'rateLimit': item.rateLimit,
                    'sessionTimeoutSeconds': item.sessionTimeoutSeconds,
                    'expiration': item.expiration?.toIso8601String(),
                    'disabled': item.disabled,
                  },
                )
                .toList(),
          ),
        );
  }

  Future<void> _addSubscriber() async {
    final result = await showDialog<RadiusSubscriber>(
      context: context,
      builder: (context) => const _SubscriberDialog(),
    );
    if (result == null) return;
    setState(() => _subscribers = [..._subscribers, result]);
    await _save();
  }

  Future<void> _toggle(RadiusSubscriber subscriber) async {
    final replacement = RadiusSubscriber(
      username: subscriber.username,
      password: subscriber.password,
      planName: subscriber.planName,
      rateLimit: subscriber.rateLimit,
      sessionTimeoutSeconds: subscriber.sessionTimeoutSeconds,
      expiration: subscriber.expiration,
      disabled: !subscriber.disabled,
      dataLimitBytes: subscriber.dataLimitBytes,
    );
    setState(
      () => _subscribers = [
        for (final item in _subscribers)
          item.username == subscriber.username ? replacement : item,
      ],
    );
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PPPoE subscribers'),
        actions: [
          IconButton(
            onPressed: _addSubscriber,
            tooltip: 'Add subscriber',
            icon: const Icon(Icons.person_add_alt_1),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSubscriber,
        icon: const Icon(Icons.add),
        label: const Text('Add subscriber'),
      ),
      body: _subscribers.isEmpty
          ? const Center(child: Text('No PPPoE subscribers yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _subscribers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final subscriber = _subscribers[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      subscriber.disabled
                          ? Icons.person_off_outlined
                          : Icons.person_outline,
                    ),
                    title: Text(subscriber.username),
                    subtitle: Text(
                      '${subscriber.planName} • ${subscriber.rateLimit}',
                    ),
                    trailing: Switch(
                      value: !subscriber.disabled,
                      onChanged: (_) => _toggle(subscriber),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _SubscriberDialog extends StatefulWidget {
  const _SubscriberDialog();

  @override
  State<_SubscriberDialog> createState() => _SubscriberDialogState();
}

class _SubscriberDialogState extends State<_SubscriberDialog> {
  final username = TextEditingController();
  final password = TextEditingController();
  final plan = TextEditingController(text: 'Standard');
  final rate = TextEditingController(text: '5M/5M');

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    plan.dispose();
    rate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add PPPoE subscriber'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: username,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: plan,
              decoration: const InputDecoration(labelText: 'Plan name'),
            ),
            TextField(
              controller: rate,
              decoration: const InputDecoration(
                labelText: 'Rate limit',
                hintText: '5M/5M',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final item = RadiusSubscriber(
              username: username.text.trim(),
              password: password.text,
              planName: plan.text.trim(),
              rateLimit: rate.text.trim(),
            );
            if (item.validationErrors.isNotEmpty) return;
            Navigator.pop(context, item);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
