import 'package:flutter/material.dart';

class Message {
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      Colors.green,
      Icons.check_circle,
      'نجح',
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      Colors.red,
      Icons.error,
      'خطأ',
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      Colors.orange,
      Icons.warning,
      'تحذير',
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      Colors.blue,
      Icons.info,
      'معلومات',
    );
  }

  static void showLoading(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      Colors.blue,
      Icons.refresh,
      'جاري التحميل',
    );
  }

  static void showCustom(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context,
      message,
      color,
      icon,
      title,
      duration: duration,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
    String title, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Helper methods for common scenarios
  static void showProductAdded(BuildContext context) {
    showSuccess(context, 'تم إضافة المنتج بنجاح');
  }

  static void showProductUpdated(BuildContext context) {
    showSuccess(context, 'تم تحديث المنتج بنجاح');
  }

  static void showProductDeleted(BuildContext context) {
    showSuccess(context, 'تم حذف المنتج بنجاح');
  }

  static void showSaleCompleted(BuildContext context) {
    showSuccess(context, 'تم إتمام البيع بنجاح');
  }

  static void showDataSaved(BuildContext context) {
    showSuccess(context, 'تم حفظ البيانات بنجاح');
  }

  static void showReportGenerated(BuildContext context) {
    showSuccess(context, 'تم إنشاء التقرير بنجاح');
  }

  static void showProductNotFound(BuildContext context) {
    showError(context, 'المنتج غير موجود');
  }

  static void showInsufficientStock(BuildContext context) {
    showError(context, 'الكمية المتاحة غير كافية');
  }

  static void showInvalidInput(BuildContext context) {
    showError(context, 'البيانات المدخلة غير صحيحة');
  }

  static void showNetworkError(BuildContext context) {
    showError(context, 'خطأ في الاتصال بالشبكة');
  }

  static void showServerError(BuildContext context) {
    showError(context, 'خطأ في الخادم');
  }

  static void showLoginFailed(BuildContext context) {
    showError(context, 'فشل في تسجيل الدخول');
  }

  static void showAccessDenied(BuildContext context) {
    showError(context, 'ليس لديك صلاحية للوصول');
  }

  static void showLowStock(BuildContext context) {
    showWarning(context, 'الكمية قليلة - يرجى إعادة التموين');
  }

  static void showUnsavedChanges(BuildContext context) {
    showWarning(context, 'يوجد تغييرات غير محفوظة');
  }

  static void showConfirmDelete(BuildContext context) {
    showWarning(context, 'هل أنت متأكد من الحذف؟');
  }

  static void showLoadingData(BuildContext context) {
    showLoading(context, 'جاري تحميل البيانات...');
  }

  static void showProcessingRequest(BuildContext context) {
    showLoading(context, 'جاري معالجة الطلب...');
  }

  static void showGeneratingReport(BuildContext context) {
    showLoading(context, 'جاري إنشاء التقرير...');
  }

  static void showSavingData(BuildContext context) {
    showLoading(context, 'جاري حفظ البيانات...');
  }

  static void showSystemReady(BuildContext context) {
    showInfo(context, 'النظام جاهز للاستخدام');
  }
}
