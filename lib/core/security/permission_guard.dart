import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';

class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException([this.message = "تم رفض الوصول: ليس لديك صلاحية لتنفيذ هذا الإجراء."]);
  
  @override
  String toString() => message;
}

class PermissionGuard {
  static void checkRefundPermission(User user) {
    if (user.userType == UserType.cashier) {
      throw PermissionDeniedException("لا يمكن للكاشير تنفيذ عمليات المرتجع على الفواتير.");
    }
  }

  static void checkReportAccess(User user) {
    // Cashiers are allowed to check reports and session details per user request
    return;
  }

  static void checkDayClosePermission(User user) {

    
    return;
  }
}
