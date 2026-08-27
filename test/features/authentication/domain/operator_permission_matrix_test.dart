import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/authentication/domain/entities/operator_role.dart';

void main() {
  group('OperatorPermissionMatrix', () {
    test('Admin role has full management and cloud permissions', () {
      expect(
        OperatorPermissionMatrix.canManageRouters(OperatorRole.admin),
        isTrue,
      );
      expect(
        OperatorPermissionMatrix.canViewFinancialReports(OperatorRole.admin),
        isTrue,
      );
      expect(
        OperatorPermissionMatrix.canManageCloudBackup(OperatorRole.admin),
        isTrue,
      );
      expect(OperatorPermissionMatrix.isReadOnly(OperatorRole.admin), isFalse);
    });

    test(
      'Operator role can disconnect sessions and sell vouchers but cannot manage cloud backups',
      () {
        expect(
          OperatorPermissionMatrix.canSellVouchers(OperatorRole.operator),
          isTrue,
        );
        expect(
          OperatorPermissionMatrix.canDisconnectSessions(OperatorRole.operator),
          isTrue,
        );
        expect(
          OperatorPermissionMatrix.canManageCloudBackup(OperatorRole.operator),
          isFalse,
        );
        expect(
          OperatorPermissionMatrix.isReadOnly(OperatorRole.operator),
          isFalse,
        );
      },
    );

    test('Viewer role is strictly read-only and cannot sell vouchers', () {
      expect(
        OperatorPermissionMatrix.canSellVouchers(OperatorRole.viewer),
        isFalse,
      );
      expect(
        OperatorPermissionMatrix.canManageRouters(OperatorRole.viewer),
        isFalse,
      );
      expect(
        OperatorPermissionMatrix.canDisconnectSessions(OperatorRole.viewer),
        isFalse,
      );
      expect(OperatorPermissionMatrix.isReadOnly(OperatorRole.viewer), isTrue);
    });
  });
}
