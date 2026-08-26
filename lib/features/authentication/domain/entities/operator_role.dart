enum OperatorRole { owner, manager, cashier }

class OperatorPermissionMatrix {
  const OperatorPermissionMatrix._();

  static bool canManageRouters(OperatorRole role) {
    return role == OperatorRole.owner || role == OperatorRole.manager;
  }

  static bool canViewFinancialReports(OperatorRole role) {
    return role == OperatorRole.owner || role == OperatorRole.manager;
  }

  static bool canManageCloudBackup(OperatorRole role) {
    return role == OperatorRole.owner;
  }

  static bool canSellVouchers(OperatorRole role) => true;

  static bool canDisconnectSessions(OperatorRole role) {
    return role == OperatorRole.owner || role == OperatorRole.manager;
  }
}
