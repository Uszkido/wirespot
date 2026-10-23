import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../hotspot/presentation/pppoe_radius_guide.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & setup guide')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start here',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Follow the guides in order. WireSpot explains each technical value before it asks you to enter it.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _GuideTile(
            title: '1. Add your first router',
            description:
                'Choose a vendor, test the connection, and save credentials securely.',
            icon: Icons.router_outlined,
            onTap: () => showRouterConfigurationGuide(context),
          ),
          _GuideTile(
            title: '2. Connect Cloud Sync',
            description:
                'Sign in and sync routers, vouchers, subscribers, and reports across devices.',
            icon: Icons.cloud_sync_outlined,
            onTap: () => context.push(AppRoutes.cloud),
          ),
          _GuideTile(
            title: '3. Connect a router with WireGuard',
            description:
                'Import a VPN file or QR code, connect the tunnel, then add the router through its private address.',
            icon: Icons.vpn_key_outlined,
            onTap: () => showWireGuardSetupGuide(context),
          ),
          _GuideTile(
            title: '4. Configure hotspot and PPPoE',
            description:
                'Set up captive portal users, PPPoE subscriber access, and FreeRADIUS.',
            icon: Icons.wifi_tethering_outlined,
            onTap: () => showPppoeRadiusGuide(context),
          ),
          _GuideTile(
            title: '5. Manage PPPoE subscribers',
            description:
                'Create plans, assign speed limits, suspend accounts, and review status.',
            icon: Icons.manage_accounts_outlined,
            onTap: () => context.push(AppRoutes.radiusSubscribers),
          ),
          _GuideTile(
            title: '6. Create vouchers',
            description:
                'Generate, print, export, and synchronize hotspot voucher batches.',
            icon: Icons.confirmation_number_outlined,
            onTap: () => context.push(AppRoutes.vouchers),
          ),
          _GuideTile(
            title: '7. Review reports',
            description:
                'Export sales, usage, voucher, and subscriber reports.',
            icon: Icons.assessment_outlined,
            onTap: () => context.push(AppRoutes.reports),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Safety reminder: PPPoE and RADIUS authenticate subscribers. Use the WireSpot cloud agent, trusted LAN, or API-SSL firewall rules for remote router management.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ExpansionTile(
              title: const Text('Frequently asked questions'),
              children: [
                _FaqItem(
                  question: 'Do I need a VPN?',
                  answer:
                      'Not for the cloud-agent workflow. The router or mobile agent makes an outbound connection. Use a VPN or trusted LAN for direct RouterOS management.',
                ),
                _FaqItem(
                  question: 'What does PPPoE do?',
                  answer:
                      'PPPoE authenticates subscribers. FreeRADIUS checks their plan, speed, expiry, and accounting. It is not a router-management tunnel.',
                ),
                _FaqItem(
                  question: 'Why is my dashboard empty?',
                  answer:
                      'WireSpot does not fabricate live data. Complete Cloud Sync or add a router before telemetry and reports appear.',
                ),
                _FaqItem(
                  question: 'What is copied during Cloud Sync?',
                  answer:
                      'WireSpot syncs routers, hotspot users, active sessions, hotspot profiles, vouchers, router groups, WireGuard profiles, printer settings, and business settings. The app does not upload router passwords or private keys as ordinary dashboard data.',
                ),
                _FaqItem(
                  question: 'Which address should I enter for a VPN router?',
                  answer:
                      'Enter the router address reachable through the WireGuard tunnel, not its public address. Keep Require WireGuard enabled and connect the tunnel before testing the router.',
                ),
                _FaqItem(
                  question: 'Can I use WireSpot without a VPN?',
                  answer:
                      'Yes, when the phone is on the same trusted LAN as the router. Turn off Require WireGuard only for local on-site use. For remote management, use WireGuard or another private network path.',
                ),
                _FaqItem(
                  question: 'How do I recover access?',
                  answer:
                      'Use Forgot password on the sign-in screen. Production deployments need an identity provider and email delivery service.',
                ),
                _FaqItem(
                  question: 'Can I expose RADIUS ports publicly?',
                  answer:
                      'No. Keep UDP 1812/1813 and RouterOS API ports private. Use firewall restrictions, API-SSL, a trusted LAN, or the cloud agent.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showRouterConfigurationGuide(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _RouterGuideSheet(),
  );
}

Future<void> showWireGuardSetupGuide(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _WireGuardGuideSheet(),
  );
}

class _WireGuardGuideSheet extends StatelessWidget {
  const _WireGuardGuideSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set up WireGuard remote access',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'WireGuard creates a private route between this device and the router site. It is the preferred option for remote management because the RouterOS API does not need to be exposed publicly.',
            ),
            const SizedBox(height: 16),
            const _RouterGuideSection(
              title: 'Before you begin',
              steps: [
                'Ask the network administrator for a client .conf file or a WireGuard QR code.',
                'Confirm the router site has a working WireGuard server and a peer for this device.',
                'Make sure the allowed IPs include the router private address, for example 192.168.88.1/32.',
              ],
            ),
            const _RouterGuideSection(
              title: 'Connect in WireSpot',
              steps: [
                'Open WireGuard from the VPN screen or Settings > Permissions and VPN.',
                'Import the .conf file or scan the QR code, then save the tunnel with a clear site name.',
                'Tap Connect and approve the Android VPN permission prompt.',
                'Return to Routers, add the router using its private VPN address, and leave Require WireGuard enabled.',
                'Run Test connection. The router identity should match the site you intended to reach.',
              ],
            ),
            const _RouterGuideSection(
              title: 'If it does not connect',
              steps: [
                'Check that mobile data or Wi-Fi is available and another VPN is disconnected.',
                'Confirm the peer public key, endpoint, allowed IPs, and keepalive value with the network administrator.',
                'Check the router firewall and confirm RouterOS API or API-SSL is allowed from the WireGuard interface.',
                'Use local LAN mode only when the phone is physically on the router network.',
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.push(AppRoutes.wireGuard);
              },
              icon: const Icon(Icons.vpn_key),
              label: const Text('Open WireGuard'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouterGuideSheet extends StatelessWidget {
  const _RouterGuideSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configure your router',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'WireSpot needs a reachable management endpoint. Use a trusted LAN, private tunnel, or the outbound cloud agent. Never expose an unrestricted router API to the Internet.',
            ),
            const SizedBox(height: 16),
            const _RouterGuideSection(
              title: 'MikroTik RouterOS',
              steps: [
                'Create a least-privilege WireSpot user in System > Users.',
                'Enable API on port 8728 or API-SSL on 8729.',
                'Restrict the API service in IP > Services and the firewall.',
                'In WireSpot, choose MikroTik, enter the router address, port, username, and password, then run Test connection.',
              ],
            ),
            const _RouterGuideSection(
              title: 'Ruijie / Reyee',
              steps: [
                'Create an operator account in the Ruijie Cloud controller.',
                'Create a scoped API token for the target site.',
                'Select Ruijie / Reyee in WireSpot and enter the controller URL and token.',
              ],
            ),
            const _RouterGuideSection(
              title: 'OpenWrt',
              steps: [
                'Keep LuCI/ubus or SSH on the private management network.',
                'Install and configure the supported captive-portal package if hotspot service is needed.',
                'Use a scoped operator credential and test the connection from WireSpot.',
              ],
            ),
            const _RouterGuideSection(
              title: 'Omada / UniFi',
              steps: [
                'Confirm the controller is online and the target site is adopted.',
                'Create a scoped controller account or API token.',
                'Enter the HTTPS controller URL and test discovery before enabling hotspot operations.',
              ],
            ),
            const _RouterGuideSection(
              title: 'After connecting',
              steps: [
                'Run dashboard discovery and confirm the identity matches the intended router.',
                'Create a backup before applying hotspot, PPPoE, or RADIUS changes.',
                'Use the preflight checks and test one subscriber before serving customers.',
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.push(AppRoutes.routers);
              },
              icon: const Icon(Icons.router_outlined),
              label: const Text('Open router fleet'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouterGuideSection extends StatelessWidget {
  const _RouterGuideSection({required this.title, required this.steps});
  final String title;
  final List<String> steps;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    children: [
      for (var i = 0; i < steps.length; i++)
        ListTile(
          leading: CircleAvatar(radius: 12, child: Text('${i + 1}')),
          title: Text(steps[i]),
        ),
    ],
  );
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    title: Text(question, style: Theme.of(context).textTheme.bodyMedium),
    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    children: [Text(answer)],
  );
}

class _GuideTile extends StatelessWidget {
  const _GuideTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
