// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import '../../constants/app_colors.dart';
import 'data_persistence_manager.dart';
import '../repositories/settings_repository.dart';

/// Helper class to initialize the persistence system with user interaction
class PersistenceInitializer {
  static DataPersistenceManager? _persistenceManager;
  static SettingsRepository? _settingsRepository;

  static DataPersistenceManager? get persistenceManager => _persistenceManager;
  static SettingsRepository? get settingsRepository => _settingsRepository;

  /// Initialize persistence system
  static Future<bool> initialize() async {
    print('  🔧 Creating DataPersistenceManager instance...');
    _persistenceManager = DataPersistenceManager();
    
    final initialized = await _persistenceManager!.initialize();
    
    if (initialized) {
      print('  🏪 Creating SettingsRepository...');
      _settingsRepository = SettingsRepository(_persistenceManager!);
      print('  ✅ SettingsRepository ready');
      
      // Test store settings
      print('\n📋 Testing store settings...');
      try {
        final settings = await _settingsRepository!.getStoreSettings();
        print('✅ Store Name: ${settings.storeName}');
        print('✅ Store Address: ${settings.storeAddress ?? "Not set"}');
        print('✅ Store Phone: ${settings.storePhone ?? "Not set"}');
        print('✅ Invoice Prefix: ${settings.invoicePrefix}');
        print('✅ Last Invoice Number: ${settings.lastInvoiceNumber}');
      } catch (e) {
        print('⚠️ Store settings error: $e');
      }
      
      return true;
    }
    
    return false;
  }

  /// Show dialog to select data path
  static Future<bool> promptForDataPath(BuildContext context, {bool allowCancel = true}) async {
    if (_persistenceManager == null) {
      _persistenceManager = DataPersistenceManager();
      await _persistenceManager!.pathResolver.initialize();
    }

    final String message = allowCancel 
        ? 'اختر مجلداً آمناً لحفظ بيانات النظام.\nسيتم إنشاء مجلد "BayaaData" في المكان الذي تختاره.\n\nملاحظة: البيانات محمية ولن يتم حذفها عند إزالة البرنامج.'
        : 'الإعداد الأولي: اختر مكاناً لحفظ بيانات النظام.\n\nسيتم إنشاء مجلد "BayaaData".\nإذا كان لديك بيانات سابقة، اختر المجلد الذي يحتويها.\n\nالموقع الافتراضي: بجانب ملف التطبيق.';

    final shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: allowCancel,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor.withOpacity(0.2),
                      AppColors.primaryColor.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.folderKey,
                    size: 36,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                allowCancel ? 'مكان حفظ البيانات' : 'إعداد مسار البيانات',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (!allowCancel) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.info, size: 18, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'إذا كان لديك مجلد BayaaData سابق، اختر المجلد الأب الذي يحتويه وسيتم التعرف عليه تلقائياً.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  if (allowCancel)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "إلغاء",
                          style: TextStyle(
                            color: AppColors.mutedColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (allowCancel) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shadowColor: AppColors.primaryColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "اختيار المجلد",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(LucideIcons.folderSearch, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldContinue != true) {
      if (allowCancel) return false;
      // For mandatory setup, proceed even if dialog dismissed
    }

    print('  📂 Opening native folder picker (allowCancel: $allowCancel)...');
    final selected = await _persistenceManager!.promptForDataPath(allowCancel: allowCancel);
    print('  📂 Folder selection result: $selected');
    
    if (selected) {
      await _persistenceManager!.initialize();
      _settingsRepository = SettingsRepository(_persistenceManager!);
      return true;
    }

    return false;
  }

  /// Show dialog to change data location (migrate)
  static Future<bool> changeDataLocation(BuildContext context) async {
    if (_persistenceManager == null || !isEnabled) {
      return false;
    }

    final currentPath = _persistenceManager!.pathResolver.dataRootPath;
    
    // Step 1: Confirm with the user
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade300, width: 2),
                ),
                child: Icon(LucideIcons.folderOutput, size: 28, color: Colors.orange.shade700),
              ),
              const SizedBox(height: 20),
              const Text(
                'نقل البيانات إلى مكان جديد',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المكان الحالي:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mutedColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentPath,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.alertTriangle, size: 18, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سيتم نقل جميع البيانات والنسخ الاحتياطية.\nلا تغلق التطبيق أثناء النقل.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        "إلغاء",
                        style: TextStyle(color: AppColors.mutedColor, fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 4,
                        shadowColor: Colors.orange.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("اختيار المكان الجديد", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                          SizedBox(width: 8),
                          Icon(LucideIcons.folderOutput, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldProceed != true) return false;

    // Step 2: Pick new directory
    String? newPath;
    try {
      newPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'اختر المكان الجديد لحفظ البيانات',
        lockParentWindow: false,
      );
    } catch (e) {
      print('  ❌ FilePicker error: $e');
    }

    if (newPath == null) return false;

    // Step 3: Show progress and migrate
    bool migrationResult = false;

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(32),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primaryColor),
                SizedBox(height: 24),
                Text(
                  'جاري نقل البيانات...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  'لا تغلق التطبيق',
                  style: TextStyle(fontSize: 14, color: AppColors.mutedColor),
                ),
              ],
            ),
          ),
        ),
      );

      // Create backup before migration
      try {
        await _persistenceManager!.backupManager.createBackup();
      } catch (_) {}

      // Perform migration
      migrationResult = await _persistenceManager!.pathResolver.migrateData(newPath);

      // Close progress dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return migrationResult;
  }

  /// Check if persistence is enabled
  static bool get isEnabled => 
      _persistenceManager?.isEnabled ?? false;

  /// Shutdown persistence system
  static Future<void> shutdown() async {
    await _persistenceManager?.shutdown();
  }
}
