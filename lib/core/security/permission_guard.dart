import 'package:bayaa_pos/features/auth/data/models/user_model.dart';
import 'package:bayaa_pos/core/components/message_overlay.dart';

class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException(
      [this.message = ""]); // TODO: Use GlobalMessage.l10n.accessDeniedMessage when context available

  @override
  String toString() => message;
}

class PermissionGuard {
  /// Refund permission — both managers and cashiers can process refunds.
  static void checkRefundPermission(User user) {
    // Cashiers are now allowed to process partial refunds.
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
