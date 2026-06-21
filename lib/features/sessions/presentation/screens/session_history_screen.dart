// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/models/activity_log.dart';
import '../../../../core/services/activity_logger.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../data/repositories/session_repository_impl.dart';
import '../../data/models/session_model.dart';
import '../../data/models/daily_report_model.dart';
import '../../../analytics/domain/analytics_repository.dart';
import '../../../auth/presentation/cubit/user_cubit.dart';
import '../../../auth/data/models/user_model.dart';
import 'daily_report_preview_screen.dart';
import 'daily_report_datasheet_screen.dart';

class SessionHistoryScreen extends StatefulWidget {
  final bool isEmbedded;

  const SessionHistoryScreen({super.key, this.isEmbedded = false});

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> with TickerProviderStateMixin {
  List<Session> _sessions = [];
  bool _loading = true;
  Session? _selectedSession;
  
  // Activity Log State
  List<ActivityLog> _allActivities = [];
  List<ActivityLog> _filteredActivities = [];
  bool _loadingActivities = false;
  String _searchQuery = '';
  ActivityType? _filterType;

  // Report State
  Future<DailyReport?>? _reportFuture;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _loading = true);
    try {
      final repo = getIt<SessionRepositoryImpl>();
      final current = repo.getCurrentSession();
      final closed = await repo.getClosedSessions();

      final all = <Session>[];
      if (current != null && current.isOpen) {
        all.add(current);
      }
      closed.sort((a, b) => (b.closeTime ?? DateTime.now()).compareTo(a.closeTime ?? DateTime.now()));
      all.addAll(closed);

      setState(() {
        _sessions = all;
        _loading = false;
      });
      
      if (_selectedSession != null) {
        final found = all.where((s) => s.id == _selectedSession!.id).firstOrNull;
        if (found != null) {
          _selectSession(found, refreshLogs: false);
        } else {
          setState(() => _selectedSession = null);
        }
      } else if (all.isNotEmpty) {
        _selectSession(all.first);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _selectSession(Session session, {bool refreshLogs = true}) {
    setState(() {
      _selectedSession = session;
      _reportFuture = getIt<SessionRepositoryImpl>().generateDailyReport(session.id);
    });

    if (refreshLogs) {
      _loadActivities(session);
    }
  }

  Future<void> _loadActivities(Session session) async {
    setState(() {
      _loadingActivities = true;
      _allActivities = [];
      _filteredActivities = [];
    });

    try {
      final activities = await getIt<ActivityLogger>().getActivitiesForSession(session.id);
      activities.sort((a, b) {
        if (a.type == ActivityType.sessionOpen) return -1;
        if (b.type == ActivityType.sessionOpen) return 1;
        if (a.type == ActivityType.sessionClose) return 1;
        if (b.type == ActivityType.sessionClose) return -1;
        return a.timestamp.compareTo(b.timestamp);
      });

      setState(() {
        _allActivities = activities;
        _loadingActivities = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() => _loadingActivities = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredActivities = _allActivities.where((a) {
        final matchesSearch = _searchQuery.isEmpty ||
            a.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            a.userName.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesType = _filterType == null || a.type == _filterType;
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  Future<void> _deleteSession(Session session) async {
    final currentUser = getIt<UserCubit>().currentUser;
    if (currentUser.userType != UserType.manager) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'فقط المدير يمكنه حذف الأيام.',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (session.isOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'لا يمكن حذف اليوم الحالي وهو مفتوح.',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.trash2, color: AppColors.errorColor, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'تأكيد حذف اليوم',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من حذف هذا اليوم؟ سيتم حذف تقرير الإغلاق المرتبط به نهائياً ولا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    'حذف',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final sessionRepo = getIt<SessionRepositoryImpl>();
      final analyticsRepo = getIt<AnalyticsRepository>();

      await sessionRepo.deleteSession(session);
      if (session.dailyReportId != null) {
        try {
          await analyticsRepo.deleteReport(session.dailyReportId!);
        } catch (e) {
          // ignore
        }
      }
      
      await _loadSessions();
      setState(() {
        if (_selectedSession?.id == session.id) {
          _selectedSession = null;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'تم حذف اليوم بنجاح.',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            ),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل حذف اليوم: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            ),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  String _formatDuration(Session session) {
    if (session.closeTime == null) return 'نشط الآن';
    final duration = session.closeTime!.difference(session.openTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hoursس $minutesد';
    }
    return '$minutesد';
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      children: [
        // Session List (Right)
        SizedBox(
          width: 360,
          child: _buildSessionList(),
        ),
        Container(
          width: 1,
          color: AppColors.borderColor.withOpacity(0.4),
        ),
        // Detail (Left)
        Expanded(
          child: _buildBody(),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return Directionality(textDirection: TextDirection.rtl, child: content);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildGradientAppBar(),
      body: Directionality(textDirection: TextDirection.rtl, child: content),
    );
  }

  PreferredSizeWidget _buildGradientAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryColor, AppColors.secondaryColor],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A1E3A8A),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                const Icon(LucideIcons.history, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'سجل الأيام والعمليات',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'إجمالي ${_sessions.length} يوم عمل',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontFamily: 'Cairo',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionList() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryColor),
            const SizedBox(height: 16),
            Text(
              'جاري تحميل سجل الأيام...',
              style: TextStyle(color: AppColors.mutedColor, fontSize: 13, fontFamily: 'Cairo'),
            ),
          ],
        ),
      );
    }
    if (_sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.inbox, size: 40, color: AppColors.mutedColor.withOpacity(0.5)),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد أيام مسجلة بعد',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 4),
            Text(
              'سيتم إدراج الأيام فور فتح وإغلاق الفترات',
              style: TextStyle(color: AppColors.mutedColor.withOpacity(0.8), fontSize: 11, fontFamily: 'Cairo'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              const Text(
                'قائمة الفترات',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_sessions.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            itemCount: _sessions.length,
            itemBuilder: (context, index) {
              final session = _sessions[index];
              final isSelected = _selectedSession?.id == session.id;
              final timeFormat = DateFormat('hh:mm a');
              final dateFormat = DateFormat('dd/MM/yyyy');

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectSession(session),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryColor.withOpacity(0.04)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryColor.withOpacity(0.4)
                              : AppColors.borderColor.withOpacity(0.4),
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.01),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (session.isOpen)
                                const StatusPulseIndicator(color: AppColors.successColor)
                              else
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.mutedColor.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: session.isOpen
                                      ? AppColors.successColor.withOpacity(0.08)
                                      : AppColors.mutedColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: session.isOpen
                                        ? AppColors.successColor.withOpacity(0.16)
                                        : AppColors.mutedColor.withOpacity(0.16),
                                  ),
                                ),
                                child: Text(
                                  session.isOpen ? 'نشط الآن' : 'مغلق',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    color: session.isOpen ? AppColors.successColor : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Duration badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryColor.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.secondaryColor.withOpacity(0.12)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.clock, size: 12, color: AppColors.secondaryColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDuration(session),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'يوم #${(session.id.length > 8 ? session.id.substring(0, 8) : session.id).toUpperCase()}',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: isSelected ? AppColors.primaryColor : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(LucideIcons.user, size: 12, color: AppColors.mutedColor.withOpacity(0.8)),
                              const SizedBox(width: 6),
                              Text(
                                'المدخل: ${session.openedByUserId}',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Time Chips
                          Row(
                            children: [
                              _buildTimeChip(
                                LucideIcons.logIn,
                                AppColors.successColor,
                                '${dateFormat.format(session.openTime)} ${timeFormat.format(session.openTime)}',
                              ),
                              if (session.closeTime != null) ...[
                                const SizedBox(width: 6),
                                Icon(LucideIcons.chevronLeft, size: 10, color: AppColors.mutedColor.withOpacity(0.4)),
                                const SizedBox(width: 6),
                                _buildTimeChip(
                                  LucideIcons.logOut,
                                  AppColors.warningColor,
                                  timeFormat.format(session.closeTime!),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeChip(IconData icon, Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color.withOpacity(0.8)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary.withOpacity(0.8), fontFamily: 'Cairo'),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_selectedSession == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.mousePointerClick, size: 44, color: AppColors.mutedColor.withOpacity(0.35)),
            ),
            const SizedBox(height: 20),
            const Text(
              'حدد فترة لعرض تفاصيلها',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 6),
            Text(
              'اختر أحد الأيام من القائمة الجانبية لتفحص التقرير والعمليات',
              style: TextStyle(color: AppColors.mutedColor, fontSize: 12, fontFamily: 'Cairo'),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _buildDetailHeader(),
          
          // TabBar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.borderColor.withOpacity(0.4))),
            ),
            child: TabBar(
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppColors.mutedColor,
              indicatorColor: AppColors.primaryColor,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.list, size: 16),
                      const SizedBox(width: 8),
                      const Text('سجل العمليات اليومي'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.fileText, size: 16),
                      const SizedBox(width: 8),
                      const Text('التقرير المالي اليومي'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActivityList(),
                _buildReportPreview(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader() {
    final session = _selectedSession!;
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderColor.withOpacity(0.4))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.12)),
                ),
                child: const Icon(LucideIcons.monitor, color: AppColors.primaryColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تفاصيل فترة العمل #${(session.id.length > 12 ? session.id.substring(0, 12) : session.id).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: session.isOpen
                                ? AppColors.successColor.withOpacity(0.08)
                                : AppColors.mutedColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: session.isOpen
                                  ? AppColors.successColor.withOpacity(0.24)
                                  : AppColors.mutedColor.withOpacity(0.24),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: session.isOpen ? AppColors.successColor : AppColors.mutedColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                session.isOpen ? 'مفتوحة حالياً' : 'مغلقة ومؤرشفة',
                                style: TextStyle(
                                  color: session.isOpen ? AppColors.successColor : AppColors.textSecondary,
                                  fontSize: 11,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(LucideIcons.user, size: 13, color: AppColors.mutedColor),
                        const SizedBox(width: 4),
                        Text(
                          session.openedByUserId,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!session.isOpen) ...[
                _buildHeaderAction(
                  icon: LucideIcons.printer,
                  tooltip: 'طباعة التقرير',
                  color: AppColors.primaryColor,
                  onPressed: () => _handlePrintReport(session),
                ),
                const SizedBox(width: 8),
              ],
              _buildHeaderAction(
                icon: LucideIcons.trash2,
                tooltip: 'حذف الفترة',
                color: AppColors.errorColor,
                onPressed: () => _deleteSession(session),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Stats row
          Row(
            children: [
              _buildHeaderStat(
                LucideIcons.logIn, 
                'بدء العمل', 
                '${dateFormat.format(session.openTime)}   ${timeFormat.format(session.openTime)}',
                AppColors.successColor,
              ),
              if (session.closeTime != null) ...[
                const SizedBox(width: 24),
                _buildHeaderStat(
                  LucideIcons.logOut, 
                  'إغلاق العمل', 
                  '${dateFormat.format(session.closeTime!)}   ${timeFormat.format(session.closeTime!)}',
                  AppColors.warningColor,
                ),
                const SizedBox(width: 24),
                _buildHeaderStat(
                  LucideIcons.clock,
                  'المدة الكلية',
                  _formatDuration(session),
                  AppColors.secondaryColor,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.15)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: AppColors.mutedColor, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'Cairo')),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityList() {
    return Column(
      children: [
        // Filter Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.borderColor.withOpacity(0.4))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor.withOpacity(0.4)),
                  ),
                  child: TextField(
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'بحث باسم المستخدم أو العملية...',
                      hintStyle: TextStyle(color: AppColors.mutedColor.withOpacity(0.6), fontSize: 12, fontFamily: 'Cairo'),
                      prefixIcon: Icon(LucideIcons.search, size: 18, color: AppColors.mutedColor.withOpacity(0.5)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                      _applyFilters();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  border: Border.all(color: AppColors.borderColor.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ActivityType?>(
                    value: _filterType,
                    style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textPrimary, fontSize: 12),
                    hint: Text('كل العمليات', style: TextStyle(fontSize: 12, color: AppColors.mutedColor, fontFamily: 'Cairo')),
                    icon: Icon(LucideIcons.chevronDown, size: 16, color: AppColors.mutedColor),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('كل العمليات', style: TextStyle(fontSize: 12, fontFamily: 'Cairo'))),
                      ...ActivityType.values.map((type) => DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(_getIconForType(type), size: 13, color: _getColorForType(type)),
                            const SizedBox(width: 8),
                            Text(_getTypeName(type), style: const TextStyle(fontSize: 12, fontFamily: 'Cairo')),
                          ],
                        ),
                      )),
                    ],
                    onChanged: (val) {
                      setState(() => _filterType = val);
                      _applyFilters();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Timeline List
        Expanded(
          child: _loadingActivities
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
              : _filteredActivities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.04),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(LucideIcons.filterX, size: 40, color: AppColors.mutedColor.withOpacity(0.35)),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'لا توجد عمليات تطابق البحث',
                            style: TextStyle(color: AppColors.mutedColor, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      itemCount: _filteredActivities.length,
                      itemBuilder: (context, index) {
                        final activity = _filteredActivities[index];
                        final timeFormat = DateFormat('hh:mm:ss a');
                        final isSessionEvent = activity.type == ActivityType.sessionOpen ||
                            activity.type == ActivityType.sessionClose;
                        final color = _getColorForType(activity.type);
                        final isLast = index == _filteredActivities.length - 1;

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Timeline Column
                              SizedBox(
                                width: 44,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: color.withOpacity(0.24)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: color.withOpacity(0.04),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(_getIconForType(activity.type), color: color, size: 14),
                                    ),
                                    if (!isLast)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.3),
                                                AppColors.borderColor.withOpacity(0.2),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius: BorderRadius.circular(1),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Content Card
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isSessionEvent
                                        ? color.withOpacity(0.04)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSessionEvent
                                          ? color.withOpacity(0.2)
                                          : AppColors.borderColor.withOpacity(0.4),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x05000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              activity.description,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.5,
                                                fontFamily: 'Cairo',
                                                color: isSessionEvent ? color : AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            timeFormat.format(activity.timestamp),
                                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.mutedColor.withOpacity(0.8), fontFamily: 'Cairo'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(LucideIcons.user, size: 12, color: AppColors.primaryColor.withOpacity(0.6)),
                                          const SizedBox(width: 4),
                                          Text(
                                            activity.userName,
                                            style: const TextStyle(fontSize: 11, color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                                          ),
                                        ],
                                      ),
                                      if (activity.details != null && activity.details!.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          ActivityLogger.formatDetailsArabic(activity.type, activity.details),
                                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withOpacity(0.8), fontFamily: 'Cairo'),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildReportPreview() {
    if (_selectedSession == null || _selectedSession!.isOpen) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.fileClock, size: 44, color: AppColors.mutedColor.withOpacity(0.4)),
            ),
            const SizedBox(height: 20),
            const Text(
              'التقرير اليومي يتاح فقط بعد إغلاق يوم العمل',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 6),
            Text(
              'يرجى إغلاق الفترة الحالية لإنشاء التقرير وعرض الإحصائيات',
              style: TextStyle(fontSize: 11, color: AppColors.mutedColor, fontFamily: 'Cairo'),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<DailyReport?>(
      future: _reportFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.alertTriangle, size: 40, color: AppColors.errorColor.withOpacity(0.6)),
                ),
                const SizedBox(height: 16),
                const Text('فشل تحميل التقرير اليومي', style: TextStyle(color: AppColors.errorColor, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo')),
                const SizedBox(height: 6),
                Text('${snapshot.error}', style: TextStyle(color: AppColors.mutedColor, fontSize: 12, fontFamily: 'Cairo')),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.fileQuestion, size: 40, color: AppColors.mutedColor.withOpacity(0.4)),
                ),
                const SizedBox(height: 16),
                const Text('لم يتم العثور على تقرير مالي اليوم', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                const SizedBox(height: 6),
                Text('تأكد من إغلاق الفترة بنجاح', style: TextStyle(fontSize: 11, color: AppColors.mutedColor, fontFamily: 'Cairo')),
              ],
            ),
          );
        }

        final report = snapshot.data!;
        
        return Column(
          children: [
            // Summary strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.borderColor.withOpacity(0.4))),
              ),
              child: Row(
                children: [
                  _buildReportStat('صافي المبيعات', '${report.netRevenue.toStringAsFixed(0)} ج.م', const Color(0xFF059669), LucideIcons.trendingUp),
                  _buildReportStatDivider(),
                  _buildReportStat('عدد العمليات', '${report.totalTransactions}', AppColors.secondaryColor, LucideIcons.receipt),
                  _buildReportStatDivider(),
                  _buildReportStat('إجمالي المرتجعات', '${report.totalRefunds.toStringAsFixed(0)} ج.م', AppColors.errorColor, LucideIcons.cornerUpLeft),
                  const Spacer(),
                  // Actions
                  _buildReportAction(
                    icon: LucideIcons.printer,
                    label: 'طباعة التقرير',
                    color: AppColors.primaryColor,
                    onTap: () => _handlePrintReport(_selectedSession!),
                  ),
                  const SizedBox(width: 8),
                  _buildReportAction(
                    icon: LucideIcons.table,
                    label: 'جدول البيانات',
                    color: AppColors.secondaryColor,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          insetPadding: const EdgeInsets.all(32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.85,
                            height: MediaQuery.of(context).size.height * 0.85,
                            child: DailyReportDatasheetScreen(report: report),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // PDF Preview section
            Expanded(
              child: DailyReportPreviewScreen(
                report: report,
                session: _selectedSession,
                isEmbedded: true,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handlePrintReport(Session session) async {
    try {
      final repo = getIt<SessionRepositoryImpl>();
      final report = await repo.generateDailyReport(session.id);

      if (report == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يوجد تقرير لهذا اليوم', style: TextStyle(fontFamily: 'Cairo')),
            ),
          );
        }
        return;
      }
      
      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            width: 900,
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Dialog Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.borderColor.withOpacity(0.5))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'معاينة التقرير المطبوع', 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'Cairo')
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Dialog Content
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    child: DailyReportPreviewScreen(
                      report: report,
                      session: session,
                      isEmbedded: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل التقرير: $e', style: const TextStyle(fontFamily: 'Cairo'))),
        );
      }
    }
  }

  Widget _buildReportStat(String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: AppColors.mutedColor, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color, fontFamily: 'Cairo')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportStatDivider() {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.borderColor.withOpacity(0.3),
    );
  }

  Widget _buildReportAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color, fontFamily: 'Cairo')),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(ActivityType type) {
    switch (type) {
      case ActivityType.sale: return LucideIcons.shoppingCart;
      case ActivityType.refund: return LucideIcons.cornerUpLeft;
      case ActivityType.productAdd: return LucideIcons.packagePlus;
      case ActivityType.productUpdate: return LucideIcons.pencil;
      case ActivityType.productDelete: return LucideIcons.trash2;
      case ActivityType.productQuantityUpdate: return LucideIcons.package;
      case ActivityType.userAdd: return LucideIcons.userPlus;
      case ActivityType.userUpdate: return LucideIcons.userCheck;
      case ActivityType.userDelete: return LucideIcons.userMinus;
      case ActivityType.sessionOpen: return LucideIcons.logIn;
      case ActivityType.sessionClose: return LucideIcons.logOut;
      case ActivityType.restock: return LucideIcons.packagePlus;
      case ActivityType.expense: return LucideIcons.banknote;
      case ActivityType.invoiceDelete: return LucideIcons.fileMinus;
      case ActivityType.printReport: return LucideIcons.printer;
      case ActivityType.login: return LucideIcons.key;
    }
  }

  Color _getColorForType(ActivityType type) {
    switch (type) {
      case ActivityType.sale: return AppColors.successColor;
      case ActivityType.refund: return AppColors.warningColor;
      case ActivityType.productAdd: return AppColors.primaryColor;
      case ActivityType.productUpdate: return AppColors.accentGold;
      case ActivityType.productDelete: return AppColors.errorColor;
      case ActivityType.productQuantityUpdate: return Colors.purple;
      case ActivityType.userAdd: return Colors.blue;
      case ActivityType.userUpdate: return Colors.teal;
      case ActivityType.userDelete: return Colors.red;
      case ActivityType.sessionOpen: return Colors.green;
      case ActivityType.sessionClose: return Colors.orange;
      case ActivityType.restock: return Colors.indigo;
      case ActivityType.expense: return Colors.brown;
      case ActivityType.invoiceDelete: return AppColors.errorColor;
      case ActivityType.printReport: return Colors.blueGrey;
      case ActivityType.login: return Colors.cyan;
    }
  }

  String _getTypeName(ActivityType type) {
    switch (type) {
      case ActivityType.sale: return 'عملية بيع';
      case ActivityType.refund: return 'مرتجع';
      case ActivityType.productAdd: return 'إضافة منتج';
      case ActivityType.productUpdate: return 'تعديل منتج';
      case ActivityType.productDelete: return 'حذف منتج';
      case ActivityType.productQuantityUpdate: return 'تعديل كمية';
      case ActivityType.userAdd: return 'إضافة مستخدم';
      case ActivityType.userUpdate: return 'تعديل صلاحيات';
      case ActivityType.userDelete: return 'حذف مستخدم';
      case ActivityType.sessionOpen: return 'فتح يومية';
      case ActivityType.sessionClose: return 'إغلاق يومية';
      case ActivityType.restock: return 'شحنة جديدة';
      case ActivityType.expense: return 'مصروفات';
      case ActivityType.invoiceDelete: return 'حذف فاتورة';
      case ActivityType.printReport: return 'طباعة تقرير';
      case ActivityType.login: return 'تسجيل دخول';
    }
  }
}

class StatusPulseIndicator extends StatefulWidget {
  final Color color;
  const StatusPulseIndicator({super.key, required this.color});

  @override
  State<StatusPulseIndicator> createState() => _StatusPulseIndicatorState();
}

class _StatusPulseIndicatorState extends State<StatusPulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 12,
          height: 12,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 12 * _controller.value,
                height: 12 * _controller.value,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(1 - _controller.value),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
