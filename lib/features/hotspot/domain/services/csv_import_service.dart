import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

import '../../../routers/domain/entities/router_entity.dart';
import '../entities/hotspot_user_input.dart';
import 'hotspot_service.dart';

class CsvImportService {
  const CsvImportService(this._hotspotService);

  final HotspotService _hotspotService;

  Future<List<HotspotUserInput>> parseCsv(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes == null) {
      throw Exception('Unable to read the CSV file bytes. Make sure the file exists and is readable.');
    }

    final csvString = utf8.decode(bytes, allowMalformed: true);
    final rows = Csv(lineDelimiter: '\n').decode(csvString);
    if (rows.isEmpty) {
      throw Exception('The CSV file is empty.');
    }

    // Attempt to guess mapping from the first row (headers).
    // If not matching any header, fallback to strict column indexes:
    // 0: username, 1: password, 2: profile, 3: limit-uptime
    final headers = rows.first.map((e) => e.toString().toLowerCase().trim()).toList();
    
    int usernameIdx = headers.indexOf('username');
    if (usernameIdx == -1) usernameIdx = headers.indexOf('user');
    int passwordIdx = headers.indexOf('password');
    if (passwordIdx == -1) passwordIdx = headers.indexOf('pass');
    
    int profileIdx = headers.indexOf('profile');
    int limitUptimeIdx = headers.indexOf('limit-uptime');
    if (limitUptimeIdx == -1) limitUptimeIdx = headers.indexOf('limituptime');
    if (limitUptimeIdx == -1) limitUptimeIdx = headers.indexOf('uptime');

    final bool hasHeaders = usernameIdx != -1;
    if (!hasHeaders) {
      // Default fallback
      usernameIdx = 0;
      passwordIdx = 1;
      profileIdx = 2;
      limitUptimeIdx = 3;
    }

    final users = <HotspotUserInput>[];
    for (int i = hasHeaders ? 1 : 0; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row.length <= usernameIdx) continue;
      
      final username = row[usernameIdx].toString().trim();
      if (username.isEmpty) continue;

      final password = row.length > passwordIdx ? row[passwordIdx].toString().trim() : '';
      final profile = row.length > profileIdx ? row[profileIdx].toString().trim() : null;
      final limitUptime = row.length > limitUptimeIdx ? row[limitUptimeIdx].toString().trim() : null;

      users.add(HotspotUserInput(
        username: username,
        password: password,
        profile: profile?.isNotEmpty == true ? profile : null,
        limitUptime: limitUptime?.isNotEmpty == true ? limitUptime : null,
        comment: 'CSV Bulk Import',
      ));
    }

    return users;
  }

  Future<void> importUsers(RouterEntity router, List<HotspotUserInput> users, {
    void Function(int current, int total)? onProgress,
  }) async {
    for (int i = 0; i < users.length; i++) {
      await _hotspotService.createUser(router, users[i]);
      onProgress?.call(i + 1, users.length);
      
      // Artificial delay to prevent overwhelming the router CPU
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }
}
