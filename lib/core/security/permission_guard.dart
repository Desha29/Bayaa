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
    if (user.userType == UserType.cashier) {
      throw PermissionDeniedException("لا يمكن للكاشير عرض التقارير والإحصائيات.");
    }
  }

  static void checkDayClosePermission(User user) {
    // Both Cashier and Manager can close the day (User override)
    // So this might just pass, or we enforce logic if requirements change.
    // For now, based on requirements: "Cashier can close the day".
    
    return;
  }
}
