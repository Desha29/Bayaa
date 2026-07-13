import 'package:bayaa_pos/features/auth/data/models/user_model.dart';

class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException(
      [this.message = "Access denied: You don't have permission to perform this action."]);

  @override
  String toString() => message;
}

class PermissionGuard {
  /// Refund permission — both managers and cashiers can process refunds.
  static void checkRefundPermission(User user) {
    // Cashiers are now allowed to process partial refunds.
    //     if (user.userType == UserType.cashier) {
    //   throw PermissionDeniedException("لا يمكن للكاشير تنفيذ عمليات المرتجع على الفواتير.");
    // }
    return;
  }

  static void checkReportAccess(User user) {
    // Cashiers are allowed to check reports and session details per user request
    return;
  }

  static void checkDayClosePermission(User user) {
    return;
  }
}
