import 'package:flutter/material.dart';
import '../utils/message.dart';

class MessageOverlay extends StatefulWidget {
  final Widget child;

  const MessageOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<MessageOverlay> createState() => _MessageOverlayState();
}

class _MessageOverlayState extends State<MessageOverlay> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: widget.child,
    );
  }
}


class GlobalMessage {
  static BuildContext? _context;

  static void initialize(BuildContext context) {
    _context = context;
  }

  static void showSuccess(String message) {
    if (_context != null) {
      Message.showSuccess(_context!, message);
    }
  }

  static void showError(String message) {
    if (_context != null) {
      Message.showError(_context!, message);
    }
  }

  static void showWarning(String message) {
    if (_context != null) {
      Message.showWarning(_context!, message);
    }
  }

  static void showInfo(String message) {
    if (_context != null) {
      Message.showInfo(_context!, message);
    }
  }

  static void showLoading(String message) {
    if (_context != null) {
      Message.showLoading(_context!, message);
    }
  }

  static void showCustom({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (_context != null) {
      Message.showCustom(
        _context!,
        title: title,
        message: message,
        icon: icon,
        color: color,
        duration: duration,
      );
    }
  }

  // Predefined message helpers
  static void productAdded() => showSuccess('تم إضافة المنتج بنجاح');
  static void productUpdated() => showSuccess('تم تحديث المنتج بنجاح');
  static void productDeleted() => showSuccess('تم حذف المنتج بنجاح');
  static void saleCompleted() => showSuccess('تم إتمام البيع بنجاح');
  static void dataSaved() => showSuccess('تم حفظ البيانات بنجاح');
  static void reportGenerated() => showSuccess('تم إنشاء التقرير بنجاح');
  static void userCreated() => showSuccess('تم إنشاء المستخدم بنجاح');
  static void userUpdated() => showSuccess('تم تحديث المستخدم بنجاح');
  static void userDeleted() => showSuccess('تم حذف المستخدم بنجاح');
  static void loginSuccess() => showSuccess('تم تسجيل الدخول بنجاح');
  static void logoutSuccess() => showSuccess('تم تسجيل الخروج بنجاح');
  static void passwordChanged() => showSuccess('تم تغيير كلمة المرور بنجاح');
  static void settingsSaved() => showSuccess('تم حفظ الإعدادات بنجاح');

  static void productNotFound() => showError('المنتج غير موجود');
  static void insufficientStock() => showError('الكمية المتاحة غير كافية');
  static void invalidInput() => showError('البيانات المدخلة غير صحيحة');
  static void networkError() => showError('خطأ في الاتصال بالشبكة');
  static void serverError() => showError('خطأ في الخادم');
  static void loginFailed() => showError('فشل في تسجيل الدخول');
  static void accessDenied() => showError('ليس لديك صلاحية للوصول');
  static void fileNotFound() => showError('الملف غير موجود');
  static void saveFailed() => showError('فشل في حفظ البيانات');
  static void deleteFailed() => showError('فشل في حذف البيانات');
  static void updateFailed() => showError('فشل في تحديث البيانات');
  static void connectionTimeout() => showError('انتهت مهلة الاتصال');
  static void invalidCredentials() => showError('بيانات الدخول غير صحيحة');

  static void lowStock() => showWarning('الكمية قليلة - يرجى إعادة التموين');
  static void unsavedChanges() => showWarning('يوجد تغييرات غير محفوظة');
  static void confirmDelete() => showWarning('هل أنت متأكد من الحذف؟');
  static void sessionExpired() => showWarning('انتهت جلسة العمل');
  static void dataLoss() => showWarning('قد تفقد البيانات غير المحفوظة');
  static void backupRequired() => showWarning('يُفضل عمل نسخة احتياطية');
  static void systemMaintenance() => showWarning('سيتم إغلاق النظام للصيانة');

  static void loadingData() => showLoading('جاري تحميل البيانات...');
  static void processingRequest() => showLoading('جاري معالجة الطلب...');
  static void generatingReport() => showLoading('جاري إنشاء التقرير...');
  static void savingData() => showLoading('جاري حفظ البيانات...');
  static void updatingData() => showLoading('جاري تحديث البيانات...');
  static void deletingData() => showLoading('جاري حذف البيانات...');
  static void exportingData() => showLoading('جاري تصدير البيانات...');
  static void importingData() => showLoading('جاري استيراد البيانات...');
  static void synchronizingData() => showLoading('جاري مزامنة البيانات...');
  static void systemReady() => showInfo('النظام جاهز للاستخدام');
  static void newUpdateAvailable() => showInfo('يوجد تحديث جديد متاح');
  static void maintenanceScheduled() => showInfo('مجدولة صيانة النظام');
}
