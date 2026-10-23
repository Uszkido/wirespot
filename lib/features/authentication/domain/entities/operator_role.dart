enum OperatorRole { owner, manager, cashier, admin, operator, viewer }

extension OperatorRoleWireValue on OperatorRole {
  static OperatorRole fromWireValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    return OperatorRole.values.firstWhere(
      (role) => role.name == normalized,
      orElse: () => OperatorRole.owner,
    );
  }
}

class OperatorPermissionMatrix {
  const OperatorPermissionMatrix._();

  static bool canManageRouters(OperatorRole role) {
    return role == OperatorRole.owner ||
        role == OperatorRole.manager ||
        role == OperatorRole.admin;
  }

  static bool canViewFinancialReports(OperatorRole role) {
    return role == OperatorRole.owner ||
        role == OperatorRole.manager ||
        role == OperatorRole.admin;
  }

  static bool canManageCloudBackup(OperatorRole role) {
    return role == OperatorRole.owner || role == OperatorRole.admin;
  }

  static bool canSellVouchers(OperatorRole role) {
    return role != OperatorRole.viewer;
  }

  static bool canDisconnectSessions(OperatorRole role) {
    return role == OperatorRole.owner ||
        role == OperatorRole.manager ||
        role == OperatorRole.admin ||
        role == OperatorRole.operator;
  }

  static bool isReadOnly(OperatorRole role) {
    return role == OperatorRole.viewer;
  }
}
