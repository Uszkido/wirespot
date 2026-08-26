import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/branding/app_branding.dart';
import '../../../core/di/providers.dart';
import '../../../core/router/app_routes.dart';
import '../../settings/domain/entities/app_settings.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await ref
        .read(settingsRepositoryProvider)
        .writeSetting(AppSettingsKeys.hasCompletedOnboarding, 'true');
    if (!mounted) return;
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppBranding.appName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (_currentPage < 3)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text('Skip'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildWelcomePage(theme),
                  _buildRouterSetupPage(theme),
                  _buildVpnSetupPage(theme),
                  _buildCloudBackupPage(theme),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      4,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      if (_currentPage < 3) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    icon: Icon(
                      _currentPage == 3
                          ? Icons.check_circle_outline
                          : Icons.arrow_forward,
                    ),
                    label: Text(_currentPage == 3 ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_tethering_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to ${AppBranding.appName}',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppBranding.poweredByLine,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'The complete hotspot management, multi-vendor router control, '
            'and ticketing platform for internet operators.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildRouterSetupPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.router_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            'Multi-Vendor Router Fleet',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Connect and manage MikroTik RouterOS, TP-Link Omada, Ubiquiti UniFi, '
            'Ruijie Cloud, OpenWrt, and Generic routers with unified control.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.newRouter),
            icon: const Icon(Icons.add),
            label: const Text('Add First Router Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildVpnSetupPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.vpn_key_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            'Standalone WireGuard VPN',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'WireSpot features a fully standalone WireGuard VPN engine. '
            'Import raw .conf configuration files to manage remote router tunnels directly.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.wireGuard),
            icon: const Icon(Icons.tune),
            label: const Text('Manage WireGuard Tunnels'),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudBackupPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_sync_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            'WhatsApp-Style Cloud Backup',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your hotspot profiles, vouchers, router fleet, and settings are '
            'automatically backed up to the cloud. On fresh installs, your data auto-restores in seconds.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
