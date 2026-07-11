// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RoutersTable extends Routers
    with TableInfo<$RoutersTable, RouterRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _apiPortMeta = const VerificationMeta(
    'apiPort',
  );
  @override
  late final GeneratedColumn<int> apiPort = GeneratedColumn<int>(
    'api_port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(8728),
  );
  static const VerificationMeta _useSslMeta = const VerificationMeta('useSsl');
  @override
  late final GeneratedColumn<bool> useSsl = GeneratedColumn<bool>(
    'use_ssl',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("use_ssl" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _identityMeta = const VerificationMeta(
    'identity',
  );
  @override
  late final GeneratedColumn<String> identity = GeneratedColumn<String>(
    'identity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boardNameMeta = const VerificationMeta(
    'boardName',
  );
  @override
  late final GeneratedColumn<String> boardName = GeneratedColumn<String>(
    'board_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastConnectedAtMeta = const VerificationMeta(
    'lastConnectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastConnectedAt =
      GeneratedColumn<DateTime>(
        'last_connected_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    name,
    host,
    apiPort,
    useSsl,
    username,
    identity,
    version,
    boardName,
    isEnabled,
    lastConnectedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routers';
  @override
  VerificationContext validateIntegrity(
    Insertable<RouterRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('api_port')) {
      context.handle(
        _apiPortMeta,
        apiPort.isAcceptableOrUnknown(data['api_port']!, _apiPortMeta),
      );
    }
    if (data.containsKey('use_ssl')) {
      context.handle(
        _useSslMeta,
        useSsl.isAcceptableOrUnknown(data['use_ssl']!, _useSslMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('identity')) {
      context.handle(
        _identityMeta,
        identity.isAcceptableOrUnknown(data['identity']!, _identityMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('board_name')) {
      context.handle(
        _boardNameMeta,
        boardName.isAcceptableOrUnknown(data['board_name']!, _boardNameMeta),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('last_connected_at')) {
      context.handle(
        _lastConnectedAtMeta,
        lastConnectedAt.isAcceptableOrUnknown(
          data['last_connected_at']!,
          _lastConnectedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RouterRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RouterRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      apiPort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}api_port'],
      )!,
      useSsl: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}use_ssl'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      identity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identity'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      ),
      boardName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board_name'],
      ),
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      lastConnectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_connected_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RoutersTable createAlias(String alias) {
    return $RoutersTable(attachedDatabase, alias);
  }
}

class RouterRecord extends DataClass implements Insertable<RouterRecord> {
  final String id;
  final String? groupId;
  final String name;
  final String host;
  final int apiPort;
  final bool useSsl;
  final String username;
  final String? identity;
  final String? version;
  final String? boardName;
  final bool isEnabled;
  final DateTime? lastConnectedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RouterRecord({
    required this.id,
    this.groupId,
    required this.name,
    required this.host,
    required this.apiPort,
    required this.useSsl,
    required this.username,
    this.identity,
    this.version,
    this.boardName,
    required this.isEnabled,
    this.lastConnectedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['name'] = Variable<String>(name);
    map['host'] = Variable<String>(host);
    map['api_port'] = Variable<int>(apiPort);
    map['use_ssl'] = Variable<bool>(useSsl);
    map['username'] = Variable<String>(username);
    if (!nullToAbsent || identity != null) {
      map['identity'] = Variable<String>(identity);
    }
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<String>(version);
    }
    if (!nullToAbsent || boardName != null) {
      map['board_name'] = Variable<String>(boardName);
    }
    map['is_enabled'] = Variable<bool>(isEnabled);
    if (!nullToAbsent || lastConnectedAt != null) {
      map['last_connected_at'] = Variable<DateTime>(lastConnectedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RoutersCompanion toCompanion(bool nullToAbsent) {
    return RoutersCompanion(
      id: Value(id),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      name: Value(name),
      host: Value(host),
      apiPort: Value(apiPort),
      useSsl: Value(useSsl),
      username: Value(username),
      identity: identity == null && nullToAbsent
          ? const Value.absent()
          : Value(identity),
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      boardName: boardName == null && nullToAbsent
          ? const Value.absent()
          : Value(boardName),
      isEnabled: Value(isEnabled),
      lastConnectedAt: lastConnectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastConnectedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RouterRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RouterRecord(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      name: serializer.fromJson<String>(json['name']),
      host: serializer.fromJson<String>(json['host']),
      apiPort: serializer.fromJson<int>(json['apiPort']),
      useSsl: serializer.fromJson<bool>(json['useSsl']),
      username: serializer.fromJson<String>(json['username']),
      identity: serializer.fromJson<String?>(json['identity']),
      version: serializer.fromJson<String?>(json['version']),
      boardName: serializer.fromJson<String?>(json['boardName']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      lastConnectedAt: serializer.fromJson<DateTime?>(json['lastConnectedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String?>(groupId),
      'name': serializer.toJson<String>(name),
      'host': serializer.toJson<String>(host),
      'apiPort': serializer.toJson<int>(apiPort),
      'useSsl': serializer.toJson<bool>(useSsl),
      'username': serializer.toJson<String>(username),
      'identity': serializer.toJson<String?>(identity),
      'version': serializer.toJson<String?>(version),
      'boardName': serializer.toJson<String?>(boardName),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'lastConnectedAt': serializer.toJson<DateTime?>(lastConnectedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RouterRecord copyWith({
    String? id,
    Value<String?> groupId = const Value.absent(),
    String? name,
    String? host,
    int? apiPort,
    bool? useSsl,
    String? username,
    Value<String?> identity = const Value.absent(),
    Value<String?> version = const Value.absent(),
    Value<String?> boardName = const Value.absent(),
    bool? isEnabled,
    Value<DateTime?> lastConnectedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => RouterRecord(
    id: id ?? this.id,
    groupId: groupId.present ? groupId.value : this.groupId,
    name: name ?? this.name,
    host: host ?? this.host,
    apiPort: apiPort ?? this.apiPort,
    useSsl: useSsl ?? this.useSsl,
    username: username ?? this.username,
    identity: identity.present ? identity.value : this.identity,
    version: version.present ? version.value : this.version,
    boardName: boardName.present ? boardName.value : this.boardName,
    isEnabled: isEnabled ?? this.isEnabled,
    lastConnectedAt: lastConnectedAt.present
        ? lastConnectedAt.value
        : this.lastConnectedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RouterRecord copyWithCompanion(RoutersCompanion data) {
    return RouterRecord(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      name: data.name.present ? data.name.value : this.name,
      host: data.host.present ? data.host.value : this.host,
      apiPort: data.apiPort.present ? data.apiPort.value : this.apiPort,
      useSsl: data.useSsl.present ? data.useSsl.value : this.useSsl,
      username: data.username.present ? data.username.value : this.username,
      identity: data.identity.present ? data.identity.value : this.identity,
      version: data.version.present ? data.version.value : this.version,
      boardName: data.boardName.present ? data.boardName.value : this.boardName,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      lastConnectedAt: data.lastConnectedAt.present
          ? data.lastConnectedAt.value
          : this.lastConnectedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RouterRecord(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('host: $host, ')
          ..write('apiPort: $apiPort, ')
          ..write('useSsl: $useSsl, ')
          ..write('username: $username, ')
          ..write('identity: $identity, ')
          ..write('version: $version, ')
          ..write('boardName: $boardName, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('lastConnectedAt: $lastConnectedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    groupId,
    name,
    host,
    apiPort,
    useSsl,
    username,
    identity,
    version,
    boardName,
    isEnabled,
    lastConnectedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouterRecord &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.name == this.name &&
          other.host == this.host &&
          other.apiPort == this.apiPort &&
          other.useSsl == this.useSsl &&
          other.username == this.username &&
          other.identity == this.identity &&
          other.version == this.version &&
          other.boardName == this.boardName &&
          other.isEnabled == this.isEnabled &&
          other.lastConnectedAt == this.lastConnectedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RoutersCompanion extends UpdateCompanion<RouterRecord> {
  final Value<String> id;
  final Value<String?> groupId;
  final Value<String> name;
  final Value<String> host;
  final Value<int> apiPort;
  final Value<bool> useSsl;
  final Value<String> username;
  final Value<String?> identity;
  final Value<String?> version;
  final Value<String?> boardName;
  final Value<bool> isEnabled;
  final Value<DateTime?> lastConnectedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RoutersCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.name = const Value.absent(),
    this.host = const Value.absent(),
    this.apiPort = const Value.absent(),
    this.useSsl = const Value.absent(),
    this.username = const Value.absent(),
    this.identity = const Value.absent(),
    this.version = const Value.absent(),
    this.boardName = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.lastConnectedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutersCompanion.insert({
    required String id,
    this.groupId = const Value.absent(),
    required String name,
    required String host,
    this.apiPort = const Value.absent(),
    this.useSsl = const Value.absent(),
    required String username,
    this.identity = const Value.absent(),
    this.version = const Value.absent(),
    this.boardName = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.lastConnectedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       host = Value(host),
       username = Value(username);
  static Insertable<RouterRecord> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? name,
    Expression<String>? host,
    Expression<int>? apiPort,
    Expression<bool>? useSsl,
    Expression<String>? username,
    Expression<String>? identity,
    Expression<String>? version,
    Expression<String>? boardName,
    Expression<bool>? isEnabled,
    Expression<DateTime>? lastConnectedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (name != null) 'name': name,
      if (host != null) 'host': host,
      if (apiPort != null) 'api_port': apiPort,
      if (useSsl != null) 'use_ssl': useSsl,
      if (username != null) 'username': username,
      if (identity != null) 'identity': identity,
      if (version != null) 'version': version,
      if (boardName != null) 'board_name': boardName,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (lastConnectedAt != null) 'last_connected_at': lastConnectedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutersCompanion copyWith({
    Value<String>? id,
    Value<String?>? groupId,
    Value<String>? name,
    Value<String>? host,
    Value<int>? apiPort,
    Value<bool>? useSsl,
    Value<String>? username,
    Value<String?>? identity,
    Value<String?>? version,
    Value<String?>? boardName,
    Value<bool>? isEnabled,
    Value<DateTime?>? lastConnectedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RoutersCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      host: host ?? this.host,
      apiPort: apiPort ?? this.apiPort,
      useSsl: useSsl ?? this.useSsl,
      username: username ?? this.username,
      identity: identity ?? this.identity,
      version: version ?? this.version,
      boardName: boardName ?? this.boardName,
      isEnabled: isEnabled ?? this.isEnabled,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (apiPort.present) {
      map['api_port'] = Variable<int>(apiPort.value);
    }
    if (useSsl.present) {
      map['use_ssl'] = Variable<bool>(useSsl.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (identity.present) {
      map['identity'] = Variable<String>(identity.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (boardName.present) {
      map['board_name'] = Variable<String>(boardName.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (lastConnectedAt.present) {
      map['last_connected_at'] = Variable<DateTime>(lastConnectedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutersCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('host: $host, ')
          ..write('apiPort: $apiPort, ')
          ..write('useSsl: $useSsl, ')
          ..write('username: $username, ')
          ..write('identity: $identity, ')
          ..write('version: $version, ')
          ..write('boardName: $boardName, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('lastConnectedAt: $lastConnectedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RouterGroupsTable extends RouterGroups
    with TableInfo<$RouterGroupsTable, RouterGroupRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RouterGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'router_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<RouterGroupRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RouterGroupRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RouterGroupRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RouterGroupsTable createAlias(String alias) {
    return $RouterGroupsTable(attachedDatabase, alias);
  }
}

class RouterGroupRecord extends DataClass
    implements Insertable<RouterGroupRecord> {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RouterGroupRecord({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RouterGroupsCompanion toCompanion(bool nullToAbsent) {
    return RouterGroupsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RouterGroupRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RouterGroupRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RouterGroupRecord copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => RouterGroupRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RouterGroupRecord copyWithCompanion(RouterGroupsCompanion data) {
    return RouterGroupRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RouterGroupRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouterGroupRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RouterGroupsCompanion extends UpdateCompanion<RouterGroupRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RouterGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RouterGroupsCompanion.insert({
    required String id,
    required String name,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<RouterGroupRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RouterGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RouterGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RouterGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HotspotProfilesTable extends HotspotProfiles
    with TableInfo<$HotspotProfilesTable, HotspotProfileRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HotspotProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routerIdMeta = const VerificationMeta(
    'routerId',
  );
  @override
  late final GeneratedColumn<String> routerId = GeneratedColumn<String>(
    'router_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateLimitMeta = const VerificationMeta(
    'rateLimit',
  );
  @override
  late final GeneratedColumn<String> rateLimit = GeneratedColumn<String>(
    'rate_limit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _validityMinutesMeta = const VerificationMeta(
    'validityMinutes',
  );
  @override
  late final GeneratedColumn<int> validityMinutes = GeneratedColumn<int>(
    'validity_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMinorMeta = const VerificationMeta(
    'priceMinor',
  );
  @override
  late final GeneratedColumn<int> priceMinor = GeneratedColumn<int>(
    'price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NGN'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routerId,
    name,
    rateLimit,
    validityMinutes,
    priceMinor,
    currency,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hotspot_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<HotspotProfileRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('router_id')) {
      context.handle(
        _routerIdMeta,
        routerId.isAcceptableOrUnknown(data['router_id']!, _routerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rate_limit')) {
      context.handle(
        _rateLimitMeta,
        rateLimit.isAcceptableOrUnknown(data['rate_limit']!, _rateLimitMeta),
      );
    }
    if (data.containsKey('validity_minutes')) {
      context.handle(
        _validityMinutesMeta,
        validityMinutes.isAcceptableOrUnknown(
          data['validity_minutes']!,
          _validityMinutesMeta,
        ),
      );
    }
    if (data.containsKey('price_minor')) {
      context.handle(
        _priceMinorMeta,
        priceMinor.isAcceptableOrUnknown(data['price_minor']!, _priceMinorMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HotspotProfileRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HotspotProfileRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      routerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}router_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      rateLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate_limit'],
      ),
      validityMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}validity_minutes'],
      ),
      priceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HotspotProfilesTable createAlias(String alias) {
    return $HotspotProfilesTable(attachedDatabase, alias);
  }
}

class HotspotProfileRecord extends DataClass
    implements Insertable<HotspotProfileRecord> {
  final String id;
  final String routerId;
  final String name;
  final String? rateLimit;
  final int? validityMinutes;
  final int priceMinor;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;
  const HotspotProfileRecord({
    required this.id,
    required this.routerId,
    required this.name,
    this.rateLimit,
    this.validityMinutes,
    required this.priceMinor,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['router_id'] = Variable<String>(routerId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || rateLimit != null) {
      map['rate_limit'] = Variable<String>(rateLimit);
    }
    if (!nullToAbsent || validityMinutes != null) {
      map['validity_minutes'] = Variable<int>(validityMinutes);
    }
    map['price_minor'] = Variable<int>(priceMinor);
    map['currency'] = Variable<String>(currency);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HotspotProfilesCompanion toCompanion(bool nullToAbsent) {
    return HotspotProfilesCompanion(
      id: Value(id),
      routerId: Value(routerId),
      name: Value(name),
      rateLimit: rateLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(rateLimit),
      validityMinutes: validityMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(validityMinutes),
      priceMinor: Value(priceMinor),
      currency: Value(currency),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory HotspotProfileRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HotspotProfileRecord(
      id: serializer.fromJson<String>(json['id']),
      routerId: serializer.fromJson<String>(json['routerId']),
      name: serializer.fromJson<String>(json['name']),
      rateLimit: serializer.fromJson<String?>(json['rateLimit']),
      validityMinutes: serializer.fromJson<int?>(json['validityMinutes']),
      priceMinor: serializer.fromJson<int>(json['priceMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routerId': serializer.toJson<String>(routerId),
      'name': serializer.toJson<String>(name),
      'rateLimit': serializer.toJson<String?>(rateLimit),
      'validityMinutes': serializer.toJson<int?>(validityMinutes),
      'priceMinor': serializer.toJson<int>(priceMinor),
      'currency': serializer.toJson<String>(currency),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  HotspotProfileRecord copyWith({
    String? id,
    String? routerId,
    String? name,
    Value<String?> rateLimit = const Value.absent(),
    Value<int?> validityMinutes = const Value.absent(),
    int? priceMinor,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => HotspotProfileRecord(
    id: id ?? this.id,
    routerId: routerId ?? this.routerId,
    name: name ?? this.name,
    rateLimit: rateLimit.present ? rateLimit.value : this.rateLimit,
    validityMinutes: validityMinutes.present
        ? validityMinutes.value
        : this.validityMinutes,
    priceMinor: priceMinor ?? this.priceMinor,
    currency: currency ?? this.currency,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HotspotProfileRecord copyWithCompanion(HotspotProfilesCompanion data) {
    return HotspotProfileRecord(
      id: data.id.present ? data.id.value : this.id,
      routerId: data.routerId.present ? data.routerId.value : this.routerId,
      name: data.name.present ? data.name.value : this.name,
      rateLimit: data.rateLimit.present ? data.rateLimit.value : this.rateLimit,
      validityMinutes: data.validityMinutes.present
          ? data.validityMinutes.value
          : this.validityMinutes,
      priceMinor: data.priceMinor.present
          ? data.priceMinor.value
          : this.priceMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HotspotProfileRecord(')
          ..write('id: $id, ')
          ..write('routerId: $routerId, ')
          ..write('name: $name, ')
          ..write('rateLimit: $rateLimit, ')
          ..write('validityMinutes: $validityMinutes, ')
          ..write('priceMinor: $priceMinor, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routerId,
    name,
    rateLimit,
    validityMinutes,
    priceMinor,
    currency,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HotspotProfileRecord &&
          other.id == this.id &&
          other.routerId == this.routerId &&
          other.name == this.name &&
          other.rateLimit == this.rateLimit &&
          other.validityMinutes == this.validityMinutes &&
          other.priceMinor == this.priceMinor &&
          other.currency == this.currency &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class HotspotProfilesCompanion extends UpdateCompanion<HotspotProfileRecord> {
  final Value<String> id;
  final Value<String> routerId;
  final Value<String> name;
  final Value<String?> rateLimit;
  final Value<int?> validityMinutes;
  final Value<int> priceMinor;
  final Value<String> currency;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const HotspotProfilesCompanion({
    this.id = const Value.absent(),
    this.routerId = const Value.absent(),
    this.name = const Value.absent(),
    this.rateLimit = const Value.absent(),
    this.validityMinutes = const Value.absent(),
    this.priceMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HotspotProfilesCompanion.insert({
    required String id,
    required String routerId,
    required String name,
    this.rateLimit = const Value.absent(),
    this.validityMinutes = const Value.absent(),
    this.priceMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       routerId = Value(routerId),
       name = Value(name);
  static Insertable<HotspotProfileRecord> custom({
    Expression<String>? id,
    Expression<String>? routerId,
    Expression<String>? name,
    Expression<String>? rateLimit,
    Expression<int>? validityMinutes,
    Expression<int>? priceMinor,
    Expression<String>? currency,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routerId != null) 'router_id': routerId,
      if (name != null) 'name': name,
      if (rateLimit != null) 'rate_limit': rateLimit,
      if (validityMinutes != null) 'validity_minutes': validityMinutes,
      if (priceMinor != null) 'price_minor': priceMinor,
      if (currency != null) 'currency': currency,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HotspotProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? routerId,
    Value<String>? name,
    Value<String?>? rateLimit,
    Value<int?>? validityMinutes,
    Value<int>? priceMinor,
    Value<String>? currency,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return HotspotProfilesCompanion(
      id: id ?? this.id,
      routerId: routerId ?? this.routerId,
      name: name ?? this.name,
      rateLimit: rateLimit ?? this.rateLimit,
      validityMinutes: validityMinutes ?? this.validityMinutes,
      priceMinor: priceMinor ?? this.priceMinor,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routerId.present) {
      map['router_id'] = Variable<String>(routerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rateLimit.present) {
      map['rate_limit'] = Variable<String>(rateLimit.value);
    }
    if (validityMinutes.present) {
      map['validity_minutes'] = Variable<int>(validityMinutes.value);
    }
    if (priceMinor.present) {
      map['price_minor'] = Variable<int>(priceMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HotspotProfilesCompanion(')
          ..write('id: $id, ')
          ..write('routerId: $routerId, ')
          ..write('name: $name, ')
          ..write('rateLimit: $rateLimit, ')
          ..write('validityMinutes: $validityMinutes, ')
          ..write('priceMinor: $priceMinor, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VoucherHistoryTable extends VoucherHistory
    with TableInfo<$VoucherHistoryTable, VoucherRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VoucherHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routerIdMeta = const VerificationMeta(
    'routerId',
  );
  @override
  late final GeneratedColumn<String> routerId = GeneratedColumn<String>(
    'router_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasPasswordMeta = const VerificationMeta(
    'hasPassword',
  );
  @override
  late final GeneratedColumn<bool> hasPassword = GeneratedColumn<bool>(
    'has_password',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_password" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _priceMinorMeta = const VerificationMeta(
    'priceMinor',
  );
  @override
  late final GeneratedColumn<int> priceMinor = GeneratedColumn<int>(
    'price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NGN'),
  );
  static const VerificationMeta _validityMinutesMeta = const VerificationMeta(
    'validityMinutes',
  );
  @override
  late final GeneratedColumn<int> validityMinutes = GeneratedColumn<int>(
    'validity_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _printedAtMeta = const VerificationMeta(
    'printedAt',
  );
  @override
  late final GeneratedColumn<DateTime> printedAt = GeneratedColumn<DateTime>(
    'printed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _soldAtMeta = const VerificationMeta('soldAt');
  @override
  late final GeneratedColumn<DateTime> soldAt = GeneratedColumn<DateTime>(
    'sold_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routerId,
    profileId,
    username,
    hasPassword,
    priceMinor,
    currency,
    validityMinutes,
    generatedAt,
    printedAt,
    soldAt,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voucher_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<VoucherRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('router_id')) {
      context.handle(
        _routerIdMeta,
        routerId.isAcceptableOrUnknown(data['router_id']!, _routerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routerIdMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('has_password')) {
      context.handle(
        _hasPasswordMeta,
        hasPassword.isAcceptableOrUnknown(
          data['has_password']!,
          _hasPasswordMeta,
        ),
      );
    }
    if (data.containsKey('price_minor')) {
      context.handle(
        _priceMinorMeta,
        priceMinor.isAcceptableOrUnknown(data['price_minor']!, _priceMinorMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('validity_minutes')) {
      context.handle(
        _validityMinutesMeta,
        validityMinutes.isAcceptableOrUnknown(
          data['validity_minutes']!,
          _validityMinutesMeta,
        ),
      );
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    }
    if (data.containsKey('printed_at')) {
      context.handle(
        _printedAtMeta,
        printedAt.isAcceptableOrUnknown(data['printed_at']!, _printedAtMeta),
      );
    }
    if (data.containsKey('sold_at')) {
      context.handle(
        _soldAtMeta,
        soldAt.isAcceptableOrUnknown(data['sold_at']!, _soldAtMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VoucherRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoucherRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      routerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}router_id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      ),
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      hasPassword: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_password'],
      )!,
      priceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      validityMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}validity_minutes'],
      ),
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      printedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}printed_at'],
      ),
      soldAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sold_at'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $VoucherHistoryTable createAlias(String alias) {
    return $VoucherHistoryTable(attachedDatabase, alias);
  }
}

class VoucherRecord extends DataClass implements Insertable<VoucherRecord> {
  final String id;
  final String routerId;
  final String? profileId;
  final String username;
  final bool hasPassword;
  final int priceMinor;
  final String currency;
  final int? validityMinutes;
  final DateTime generatedAt;
  final DateTime? printedAt;
  final DateTime? soldAt;
  final String? note;
  const VoucherRecord({
    required this.id,
    required this.routerId,
    this.profileId,
    required this.username,
    required this.hasPassword,
    required this.priceMinor,
    required this.currency,
    this.validityMinutes,
    required this.generatedAt,
    this.printedAt,
    this.soldAt,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['router_id'] = Variable<String>(routerId);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<String>(profileId);
    }
    map['username'] = Variable<String>(username);
    map['has_password'] = Variable<bool>(hasPassword);
    map['price_minor'] = Variable<int>(priceMinor);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || validityMinutes != null) {
      map['validity_minutes'] = Variable<int>(validityMinutes);
    }
    map['generated_at'] = Variable<DateTime>(generatedAt);
    if (!nullToAbsent || printedAt != null) {
      map['printed_at'] = Variable<DateTime>(printedAt);
    }
    if (!nullToAbsent || soldAt != null) {
      map['sold_at'] = Variable<DateTime>(soldAt);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  VoucherHistoryCompanion toCompanion(bool nullToAbsent) {
    return VoucherHistoryCompanion(
      id: Value(id),
      routerId: Value(routerId),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      username: Value(username),
      hasPassword: Value(hasPassword),
      priceMinor: Value(priceMinor),
      currency: Value(currency),
      validityMinutes: validityMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(validityMinutes),
      generatedAt: Value(generatedAt),
      printedAt: printedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(printedAt),
      soldAt: soldAt == null && nullToAbsent
          ? const Value.absent()
          : Value(soldAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory VoucherRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoucherRecord(
      id: serializer.fromJson<String>(json['id']),
      routerId: serializer.fromJson<String>(json['routerId']),
      profileId: serializer.fromJson<String?>(json['profileId']),
      username: serializer.fromJson<String>(json['username']),
      hasPassword: serializer.fromJson<bool>(json['hasPassword']),
      priceMinor: serializer.fromJson<int>(json['priceMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      validityMinutes: serializer.fromJson<int?>(json['validityMinutes']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      printedAt: serializer.fromJson<DateTime?>(json['printedAt']),
      soldAt: serializer.fromJson<DateTime?>(json['soldAt']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routerId': serializer.toJson<String>(routerId),
      'profileId': serializer.toJson<String?>(profileId),
      'username': serializer.toJson<String>(username),
      'hasPassword': serializer.toJson<bool>(hasPassword),
      'priceMinor': serializer.toJson<int>(priceMinor),
      'currency': serializer.toJson<String>(currency),
      'validityMinutes': serializer.toJson<int?>(validityMinutes),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'printedAt': serializer.toJson<DateTime?>(printedAt),
      'soldAt': serializer.toJson<DateTime?>(soldAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  VoucherRecord copyWith({
    String? id,
    String? routerId,
    Value<String?> profileId = const Value.absent(),
    String? username,
    bool? hasPassword,
    int? priceMinor,
    String? currency,
    Value<int?> validityMinutes = const Value.absent(),
    DateTime? generatedAt,
    Value<DateTime?> printedAt = const Value.absent(),
    Value<DateTime?> soldAt = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => VoucherRecord(
    id: id ?? this.id,
    routerId: routerId ?? this.routerId,
    profileId: profileId.present ? profileId.value : this.profileId,
    username: username ?? this.username,
    hasPassword: hasPassword ?? this.hasPassword,
    priceMinor: priceMinor ?? this.priceMinor,
    currency: currency ?? this.currency,
    validityMinutes: validityMinutes.present
        ? validityMinutes.value
        : this.validityMinutes,
    generatedAt: generatedAt ?? this.generatedAt,
    printedAt: printedAt.present ? printedAt.value : this.printedAt,
    soldAt: soldAt.present ? soldAt.value : this.soldAt,
    note: note.present ? note.value : this.note,
  );
  VoucherRecord copyWithCompanion(VoucherHistoryCompanion data) {
    return VoucherRecord(
      id: data.id.present ? data.id.value : this.id,
      routerId: data.routerId.present ? data.routerId.value : this.routerId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      username: data.username.present ? data.username.value : this.username,
      hasPassword: data.hasPassword.present
          ? data.hasPassword.value
          : this.hasPassword,
      priceMinor: data.priceMinor.present
          ? data.priceMinor.value
          : this.priceMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      validityMinutes: data.validityMinutes.present
          ? data.validityMinutes.value
          : this.validityMinutes,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      printedAt: data.printedAt.present ? data.printedAt.value : this.printedAt,
      soldAt: data.soldAt.present ? data.soldAt.value : this.soldAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VoucherRecord(')
          ..write('id: $id, ')
          ..write('routerId: $routerId, ')
          ..write('profileId: $profileId, ')
          ..write('username: $username, ')
          ..write('hasPassword: $hasPassword, ')
          ..write('priceMinor: $priceMinor, ')
          ..write('currency: $currency, ')
          ..write('validityMinutes: $validityMinutes, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('printedAt: $printedAt, ')
          ..write('soldAt: $soldAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routerId,
    profileId,
    username,
    hasPassword,
    priceMinor,
    currency,
    validityMinutes,
    generatedAt,
    printedAt,
    soldAt,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoucherRecord &&
          other.id == this.id &&
          other.routerId == this.routerId &&
          other.profileId == this.profileId &&
          other.username == this.username &&
          other.hasPassword == this.hasPassword &&
          other.priceMinor == this.priceMinor &&
          other.currency == this.currency &&
          other.validityMinutes == this.validityMinutes &&
          other.generatedAt == this.generatedAt &&
          other.printedAt == this.printedAt &&
          other.soldAt == this.soldAt &&
          other.note == this.note);
}

class VoucherHistoryCompanion extends UpdateCompanion<VoucherRecord> {
  final Value<String> id;
  final Value<String> routerId;
  final Value<String?> profileId;
  final Value<String> username;
  final Value<bool> hasPassword;
  final Value<int> priceMinor;
  final Value<String> currency;
  final Value<int?> validityMinutes;
  final Value<DateTime> generatedAt;
  final Value<DateTime?> printedAt;
  final Value<DateTime?> soldAt;
  final Value<String?> note;
  final Value<int> rowid;
  const VoucherHistoryCompanion({
    this.id = const Value.absent(),
    this.routerId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.username = const Value.absent(),
    this.hasPassword = const Value.absent(),
    this.priceMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.validityMinutes = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.printedAt = const Value.absent(),
    this.soldAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VoucherHistoryCompanion.insert({
    required String id,
    required String routerId,
    this.profileId = const Value.absent(),
    required String username,
    this.hasPassword = const Value.absent(),
    this.priceMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.validityMinutes = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.printedAt = const Value.absent(),
    this.soldAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       routerId = Value(routerId),
       username = Value(username);
  static Insertable<VoucherRecord> custom({
    Expression<String>? id,
    Expression<String>? routerId,
    Expression<String>? profileId,
    Expression<String>? username,
    Expression<bool>? hasPassword,
    Expression<int>? priceMinor,
    Expression<String>? currency,
    Expression<int>? validityMinutes,
    Expression<DateTime>? generatedAt,
    Expression<DateTime>? printedAt,
    Expression<DateTime>? soldAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routerId != null) 'router_id': routerId,
      if (profileId != null) 'profile_id': profileId,
      if (username != null) 'username': username,
      if (hasPassword != null) 'has_password': hasPassword,
      if (priceMinor != null) 'price_minor': priceMinor,
      if (currency != null) 'currency': currency,
      if (validityMinutes != null) 'validity_minutes': validityMinutes,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (printedAt != null) 'printed_at': printedAt,
      if (soldAt != null) 'sold_at': soldAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VoucherHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? routerId,
    Value<String?>? profileId,
    Value<String>? username,
    Value<bool>? hasPassword,
    Value<int>? priceMinor,
    Value<String>? currency,
    Value<int?>? validityMinutes,
    Value<DateTime>? generatedAt,
    Value<DateTime?>? printedAt,
    Value<DateTime?>? soldAt,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return VoucherHistoryCompanion(
      id: id ?? this.id,
      routerId: routerId ?? this.routerId,
      profileId: profileId ?? this.profileId,
      username: username ?? this.username,
      hasPassword: hasPassword ?? this.hasPassword,
      priceMinor: priceMinor ?? this.priceMinor,
      currency: currency ?? this.currency,
      validityMinutes: validityMinutes ?? this.validityMinutes,
      generatedAt: generatedAt ?? this.generatedAt,
      printedAt: printedAt ?? this.printedAt,
      soldAt: soldAt ?? this.soldAt,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routerId.present) {
      map['router_id'] = Variable<String>(routerId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (hasPassword.present) {
      map['has_password'] = Variable<bool>(hasPassword.value);
    }
    if (priceMinor.present) {
      map['price_minor'] = Variable<int>(priceMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (validityMinutes.present) {
      map['validity_minutes'] = Variable<int>(validityMinutes.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (printedAt.present) {
      map['printed_at'] = Variable<DateTime>(printedAt.value);
    }
    if (soldAt.present) {
      map['sold_at'] = Variable<DateTime>(soldAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoucherHistoryCompanion(')
          ..write('id: $id, ')
          ..write('routerId: $routerId, ')
          ..write('profileId: $profileId, ')
          ..write('username: $username, ')
          ..write('hasPassword: $hasPassword, ')
          ..write('priceMinor: $priceMinor, ')
          ..write('currency: $currency, ')
          ..write('validityMinutes: $validityMinutes, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('printedAt: $printedAt, ')
          ..write('soldAt: $soldAt, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, SaleRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voucherIdMeta = const VerificationMeta(
    'voucherId',
  );
  @override
  late final GeneratedColumn<String> voucherId = GeneratedColumn<String>(
    'voucher_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routerIdMeta = const VerificationMeta(
    'routerId',
  );
  @override
  late final GeneratedColumn<String> routerId = GeneratedColumn<String>(
    'router_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NGN'),
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _soldAtMeta = const VerificationMeta('soldAt');
  @override
  late final GeneratedColumn<DateTime> soldAt = GeneratedColumn<DateTime>(
    'sold_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    voucherId,
    routerId,
    amountMinor,
    currency,
    paymentMethod,
    soldAt,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('voucher_id')) {
      context.handle(
        _voucherIdMeta,
        voucherId.isAcceptableOrUnknown(data['voucher_id']!, _voucherIdMeta),
      );
    }
    if (data.containsKey('router_id')) {
      context.handle(
        _routerIdMeta,
        routerId.isAcceptableOrUnknown(data['router_id']!, _routerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routerIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('sold_at')) {
      context.handle(
        _soldAtMeta,
        soldAt.isAcceptableOrUnknown(data['sold_at']!, _soldAtMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      voucherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voucher_id'],
      ),
      routerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}router_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      ),
      soldAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sold_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class SaleRecord extends DataClass implements Insertable<SaleRecord> {
  final String id;
  final String? voucherId;
  final String routerId;
  final int amountMinor;
  final String currency;
  final String? paymentMethod;
  final DateTime soldAt;
  final String? note;
  const SaleRecord({
    required this.id,
    this.voucherId,
    required this.routerId,
    required this.amountMinor,
    required this.currency,
    this.paymentMethod,
    required this.soldAt,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || voucherId != null) {
      map['voucher_id'] = Variable<String>(voucherId);
    }
    map['router_id'] = Variable<String>(routerId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    map['sold_at'] = Variable<DateTime>(soldAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      voucherId: voucherId == null && nullToAbsent
          ? const Value.absent()
          : Value(voucherId),
      routerId: Value(routerId),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      soldAt: Value(soldAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory SaleRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleRecord(
      id: serializer.fromJson<String>(json['id']),
      voucherId: serializer.fromJson<String?>(json['voucherId']),
      routerId: serializer.fromJson<String>(json['routerId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      soldAt: serializer.fromJson<DateTime>(json['soldAt']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'voucherId': serializer.toJson<String?>(voucherId),
      'routerId': serializer.toJson<String>(routerId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'soldAt': serializer.toJson<DateTime>(soldAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  SaleRecord copyWith({
    String? id,
    Value<String?> voucherId = const Value.absent(),
    String? routerId,
    int? amountMinor,
    String? currency,
    Value<String?> paymentMethod = const Value.absent(),
    DateTime? soldAt,
    Value<String?> note = const Value.absent(),
  }) => SaleRecord(
    id: id ?? this.id,
    voucherId: voucherId.present ? voucherId.value : this.voucherId,
    routerId: routerId ?? this.routerId,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    paymentMethod: paymentMethod.present
        ? paymentMethod.value
        : this.paymentMethod,
    soldAt: soldAt ?? this.soldAt,
    note: note.present ? note.value : this.note,
  );
  SaleRecord copyWithCompanion(SalesCompanion data) {
    return SaleRecord(
      id: data.id.present ? data.id.value : this.id,
      voucherId: data.voucherId.present ? data.voucherId.value : this.voucherId,
      routerId: data.routerId.present ? data.routerId.value : this.routerId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      soldAt: data.soldAt.present ? data.soldAt.value : this.soldAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleRecord(')
          ..write('id: $id, ')
          ..write('voucherId: $voucherId, ')
          ..write('routerId: $routerId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('soldAt: $soldAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    voucherId,
    routerId,
    amountMinor,
    currency,
    paymentMethod,
    soldAt,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleRecord &&
          other.id == this.id &&
          other.voucherId == this.voucherId &&
          other.routerId == this.routerId &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.paymentMethod == this.paymentMethod &&
          other.soldAt == this.soldAt &&
          other.note == this.note);
}

class SalesCompanion extends UpdateCompanion<SaleRecord> {
  final Value<String> id;
  final Value<String?> voucherId;
  final Value<String> routerId;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String?> paymentMethod;
  final Value<DateTime> soldAt;
  final Value<String?> note;
  final Value<int> rowid;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.voucherId = const Value.absent(),
    this.routerId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.soldAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String id,
    this.voucherId = const Value.absent(),
    required String routerId,
    required int amountMinor,
    this.currency = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.soldAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       routerId = Value(routerId),
       amountMinor = Value(amountMinor);
  static Insertable<SaleRecord> custom({
    Expression<String>? id,
    Expression<String>? voucherId,
    Expression<String>? routerId,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? paymentMethod,
    Expression<DateTime>? soldAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (voucherId != null) 'voucher_id': voucherId,
      if (routerId != null) 'router_id': routerId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (soldAt != null) 'sold_at': soldAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith({
    Value<String>? id,
    Value<String?>? voucherId,
    Value<String>? routerId,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<String?>? paymentMethod,
    Value<DateTime>? soldAt,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return SalesCompanion(
      id: id ?? this.id,
      voucherId: voucherId ?? this.voucherId,
      routerId: routerId ?? this.routerId,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      soldAt: soldAt ?? this.soldAt,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (voucherId.present) {
      map['voucher_id'] = Variable<String>(voucherId.value);
    }
    if (routerId.present) {
      map['router_id'] = Variable<String>(routerId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (soldAt.present) {
      map['sold_at'] = Variable<DateTime>(soldAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('voucherId: $voucherId, ')
          ..write('routerId: $routerId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('soldAt: $soldAt, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRecord(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRecord extends DataClass
    implements Insertable<AppSettingRecord> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSettingRecord({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRecord(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingRecord copyWith({
    String? key,
    String? value,
    DateTime? updatedAt,
  }) => AppSettingRecord(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSettingRecord copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRecord(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRecord(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRecord &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRecord> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingRecord> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrinterConfigsTable extends PrinterConfigs
    with TableInfo<$PrinterConfigsTable, PrinterConfigRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrinterConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paperWidthMmMeta = const VerificationMeta(
    'paperWidthMm',
  );
  @override
  late final GeneratedColumn<int> paperWidthMm = GeneratedColumn<int>(
    'paper_width_mm',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(58),
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    address,
    paperWidthMm,
    isDefault,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'printer_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrinterConfigRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('paper_width_mm')) {
      context.handle(
        _paperWidthMmMeta,
        paperWidthMm.isAcceptableOrUnknown(
          data['paper_width_mm']!,
          _paperWidthMmMeta,
        ),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrinterConfigRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrinterConfigRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      paperWidthMm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paper_width_mm'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PrinterConfigsTable createAlias(String alias) {
    return $PrinterConfigsTable(attachedDatabase, alias);
  }
}

class PrinterConfigRecord extends DataClass
    implements Insertable<PrinterConfigRecord> {
  final String id;
  final String name;
  final String address;
  final int paperWidthMm;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PrinterConfigRecord({
    required this.id,
    required this.name,
    required this.address,
    required this.paperWidthMm,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['address'] = Variable<String>(address);
    map['paper_width_mm'] = Variable<int>(paperWidthMm);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PrinterConfigsCompanion toCompanion(bool nullToAbsent) {
    return PrinterConfigsCompanion(
      id: Value(id),
      name: Value(name),
      address: Value(address),
      paperWidthMm: Value(paperWidthMm),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PrinterConfigRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrinterConfigRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String>(json['address']),
      paperWidthMm: serializer.fromJson<int>(json['paperWidthMm']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String>(address),
      'paperWidthMm': serializer.toJson<int>(paperWidthMm),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PrinterConfigRecord copyWith({
    String? id,
    String? name,
    String? address,
    int? paperWidthMm,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PrinterConfigRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address ?? this.address,
    paperWidthMm: paperWidthMm ?? this.paperWidthMm,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PrinterConfigRecord copyWithCompanion(PrinterConfigsCompanion data) {
    return PrinterConfigRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      paperWidthMm: data.paperWidthMm.present
          ? data.paperWidthMm.value
          : this.paperWidthMm,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrinterConfigRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('paperWidthMm: $paperWidthMm, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    address,
    paperWidthMm,
    isDefault,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrinterConfigRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.paperWidthMm == this.paperWidthMm &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PrinterConfigsCompanion extends UpdateCompanion<PrinterConfigRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> address;
  final Value<int> paperWidthMm;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PrinterConfigsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.paperWidthMm = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrinterConfigsCompanion.insert({
    required String id,
    required String name,
    required String address,
    this.paperWidthMm = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       address = Value(address);
  static Insertable<PrinterConfigRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<int>? paperWidthMm,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (paperWidthMm != null) 'paper_width_mm': paperWidthMm,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrinterConfigsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? address,
    Value<int>? paperWidthMm,
    Value<bool>? isDefault,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PrinterConfigsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      paperWidthMm: paperWidthMm ?? this.paperWidthMm,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (paperWidthMm.present) {
      map['paper_width_mm'] = Variable<int>(paperWidthMm.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrinterConfigsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('paperWidthMm: $paperWidthMm, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RoutersTable routers = $RoutersTable(this);
  late final $RouterGroupsTable routerGroups = $RouterGroupsTable(this);
  late final $HotspotProfilesTable hotspotProfiles = $HotspotProfilesTable(
    this,
  );
  late final $VoucherHistoryTable voucherHistory = $VoucherHistoryTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $PrinterConfigsTable printerConfigs = $PrinterConfigsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    routers,
    routerGroups,
    hotspotProfiles,
    voucherHistory,
    sales,
    appSettings,
    printerConfigs,
  ];
}

typedef $$RoutersTableCreateCompanionBuilder =
    RoutersCompanion Function({
      required String id,
      Value<String?> groupId,
      required String name,
      required String host,
      Value<int> apiPort,
      Value<bool> useSsl,
      required String username,
      Value<String?> identity,
      Value<String?> version,
      Value<String?> boardName,
      Value<bool> isEnabled,
      Value<DateTime?> lastConnectedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$RoutersTableUpdateCompanionBuilder =
    RoutersCompanion Function({
      Value<String> id,
      Value<String?> groupId,
      Value<String> name,
      Value<String> host,
      Value<int> apiPort,
      Value<bool> useSsl,
      Value<String> username,
      Value<String?> identity,
      Value<String?> version,
      Value<String?> boardName,
      Value<bool> isEnabled,
      Value<DateTime?> lastConnectedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RoutersTableFilterComposer
    extends Composer<_$AppDatabase, $RoutersTable> {
  $$RoutersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get apiPort => $composableBuilder(
    column: $table.apiPort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get useSsl => $composableBuilder(
    column: $table.useSsl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get identity => $composableBuilder(
    column: $table.identity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boardName => $composableBuilder(
    column: $table.boardName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoutersTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutersTable> {
  $$RoutersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get apiPort => $composableBuilder(
    column: $table.apiPort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get useSsl => $composableBuilder(
    column: $table.useSsl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identity => $composableBuilder(
    column: $table.identity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boardName => $composableBuilder(
    column: $table.boardName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutersTable> {
  $$RoutersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<int> get apiPort =>
      $composableBuilder(column: $table.apiPort, builder: (column) => column);

  GeneratedColumn<bool> get useSsl =>
      $composableBuilder(column: $table.useSsl, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get identity =>
      $composableBuilder(column: $table.identity, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get boardName =>
      $composableBuilder(column: $table.boardName, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RoutersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutersTable,
          RouterRecord,
          $$RoutersTableFilterComposer,
          $$RoutersTableOrderingComposer,
          $$RoutersTableAnnotationComposer,
          $$RoutersTableCreateCompanionBuilder,
          $$RoutersTableUpdateCompanionBuilder,
          (
            RouterRecord,
            BaseReferences<_$AppDatabase, $RoutersTable, RouterRecord>,
          ),
          RouterRecord,
          PrefetchHooks Function()
        > {
  $$RoutersTableTableManager(_$AppDatabase db, $RoutersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<int> apiPort = const Value.absent(),
                Value<bool> useSsl = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String?> identity = const Value.absent(),
                Value<String?> version = const Value.absent(),
                Value<String?> boardName = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime?> lastConnectedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutersCompanion(
                id: id,
                groupId: groupId,
                name: name,
                host: host,
                apiPort: apiPort,
                useSsl: useSsl,
                username: username,
                identity: identity,
                version: version,
                boardName: boardName,
                isEnabled: isEnabled,
                lastConnectedAt: lastConnectedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> groupId = const Value.absent(),
                required String name,
                required String host,
                Value<int> apiPort = const Value.absent(),
                Value<bool> useSsl = const Value.absent(),
                required String username,
                Value<String?> identity = const Value.absent(),
                Value<String?> version = const Value.absent(),
                Value<String?> boardName = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime?> lastConnectedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutersCompanion.insert(
                id: id,
                groupId: groupId,
                name: name,
                host: host,
                apiPort: apiPort,
                useSsl: useSsl,
                username: username,
                identity: identity,
                version: version,
                boardName: boardName,
                isEnabled: isEnabled,
                lastConnectedAt: lastConnectedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoutersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutersTable,
      RouterRecord,
      $$RoutersTableFilterComposer,
      $$RoutersTableOrderingComposer,
      $$RoutersTableAnnotationComposer,
      $$RoutersTableCreateCompanionBuilder,
      $$RoutersTableUpdateCompanionBuilder,
      (
        RouterRecord,
        BaseReferences<_$AppDatabase, $RoutersTable, RouterRecord>,
      ),
      RouterRecord,
      PrefetchHooks Function()
    >;
typedef $$RouterGroupsTableCreateCompanionBuilder =
    RouterGroupsCompanion Function({
      required String id,
      required String name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$RouterGroupsTableUpdateCompanionBuilder =
    RouterGroupsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RouterGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $RouterGroupsTable> {
  $$RouterGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RouterGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $RouterGroupsTable> {
  $$RouterGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RouterGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RouterGroupsTable> {
  $$RouterGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RouterGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RouterGroupsTable,
          RouterGroupRecord,
          $$RouterGroupsTableFilterComposer,
          $$RouterGroupsTableOrderingComposer,
          $$RouterGroupsTableAnnotationComposer,
          $$RouterGroupsTableCreateCompanionBuilder,
          $$RouterGroupsTableUpdateCompanionBuilder,
          (
            RouterGroupRecord,
            BaseReferences<
              _$AppDatabase,
              $RouterGroupsTable,
              RouterGroupRecord
            >,
          ),
          RouterGroupRecord,
          PrefetchHooks Function()
        > {
  $$RouterGroupsTableTableManager(_$AppDatabase db, $RouterGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RouterGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RouterGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RouterGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RouterGroupsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RouterGroupsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RouterGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RouterGroupsTable,
      RouterGroupRecord,
      $$RouterGroupsTableFilterComposer,
      $$RouterGroupsTableOrderingComposer,
      $$RouterGroupsTableAnnotationComposer,
      $$RouterGroupsTableCreateCompanionBuilder,
      $$RouterGroupsTableUpdateCompanionBuilder,
      (
        RouterGroupRecord,
        BaseReferences<_$AppDatabase, $RouterGroupsTable, RouterGroupRecord>,
      ),
      RouterGroupRecord,
      PrefetchHooks Function()
    >;
typedef $$HotspotProfilesTableCreateCompanionBuilder =
    HotspotProfilesCompanion Function({
      required String id,
      required String routerId,
      required String name,
      Value<String?> rateLimit,
      Value<int?> validityMinutes,
      Value<int> priceMinor,
      Value<String> currency,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$HotspotProfilesTableUpdateCompanionBuilder =
    HotspotProfilesCompanion Function({
      Value<String> id,
      Value<String> routerId,
      Value<String> name,
      Value<String?> rateLimit,
      Value<int?> validityMinutes,
      Value<int> priceMinor,
      Value<String> currency,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$HotspotProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $HotspotProfilesTable> {
  $$HotspotProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routerId => $composableBuilder(
    column: $table.routerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rateLimit => $composableBuilder(
    column: $table.rateLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get validityMinutes => $composableBuilder(
    column: $table.validityMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HotspotProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $HotspotProfilesTable> {
  $$HotspotProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routerId => $composableBuilder(
    column: $table.routerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rateLimit => $composableBuilder(
    column: $table.rateLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get validityMinutes => $composableBuilder(
    column: $table.validityMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HotspotProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HotspotProfilesTable> {
  $$HotspotProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get routerId =>
      $composableBuilder(column: $table.routerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get rateLimit =>
      $composableBuilder(column: $table.rateLimit, builder: (column) => column);

  GeneratedColumn<int> get validityMinutes => $composableBuilder(
    column: $table.validityMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HotspotProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HotspotProfilesTable,
          HotspotProfileRecord,
          $$HotspotProfilesTableFilterComposer,
          $$HotspotProfilesTableOrderingComposer,
          $$HotspotProfilesTableAnnotationComposer,
          $$HotspotProfilesTableCreateCompanionBuilder,
          $$HotspotProfilesTableUpdateCompanionBuilder,
          (
            HotspotProfileRecord,
            BaseReferences<
              _$AppDatabase,
              $HotspotProfilesTable,
              HotspotProfileRecord
            >,
          ),
          HotspotProfileRecord,
          PrefetchHooks Function()
        > {
  $$HotspotProfilesTableTableManager(
    _$AppDatabase db,
    $HotspotProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HotspotProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HotspotProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HotspotProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> routerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> rateLimit = const Value.absent(),
                Value<int?> validityMinutes = const Value.absent(),
                Value<int> priceMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HotspotProfilesCompanion(
                id: id,
                routerId: routerId,
                name: name,
                rateLimit: rateLimit,
                validityMinutes: validityMinutes,
                priceMinor: priceMinor,
                currency: currency,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String routerId,
                required String name,
                Value<String?> rateLimit = const Value.absent(),
                Value<int?> validityMinutes = const Value.absent(),
                Value<int> priceMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HotspotProfilesCompanion.insert(
                id: id,
                routerId: routerId,
                name: name,
                rateLimit: rateLimit,
                validityMinutes: validityMinutes,
                priceMinor: priceMinor,
                currency: currency,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HotspotProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HotspotProfilesTable,
      HotspotProfileRecord,
      $$HotspotProfilesTableFilterComposer,
      $$HotspotProfilesTableOrderingComposer,
      $$HotspotProfilesTableAnnotationComposer,
      $$HotspotProfilesTableCreateCompanionBuilder,
      $$HotspotProfilesTableUpdateCompanionBuilder,
      (
        HotspotProfileRecord,
        BaseReferences<
          _$AppDatabase,
          $HotspotProfilesTable,
          HotspotProfileRecord
        >,
      ),
      HotspotProfileRecord,
      PrefetchHooks Function()
    >;
typedef $$VoucherHistoryTableCreateCompanionBuilder =
    VoucherHistoryCompanion Function({
      required String id,
      required String routerId,
      Value<String?> profileId,
      required String username,
      Value<bool> hasPassword,
      Value<int> priceMinor,
      Value<String> currency,
      Value<int?> validityMinutes,
      Value<DateTime> generatedAt,
      Value<DateTime?> printedAt,
      Value<DateTime?> soldAt,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$VoucherHistoryTableUpdateCompanionBuilder =
    VoucherHistoryCompanion Function({
      Value<String> id,
      Value<String> routerId,
      Value<String?> profileId,
      Value<String> username,
      Value<bool> hasPassword,
      Value<int> priceMinor,
      Value<String> currency,
      Value<int?> validityMinutes,
      Value<DateTime> generatedAt,
      Value<DateTime?> printedAt,
      Value<DateTime?> soldAt,
      Value<String?> note,
      Value<int> rowid,
    });

class $$VoucherHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $VoucherHistoryTable> {
  $$VoucherHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routerId => $composableBuilder(
    column: $table.routerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasPassword => $composableBuilder(
    column: $table.hasPassword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get validityMinutes => $composableBuilder(
    column: $table.validityMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get printedAt => $composableBuilder(
    column: $table.printedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get soldAt => $composableBuilder(
    column: $table.soldAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VoucherHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $VoucherHistoryTable> {
  $$VoucherHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routerId => $composableBuilder(
    column: $table.routerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasPassword => $composableBuilder(
    column: $table.hasPassword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get validityMinutes => $composableBuilder(
    column: $table.validityMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get printedAt => $composableBuilder(
    column: $table.printedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get soldAt => $composableBuilder(
    column: $table.soldAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VoucherHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $VoucherHistoryTable> {
  $$VoucherHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get routerId =>
      $composableBuilder(column: $table.routerId, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<bool> get hasPassword => $composableBuilder(
    column: $table.hasPassword,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get validityMinutes => $composableBuilder(
    column: $table.validityMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get printedAt =>
      $composableBuilder(column: $table.printedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get soldAt =>
      $composableBuilder(column: $table.soldAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$VoucherHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VoucherHistoryTable,
          VoucherRecord,
          $$VoucherHistoryTableFilterComposer,
          $$VoucherHistoryTableOrderingComposer,
          $$VoucherHistoryTableAnnotationComposer,
          $$VoucherHistoryTableCreateCompanionBuilder,
          $$VoucherHistoryTableUpdateCompanionBuilder,
          (
            VoucherRecord,
            BaseReferences<_$AppDatabase, $VoucherHistoryTable, VoucherRecord>,
          ),
          VoucherRecord,
          PrefetchHooks Function()
        > {
  $$VoucherHistoryTableTableManager(
    _$AppDatabase db,
    $VoucherHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VoucherHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VoucherHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VoucherHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> routerId = const Value.absent(),
                Value<String?> profileId = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<bool> hasPassword = const Value.absent(),
                Value<int> priceMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int?> validityMinutes = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<DateTime?> printedAt = const Value.absent(),
                Value<DateTime?> soldAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VoucherHistoryCompanion(
                id: id,
                routerId: routerId,
                profileId: profileId,
                username: username,
                hasPassword: hasPassword,
                priceMinor: priceMinor,
                currency: currency,
                validityMinutes: validityMinutes,
                generatedAt: generatedAt,
                printedAt: printedAt,
                soldAt: soldAt,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String routerId,
                Value<String?> profileId = const Value.absent(),
                required String username,
                Value<bool> hasPassword = const Value.absent(),
                Value<int> priceMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int?> validityMinutes = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<DateTime?> printedAt = const Value.absent(),
                Value<DateTime?> soldAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VoucherHistoryCompanion.insert(
                id: id,
                routerId: routerId,
                profileId: profileId,
                username: username,
                hasPassword: hasPassword,
                priceMinor: priceMinor,
                currency: currency,
                validityMinutes: validityMinutes,
                generatedAt: generatedAt,
                printedAt: printedAt,
                soldAt: soldAt,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VoucherHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VoucherHistoryTable,
      VoucherRecord,
      $$VoucherHistoryTableFilterComposer,
      $$VoucherHistoryTableOrderingComposer,
      $$VoucherHistoryTableAnnotationComposer,
      $$VoucherHistoryTableCreateCompanionBuilder,
      $$VoucherHistoryTableUpdateCompanionBuilder,
      (
        VoucherRecord,
        BaseReferences<_$AppDatabase, $VoucherHistoryTable, VoucherRecord>,
      ),
      VoucherRecord,
      PrefetchHooks Function()
    >;
typedef $$SalesTableCreateCompanionBuilder =
    SalesCompanion Function({
      required String id,
      Value<String?> voucherId,
      required String routerId,
      required int amountMinor,
      Value<String> currency,
      Value<String?> paymentMethod,
      Value<DateTime> soldAt,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$SalesTableUpdateCompanionBuilder =
    SalesCompanion Function({
      Value<String> id,
      Value<String?> voucherId,
      Value<String> routerId,
      Value<int> amountMinor,
      Value<String> currency,
      Value<String?> paymentMethod,
      Value<DateTime> soldAt,
      Value<String?> note,
      Value<int> rowid,
    });

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voucherId => $composableBuilder(
    column: $table.voucherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routerId => $composableBuilder(
    column: $table.routerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get soldAt => $composableBuilder(
    column: $table.soldAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voucherId => $composableBuilder(
    column: $table.voucherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routerId => $composableBuilder(
    column: $table.routerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get soldAt => $composableBuilder(
    column: $table.soldAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get voucherId =>
      $composableBuilder(column: $table.voucherId, builder: (column) => column);

  GeneratedColumn<String> get routerId =>
      $composableBuilder(column: $table.routerId, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get soldAt =>
      $composableBuilder(column: $table.soldAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          SaleRecord,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (SaleRecord, BaseReferences<_$AppDatabase, $SalesTable, SaleRecord>),
          SaleRecord,
          PrefetchHooks Function()
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> voucherId = const Value.absent(),
                Value<String> routerId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<DateTime> soldAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion(
                id: id,
                voucherId: voucherId,
                routerId: routerId,
                amountMinor: amountMinor,
                currency: currency,
                paymentMethod: paymentMethod,
                soldAt: soldAt,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> voucherId = const Value.absent(),
                required String routerId,
                required int amountMinor,
                Value<String> currency = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<DateTime> soldAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion.insert(
                id: id,
                voucherId: voucherId,
                routerId: routerId,
                amountMinor: amountMinor,
                currency: currency,
                paymentMethod: paymentMethod,
                soldAt: soldAt,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      SaleRecord,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (SaleRecord, BaseReferences<_$AppDatabase, $SalesTable, SaleRecord>),
      SaleRecord,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingRecord,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRecord,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRecord>,
          ),
          AppSettingRecord,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingRecord,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRecord,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRecord>,
      ),
      AppSettingRecord,
      PrefetchHooks Function()
    >;
typedef $$PrinterConfigsTableCreateCompanionBuilder =
    PrinterConfigsCompanion Function({
      required String id,
      required String name,
      required String address,
      Value<int> paperWidthMm,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$PrinterConfigsTableUpdateCompanionBuilder =
    PrinterConfigsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> address,
      Value<int> paperWidthMm,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PrinterConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $PrinterConfigsTable> {
  $$PrinterConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paperWidthMm => $composableBuilder(
    column: $table.paperWidthMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrinterConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrinterConfigsTable> {
  $$PrinterConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paperWidthMm => $composableBuilder(
    column: $table.paperWidthMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrinterConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrinterConfigsTable> {
  $$PrinterConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<int> get paperWidthMm => $composableBuilder(
    column: $table.paperWidthMm,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PrinterConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrinterConfigsTable,
          PrinterConfigRecord,
          $$PrinterConfigsTableFilterComposer,
          $$PrinterConfigsTableOrderingComposer,
          $$PrinterConfigsTableAnnotationComposer,
          $$PrinterConfigsTableCreateCompanionBuilder,
          $$PrinterConfigsTableUpdateCompanionBuilder,
          (
            PrinterConfigRecord,
            BaseReferences<
              _$AppDatabase,
              $PrinterConfigsTable,
              PrinterConfigRecord
            >,
          ),
          PrinterConfigRecord,
          PrefetchHooks Function()
        > {
  $$PrinterConfigsTableTableManager(
    _$AppDatabase db,
    $PrinterConfigsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrinterConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrinterConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrinterConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<int> paperWidthMm = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrinterConfigsCompanion(
                id: id,
                name: name,
                address: address,
                paperWidthMm: paperWidthMm,
                isDefault: isDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String address,
                Value<int> paperWidthMm = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrinterConfigsCompanion.insert(
                id: id,
                name: name,
                address: address,
                paperWidthMm: paperWidthMm,
                isDefault: isDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrinterConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrinterConfigsTable,
      PrinterConfigRecord,
      $$PrinterConfigsTableFilterComposer,
      $$PrinterConfigsTableOrderingComposer,
      $$PrinterConfigsTableAnnotationComposer,
      $$PrinterConfigsTableCreateCompanionBuilder,
      $$PrinterConfigsTableUpdateCompanionBuilder,
      (
        PrinterConfigRecord,
        BaseReferences<
          _$AppDatabase,
          $PrinterConfigsTable,
          PrinterConfigRecord
        >,
      ),
      PrinterConfigRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RoutersTableTableManager get routers =>
      $$RoutersTableTableManager(_db, _db.routers);
  $$RouterGroupsTableTableManager get routerGroups =>
      $$RouterGroupsTableTableManager(_db, _db.routerGroups);
  $$HotspotProfilesTableTableManager get hotspotProfiles =>
      $$HotspotProfilesTableTableManager(_db, _db.hotspotProfiles);
  $$VoucherHistoryTableTableManager get voucherHistory =>
      $$VoucherHistoryTableTableManager(_db, _db.voucherHistory);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$PrinterConfigsTableTableManager get printerConfigs =>
      $$PrinterConfigsTableTableManager(_db, _db.printerConfigs);
}
