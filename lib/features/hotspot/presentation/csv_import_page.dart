import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../routers/presentation/router_providers.dart';
import '../domain/entities/hotspot_user_input.dart';

class CsvImportPage extends ConsumerStatefulWidget {
  const CsvImportPage({super.key});

  @override
  ConsumerState<CsvImportPage> createState() => _CsvImportPageState();
}

class _CsvImportPageState extends ConsumerState<CsvImportPage> {
  PlatformFile? _file;
  List<HotspotUserInput>? _users;
  String? _error;
  bool _isImporting = false;
  int _importProgress = 0;
  bool _success = false;

  Future<void> _pickFile() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (file == null) return;

    setState(() {
      _file = file;
      _error = null;
      _users = null;
      _success = false;
      _isImporting = false;
      _importProgress = 0;
    });

    try {
      final parsedUsers = await ref
          .read(csvImportServiceProvider)
          .parseCsv(file);
      setState(() {
        _users = parsedUsers;
      });
    } on Object catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _import() async {
    if (_users == null || _users!.isEmpty) return;

    final router = ref
        .read(routersProvider)
        .asData
        ?.value
        .firstWhere(
          (r) => r.id == ref.read(selectedRouterIdProvider),
          orElse: () => ref.read(routersProvider).asData!.value.first,
        );

    if (router == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active router selected.')),
        );
      }
      return;
    }

    setState(() {
      _isImporting = true;
      _error = null;
      _importProgress = 0;
    });

    try {
      await ref
          .read(csvImportServiceProvider)
          .importUsers(
            router,
            _users!,
            onProgress: (current, total) {
              if (mounted) {
                setState(() {
                  _importProgress = current;
                });
              }
            },
          );

      setState(() {
        _success = true;
        _isImporting = false;
      });
    } on Object catch (e) {
      setState(() {
        _error = 'Import failed: $e';
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CSV Bulk Import')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.upload_file,
                        size: 48,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _file == null
                            ? 'Select a CSV file to import users.'
                            : 'Selected: ${_file!.name}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _isImporting || _success ? null : _pickFile,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Browse Files'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (_success)
                Card(
                  color: Colors.green.shade50,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Import Successful!',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Successfully imported ${_users!.length} users.'),
                      ],
                    ),
                  ),
                ),
              if (_isImporting)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Importing user $_importProgress of ${_users!.length}...',
                    ),
                  ],
                ),
              if (_users != null && !_isImporting && !_success)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Preview (${_users!.length} users parsed):',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.separated(
                            itemCount: _users!.length > 10
                                ? 10
                                : _users!.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final user = _users![index];
                              return ListTile(
                                dense: true,
                                title: Text(user.username),
                                subtitle: Text(
                                  'Profile: ${user.profile ?? 'default'} | Uptime limit: ${user.limitUptime ?? 'none'}',
                                ),
                                trailing: Text(
                                  user.password.isNotEmpty ? '***' : 'No pass',
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (_users!.length > 10)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '...and ${_users!.length - 10} more rows',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _import,
                        child: const Text('Start Import'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
