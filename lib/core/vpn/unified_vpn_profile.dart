import 'vpn_protocol.dart';

class UnifiedVpnProfile {
  const UnifiedVpnProfile({
    required this.id,
    required this.name,
    required this.protocol,
    required this.rawConfig,
    this.remoteHost,
    this.remotePort,
    this.username,
    this.password,
    this.createdAt,
  });

  final String id;
  final String name;
  final VpnProtocol protocol;
  final String rawConfig;
  final String? remoteHost;
  final int? remotePort;
  final String? username;
  final String? password;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'protocol': protocol.name,
      'rawConfig': rawConfig,
      'remoteHost': remoteHost,
      'remotePort': remotePort,
      'username': username,
      'password': password,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory UnifiedVpnProfile.fromJson(Map<String, dynamic> json) {
    return UnifiedVpnProfile(
      id: json['id'] as String? ?? json['name'] as String? ?? 'vpn_profile',
      name: json['name'] as String? ?? 'VPN Profile',
      protocol: VpnProtocol.parse(json['protocol'] as String?),
      rawConfig: json['rawConfig'] as String? ?? '',
      remoteHost: json['remoteHost'] as String?,
      remotePort: json['remotePort'] as int?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  UnifiedVpnProfile copyWith({
    String? id,
    String? name,
    VpnProtocol? protocol,
    String? rawConfig,
    String? remoteHost,
    int? remotePort,
    String? username,
    String? password,
    DateTime? createdAt,
  }) {
    return UnifiedVpnProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      protocol: protocol ?? this.protocol,
      rawConfig: rawConfig ?? this.rawConfig,
      remoteHost: remoteHost ?? this.remoteHost,
      remotePort: remotePort ?? this.remotePort,
      username: username ?? this.username,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
