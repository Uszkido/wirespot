import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/di/providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../routers/domain/entities/router_entity.dart';
import '../../routers/presentation/router_providers.dart';
import '../domain/entities/voucher_entity.dart';
import '../domain/entities/voucher_generation_request.dart';
import '../domain/entities/voucher_plan.dart';
import 'voucher_providers.dart';

class VouchersPage extends ConsumerStatefulWidget {
  const VouchersPage({super.key});

  @override
  ConsumerState<VouchersPage> createState() => _VouchersPageState();
}

class _VouchersPageState extends ConsumerState<VouchersPage> {
  VoucherPlan _selectedPlan = VoucherPlan.defaults.first;
  final _quantityController = TextEditingController(text: '1');
  final _prefixController = TextEditingController(text: 'WS');
  final _routerOsProfileController = TextEditingController();
  bool _isGenerating = false;
  bool _provisionOnRouter = true;

  @override
  void dispose() {
    _quantityController.dispose();
    _prefixController.dispose();
    _routerOsProfileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routers = ref.watch(routersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vouchers')),
      body: routers.when(
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.router_outlined,
              title: 'No router available',
              message: 'Add a router before generating vouchers.',
              action: FilledButton.icon(
                onPressed: () => context.push(AppRoutes.newRouter),
                icon: const Icon(Icons.add),
                label: const Text('Add router'),
              ),
            );
          }

          final selectedId = ref.watch(selectedVoucherRouterIdProvider);
          final router = items.firstWhere(
            (item) => item.id == selectedId,
            orElse: () => items.first,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _VoucherGeneratorCard(
                routers: items,
                router: router,
                selectedPlan: _selectedPlan,
                quantityController: _quantityController,
                prefixController: _prefixController,
                routerOsProfileController: _routerOsProfileController,
                isGenerating: _isGenerating,
                provisionOnRouter: _provisionOnRouter,
                onRouterChanged: (value) {
                  ref.read(selectedVoucherRouterIdProvider.notifier).state =
                      value;
                },
                onPlanChanged: (plan) => setState(() => _selectedPlan = plan),
                onProvisionChanged: (value) {
                  setState(() => _provisionOnRouter = value);
                },
                onGenerate: () => _generate(router),
              ),
              const SizedBox(height: 20),
              _VoucherHistory(router: router),
            ],
          );
        },
        error: (error, stackTrace) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load routers',
          message: error.toString(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _generate(RouterEntity router) async {
    if (_isGenerating) {
      return;
    }
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    setState(() => _isGenerating = true);
    try {
      final vouchers = await ref.read(voucherGenerationServiceProvider).generate(
            VoucherGenerationRequest(
              routerId: router.id,
              plan: _selectedPlan,
              quantity: quantity,
              usernamePrefix: _prefixController.text.trim(),
              routerOsProfile: _routerOsProfileController.text.trim(),
              provisionOnRouter: _provisionOnRouter,
              note: _selectedPlan.name,
            ),
            router: router,
          );
      ref.invalidate(voucherHistoryProvider(router.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${vouchers.length} voucher(s) generated.')),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not generate vouchers: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}

class _VoucherGeneratorCard extends StatelessWidget {
  const _VoucherGeneratorCard({
    required this.routers,
    required this.router,
    required this.selectedPlan,
    required this.quantityController,
    required this.prefixController,
    required this.routerOsProfileController,
    required this.isGenerating,
    required this.provisionOnRouter,
    required this.onRouterChanged,
    required this.onPlanChanged,
    required this.onProvisionChanged,
    required this.onGenerate,
  });

  final List<RouterEntity> routers;
  final RouterEntity router;
  final VoucherPlan selectedPlan;
  final TextEditingController quantityController;
  final TextEditingController prefixController;
  final TextEditingController routerOsProfileController;
  final bool isGenerating;
  final bool provisionOnRouter;
  final ValueChanged<String?> onRouterChanged;
  final ValueChanged<VoucherPlan> onPlanChanged;
  final ValueChanged<bool> onProvisionChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Generate vouchers',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: router.id,
              decoration: const InputDecoration(labelText: 'Router'),
              items: [
                for (final item in routers)
                  DropdownMenuItem(value: item.id, child: Text(item.name)),
              ],
              onChanged: onRouterChanged,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<VoucherPlan>(
              initialValue: selectedPlan,
              decoration: const InputDecoration(labelText: 'Plan'),
              items: [
                for (final plan in VoucherPlan.defaults)
                  DropdownMenuItem(value: plan, child: Text(plan.name)),
              ],
              onChanged: (value) {
                if (value != null) {
                  onPlanChanged(value);
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: prefixController,
                    decoration: const InputDecoration(labelText: 'Prefix'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: provisionOnRouter,
              onChanged: onProvisionChanged,
              title: const Text('Create RouterOS users'),
              subtitle: const Text('Requires WireGuard and RouterOS API access.'),
              contentPadding: EdgeInsets.zero,
            ),
            if (provisionOnRouter) ...[
              const SizedBox(height: 12),
              TextField(
                controller: routerOsProfileController,
                decoration: const InputDecoration(
                  labelText: 'RouterOS profile',
                  helperText: 'Leave blank to use RouterOS default.',
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isGenerating ? null : onGenerate,
              icon: isGenerating
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.confirmation_number_outlined),
              label: Text(isGenerating ? 'Generating...' : 'Generate'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherHistory extends ConsumerWidget {
  const _VoucherHistory({required this.router});

  final RouterEntity router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(voucherHistoryProvider(router.id));

    return history.when(
      data: (items) {
        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.confirmation_number_outlined,
            title: 'No voucher history',
            message: 'Generated vouchers will appear here.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            for (final voucher in items)
              _VoucherTile(router: router, voucher: voucher),
          ],
        );
      },
      error: (error, stackTrace) => EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load vouchers',
        message: error.toString(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _VoucherTile extends ConsumerWidget {
  const _VoucherTile({
    required this.router,
    required this.voucher,
  });

  final RouterEntity router;
  final VoucherEntity voucher;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipt = ref.read(voucherReceiptTemplateServiceProvider).build(
          voucher: voucher,
        );

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.confirmation_number_outlined),
        title: Text(voucher.username),
        subtitle: Text(voucher.note ?? router.name),
        trailing: Text(voucher.password == null ? '' : 'QR'),
        children: [
          if (voucher.password != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: QrImageView(
                data: receipt.qrPayload,
                size: 180,
                backgroundColor: Colors.white,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SelectableText(receipt.toPlainText()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareReceipt(context, ref, voucher),
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _printReceipt(context, ref, voucher),
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('Print'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareReceipt(
    BuildContext context,
    WidgetRef ref,
    VoucherEntity voucher,
  ) async {
    final receipt = ref.read(voucherReceiptTemplateServiceProvider).build(
          voucher: voucher,
        );
    try {
      await ref.read(shareServiceProvider).shareVoucherReceipt(receipt);
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share receipt: $error')),
        );
      }
    }
  }

  Future<void> _printReceipt(
    BuildContext context,
    WidgetRef ref,
    VoucherEntity voucher,
  ) async {
    final receipt = ref.read(voucherReceiptTemplateServiceProvider).build(
          voucher: voucher,
        );
    try {
      final printers = await ref.read(printerServiceProvider).pairedBluetoothPrinters();
      if (printers.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No paired Bluetooth printers found.')),
          );
        }
        return;
      }
      final result = await ref.read(printerServiceProvider).printVoucherReceipt(
            printer: printers.first,
            receipt: receipt,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Print job sent.')),
        );
      }
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not print receipt: $error')),
        );
      }
    }
  }
}
