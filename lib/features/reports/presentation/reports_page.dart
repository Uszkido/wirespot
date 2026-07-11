import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../routers/domain/entities/router_entity.dart';
import '../../routers/presentation/router_providers.dart';
import '../domain/entities/report_export.dart';
import '../domain/entities/report_period.dart';
import '../domain/entities/revenue_summary.dart';
import 'report_providers.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routers = ref.watch(routersProvider);
    final summary = ref.watch(revenueSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(revenueSummaryProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          routers.when(
            data: (items) => _ReportFilters(
              routers: items,
              selectedRouterId: ref.watch(selectedReportRouterIdProvider),
              selectedPeriod: ref.watch(selectedReportPeriodProvider),
              onRouterChanged: (value) {
                ref.read(selectedReportRouterIdProvider.notifier).state = value;
              },
              onPeriodChanged: (value) {
                ref.read(selectedReportPeriodProvider.notifier).state = value;
              },
            ),
            error: (error, stackTrace) => Text('Router filter unavailable: $error'),
            loading: () => const LinearProgressIndicator(),
          ),
          const SizedBox(height: 16),
          summary.when(
            data: (value) => _ReportContent(summary: value),
            error: (error, stackTrace) => EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load report',
              message: error.toString(),
              action: FilledButton.icon(
                onPressed: () => ref.invalidate(revenueSummaryProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}

class _ReportFilters extends StatelessWidget {
  const _ReportFilters({
    required this.routers,
    required this.selectedRouterId,
    required this.selectedPeriod,
    required this.onRouterChanged,
    required this.onPeriodChanged,
  });

  final List<RouterEntity> routers;
  final String? selectedRouterId;
  final ReportPeriod selectedPeriod;
  final ValueChanged<String?> onRouterChanged;
  final ValueChanged<ReportPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final selectedValue = selectedRouterId ?? _allRoutersValue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedValue,
              decoration: const InputDecoration(
                labelText: 'Router',
                prefixIcon: Icon(Icons.router_outlined),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: _allRoutersValue,
                  child: Text('All routers'),
                ),
                for (final router in routers)
                  DropdownMenuItem<String>(
                    value: router.id,
                    child: Text(router.name),
                  ),
              ],
              onChanged: (value) {
                onRouterChanged(value == _allRoutersValue ? null : value);
              },
            ),
            const SizedBox(height: 12),
            SegmentedButton<ReportPeriod>(
              segments: const [
                ButtonSegment(
                  value: ReportPeriod.daily,
                  icon: Icon(Icons.today_outlined),
                  label: Text('Daily'),
                ),
                ButtonSegment(
                  value: ReportPeriod.weekly,
                  icon: Icon(Icons.view_week_outlined),
                  label: Text('Weekly'),
                ),
                ButtonSegment(
                  value: ReportPeriod.monthly,
                  icon: Icon(Icons.calendar_month_outlined),
                  label: Text('Monthly'),
                ),
              ],
              selected: {selectedPeriod},
              onSelectionChanged: (value) => onPeriodChanged(value.first),
            ),
          ],
        ),
      ),
    );
  }

  static const _allRoutersValue = '__all__';
}

class _ReportContent extends ConsumerWidget {
  const _ReportContent({required this.summary});

  final RevenueSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryTile(
              icon: Icons.payments_outlined,
              label: 'Revenue',
              value: '${summary.currency} ${summary.totalMajor.toStringAsFixed(0)}',
            ),
            _SummaryTile(
              icon: Icons.receipt_long_outlined,
              label: 'Transactions',
              value: summary.transactionCount.toString(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showExport(
                  context,
                  ref,
                  ReportExportFormat.excel,
                ),
                icon: const Icon(Icons.table_chart_outlined),
                label: const Text('Excel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _showExport(
                  context,
                  ref,
                  ReportExportFormat.pdf,
                ),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('PDF'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Sales',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        if (summary.sales.isEmpty)
          const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No sales',
            message: 'Sales recorded in this period will appear here.',
          )
        else
          for (final sale in summary.sales)
            Card(
              child: ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text(
                  '${sale.currency} ${(sale.amountMinor / 100).toStringAsFixed(0)}',
                ),
                subtitle: Text(sale.note ?? sale.soldAt.toIso8601String()),
                trailing: Text(sale.paymentMethod ?? ''),
              ),
            ),
      ],
    );
  }

  Future<void> _showExport(
    BuildContext context,
    WidgetRef ref,
    ReportExportFormat format,
  ) async {
    final export = ref.read(reportExportServiceProvider).export(
          ReportExportRequest(summary: summary, format: format),
        );
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(export.fileName),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(export.content),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 170,
      height: 104,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colorScheme.primary),
              const Spacer(),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
