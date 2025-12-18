import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/cubit/user_cubit.dart';
import '../../data/models/daily_report_model.dart';
import '../../data/models/session_model.dart';
import '../../data/repositories/session_repository_impl.dart';

import '../../domain/daily_report_pdf_service.dart';
import 'daily_report_preview_screen.dart';
import 'package:printing/printing.dart';
import 'package:crazy_phone_pos/core/utils/hive_helper.dart';

class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  final _sessionRepo = getIt<SessionRepositoryImpl>();
  List<Session> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _loading = true);
    final sessions = _sessionRepo.getClosedSessions();
    // Sort by close time descending
    sessions.sort((a, b) => (b.closeTime ?? DateTime.now()).compareTo(a.closeTime ?? DateTime.now()));
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  Future<void> _openReport(Session session) async {
    if (session.dailyReportId == null) return;
    
    final reportBox = HiveHelper.dailyReportBox;
    final report = reportBox.get(session.dailyReportId);
    
    if (report == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر العثور على التقرير المرتبط بهذه الجلسة'))
        );
        return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DailyReportPreviewScreen(report: report),
      ),
    );
  }

  Future<void> _printReport(Session session) async {
    if (session.dailyReportId == null) return;
    
    final reportBox = HiveHelper.dailyReportBox;
    final report = reportBox.get(session.dailyReportId) as DailyReport?;
    
    if (report == null) return;

    final bytes = await DailyReportPdfService.generateDailyReportPDF(report);
    await Printing.layoutPdf(onLayout: (format) => bytes);
  }

  Future<void> _deleteSession(Session session) async {
    final currentUser = getIt<UserCubit>().currentUser;
    if (currentUser.userType != UserType.manager) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فقط المدير يمكنه حذف الجلسات.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد حذف الجلسة'),
        content: const Text(
            'هل أنت متأكد من حذف هذه الجلسة؟ سيتم حذف تقرير الإغلاق المرتبط بها نهائياً ولا يمكن التراجع.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorColor),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _sessionRepo.deleteSession(session);
      await _loadSessions();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الجلسة بنجاح.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل حذف الجلسة: $e')),
      );
    }
  }

  Future<void> _showBulkDeleteDialog() async {
    final currentUser = getIt<UserCubit>().currentUser;
    if (currentUser.userType != UserType.manager) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فقط المدير يمكنه حذف الجلسات.')),
      );
      return;
    }

    DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد حذف الجلسات'),
        content: Text(
            'هل أنت متأكد من حذف جميع الجلسات المغلقة بين ${DateFormat('yyyy-MM-dd').format(pickedRange.start)} و ${DateFormat('yyyy-MM-dd').format(pickedRange.end)}؟ سيتم حذف تقارير الإغلاق المرتبطة بها نهائياً.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorColor),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final deletedCount = await _sessionRepo.deleteSessionsInRange(
        DateTime(pickedRange.start.year, pickedRange.start.month, pickedRange.start.day, 0, 0, 0),
        DateTime(pickedRange.end.year, pickedRange.end.month, pickedRange.end.day, 23, 59, 59),
      );
      await _loadSessions();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف $deletedCount جلسة ضمن الفترة المحددة.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل حذف الجلسات: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: const Text('سجل الجلسات المغلقة'),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'حذف الجلسات ضمن فترة',
              onPressed: _showBulkDeleteDialog,
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _sessions.isEmpty
                ? const Center(child: Text('لا توجد جلسات مغلقة في السجل'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      final closeTime = session.closeTime ?? DateTime.now();
                      
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.history, color: AppColors.primaryColor),
                          ),
                          title: Text(
                            'جلسة #${session.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'إغلاق: ${DateFormat('yyyy-MM-dd HH:mm').format(closeTime)}\nبواسطة: ${session.closedByUserId ?? "غير معروف"}',
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.print, color: Colors.green),
                                onPressed: () => _printReport(session),
                                tooltip: 'طباعة التقرير',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                tooltip: 'حذف الجلسة',
                                onPressed: () => _deleteSession(session),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                          onTap: () => _openReport(session),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
