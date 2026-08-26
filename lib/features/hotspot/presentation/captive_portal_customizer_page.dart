import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/entities/captive_portal_template.dart';
import '../domain/services/captive_portal_service.dart';

class CaptivePortalCustomizerPage extends StatefulWidget {
  const CaptivePortalCustomizerPage({super.key});

  @override
  State<CaptivePortalCustomizerPage> createState() =>
      _CaptivePortalCustomizerPageState();
}

class _CaptivePortalCustomizerPageState
    extends State<CaptivePortalCustomizerPage> {
  late CaptivePortalTemplate _template;
  final CaptivePortalService _portalService = const CaptivePortalService();
  CaptivePortalVendor _selectedVendor = CaptivePortalVendor.mikrotik;

  late TextEditingController _businessNameCtrl;
  late TextEditingController _headlineCtrl;
  late TextEditingController _taglineCtrl;
  late TextEditingController _buttonLabelCtrl;
  late TextEditingController _supportContactCtrl;

  @override
  void initState() {
    super.initState();
    _template = CaptivePortalTemplate.defaultTemplate();
    _businessNameCtrl = TextEditingController(text: _template.businessName);
    _headlineCtrl = TextEditingController(text: _template.welcomeHeadline);
    _taglineCtrl = TextEditingController(text: _template.tagline);
    _buttonLabelCtrl = TextEditingController(text: _template.loginButtonLabel);
    _supportContactCtrl = TextEditingController(text: _template.supportContact);
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _headlineCtrl.dispose();
    _taglineCtrl.dispose();
    _buttonLabelCtrl.dispose();
    _supportContactCtrl.dispose();
    super.dispose();
  }

  void _exportHtml() {
    final html = _portalService.generateHtml(
      _template,
      vendor: _selectedVendor,
    );
    Clipboard.setData(ClipboardData(text: html));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exported HTML for ${_selectedVendor.name.toUpperCase()} copied to clipboard!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Captive Portal Customizer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy HTML',
            onPressed: _exportHtml,
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target Router Platform',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<CaptivePortalVendor>(
                    segments: const [
                      ButtonSegment(
                        value: CaptivePortalVendor.mikrotik,
                        label: Text('MikroTik'),
                      ),
                      ButtonSegment(
                        value: CaptivePortalVendor.openwrt,
                        label: Text('OpenWrt'),
                      ),
                      ButtonSegment(
                        value: CaptivePortalVendor.ruijie,
                        label: Text('Ruijie'),
                      ),
                    ],
                    selected: {_selectedVendor},
                    onSelectionChanged: (set) {
                      setState(() => _selectedVendor = set.first);
                    },
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _businessNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Business / Hotspot Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => setState(
                      () => _template = _template.copyWith(businessName: val),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _headlineCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Welcome Headline',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => setState(
                      () =>
                          _template = _template.copyWith(welcomeHeadline: val),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _taglineCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tagline & Instructions',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => setState(
                      () => _template = _template.copyWith(tagline: val),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _buttonLabelCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Button Label',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => setState(
                      () =>
                          _template = _template.copyWith(loginButtonLabel: val),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _supportContactCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Support Contact Info',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => setState(
                      () => _template = _template.copyWith(supportContact: val),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _exportHtml,
                    icon: const Icon(Icons.download),
                    label: const Text('Export Portal HTML Package'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
