import 'package:flutter/material.dart';

Future<void> showPppoeRadiusGuide(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _PppoeRadiusGuideSheet(),
  );
}

class _PppoeRadiusGuideSheet extends StatelessWidget {
  const _PppoeRadiusGuideSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const steps = [
      (
        'Deploy FreeRADIUS',
        'Start the WireSpot radius/ Docker Compose bundle and note its private IP address.',
      ),
      (
        'Create the RADIUS client',
        'Set the router IP and a long shared secret in radius/.env, then restart FreeRADIUS.',
      ),
      (
        'Configure PPPoE',
        'In Hotspot setup, enable PPPoE subscriber access and enter the interface, pool, and RADIUS values.',
      ),
      (
        'Add subscriber plans',
        'Create users in your SQL/REST provider or the starter authorize file with rate and session limits.',
      ),
      (
        'Test safely',
        'Connect one test subscriber, confirm accounting, then enable the plan for customers.',
      ),
    ];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PPPoE + FreeRADIUS guide',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'PPPoE authenticates subscribers. FreeRADIUS applies their plans and records accounting. Router management remains through LAN, API-SSL, or the WireSpot cloud agent.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            for (var i = 0; i < steps.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 14, child: Text('${i + 1}')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[i].$1,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(steps[i].$2, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              if (i < steps.length - 1) const Divider(height: 24),
            ],
            const SizedBox(height: 12),
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Never expose UDP 1812/1813 or RouterOS API ports to the public Internet. Keep RADIUS on a private network and use the cloud agent for remote operations.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
