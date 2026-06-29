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

class _SessionHistoryScreenState extends State<SessionHistoryScreen>
    with TickerProviderStateMixin {
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

  // Tab controller for detail panel
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSessions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      closed.sort((a, b) =>
          (b.closeTime ?? DateTime.now())
              .compareTo(a.closeTime ?? DateTime.now()));
      all.addAll(closed);

      setState(() {
        _sessions = all;
        _loading = false;
      });

      if (_selectedSession != null) {
        final found =
            all.where((s) => s.id == _selectedSession!.id).firstOrNull;
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
      _reportFuture =
          getIt<SessionRepositoryImpl>().generateDailyReport(session.id);
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
      final activities =
          await getIt<ActivityLogger>().getActivitiesForSession(session.id);
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
            a.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            a.userName.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesType = _filterType == null || a.type == _filterType;
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  Future<void> _deleteSession(Session session) async {
    final currentUser = getIt<UserCubit>().currentUser;
    if (currentUser.userType != UserType.manager) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'فقط المدير يمكنه حذف الورديات.',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (session.isOpen) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'لا يمكن حذف الوردية الحالية وهي مفتوحة.',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.warningColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.trash2,
                    color: AppColors.errorColor, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'تأكيد حذف الوردية',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
              ),
            ],
          ),
          content: const Text(
            'هل أنت متأكد من حذف هذه الوردية؟ سيتم حذف تقرير الإغلاق المرتبط بها نهائياً ولا يمكن التراجع.',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.5,
                color: AppColors.textSecondary),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      'حذف',
                      style: TextStyle(
                          fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        } catch (_) {}
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
              'تم حذف الوردية بنجاح.',
              style:
                  TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            ),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل حذف الوردية: ${e.toString()}',
              style: const TextStyle(
                  fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            ),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  String _formatDuration(Session session) {
    if (session.closeTime == null) return 'نشطة الآن';
    final duration = session.closeTime!.difference(session.openTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}س ${minutes}د';
    return '${minutes}د';
  }

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        // ─── Left Panel: Shifts List ─────────────────────────
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(color: AppColors.borderColor.withOpacity(0.5)),
            ),
          ),
          child: _buildShiftList(),
        ),

        // ─── Right Panel: Detail / Empty state ──────────────
        Expanded(
          child: Container(
            color: AppColors.backgroundColor,
            child: _buildDetailPanel(),
          ),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return Directionality(textDirection: TextDirection.rtl, child: content);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: Directionality(textDirection: TextDirection.rtl, child: content),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryColor, AppColors.secondaryColor],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x221E3A8A),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            child: Row(
              children: [
                // Back button
                Material(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.calendarClock,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'سجل الورديات',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        '${_sessions.length} وردية مسجلة',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontFamily: 'Cairo',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Refresh button
                Material(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _loadSessions,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(LucideIcons.refreshCw,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Shift List Panel ──────────────────────────────────────
  Widget _buildShiftList() {
    return Column(
      children: [
        // Panel header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom:
                  BorderSide(color: AppColors.borderColor.withOpacity(0.5)),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.layoutList,
                    size: 15, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 10),
              const Text(
                'قائمة الورديات',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (!_loading)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_sessions.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // List body
        Expanded(
          child: _loading
              ? _buildListLoader()
              : _sessions.isEmpty
                  ? _buildEmptyShifts()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      itemCount: _sessions.length,
                      itemBuilder: (ctx, index) =>
                          _buildShiftCard(_sessions[index]),
                    ),
        ),
      ],
    );
  }

  Widget _buildListLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'جاري تحميل الورديات...',
            style: TextStyle(
                color: AppColors.mutedColor,
                fontSize: 12,
                fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyShifts() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.calendarOff,
                  size: 36, color: AppColors.mutedColor.withOpacity(0.4)),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد ورديات مسجلة',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              'ستُضاف الورديات تلقائياً فور فتحها وإغلاقها',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.mutedColor.withOpacity(0.8),
                  fontSize: 11,
                  fontFamily: 'Cairo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftCard(Session session) {
    final isSelected = _selectedSession?.id == session.id;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _selectSession(session),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryColor.withOpacity(0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryColor.withOpacity(0.45)
                    : AppColors.borderColor.withOpacity(0.45),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primaryColor.withOpacity(0.07)
                      : Colors.black.withOpacity(0.015),
                  blurRadius: isSelected ? 10 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: status badge + duration
                Row(
                  children: [
                    if (session.isOpen)
                      const StatusPulseIndicator(color: AppColors.successColor)
                    else
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.mutedColor.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: session.isOpen
                            ? AppColors.successColor.withOpacity(0.08)
                            : AppColors.mutedColor.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: session.isOpen
                              ? AppColors.successColor.withOpacity(0.2)
                              : AppColors.mutedColor.withOpacity(0.15),
                        ),
                      ),
                      child: Text(
                        session.isOpen ? 'نشطة' : 'مغلقة',
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          color: session.isOpen
                              ? AppColors.successColor
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color:
                                AppColors.secondaryColor.withOpacity(0.12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.clock,
                              size: 10, color: AppColors.secondaryColor),
                          const SizedBox(width: 3),
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
                const SizedBox(height: 10),

                // Shift ID
                Text(
                  'وردية #${(session.id.length > 8 ? session.id.substring(0, 8) : session.id).toUpperCase()}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Date row
                Row(
                  children: [
                    Icon(LucideIcons.calendar,
                        size: 11, color: AppColors.mutedColor.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(session.openTime),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(LucideIcons.user,
                        size: 11, color: AppColors.mutedColor.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        session.openedByUserId,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Time chips row
                Row(
                  children: [
                    _buildMiniTimeChip(
                      LucideIcons.logIn,
                      AppColors.successColor,
                      timeFormat.format(session.openTime),
                    ),
                    if (session.closeTime != null) ...[
                      const SizedBox(width: 6),
                      Icon(LucideIcons.arrowLeft,
                          size: 9,
                          color: AppColors.mutedColor.withOpacity(0.3)),
                      const SizedBox(width: 6),
                      _buildMiniTimeChip(
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
  }

  Widget _buildMiniTimeChip(IconData icon, Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color.withOpacity(0.8)),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary.withOpacity(0.75),
              fontFamily: 'Cairo'),
        ),
      ],
    );
  }

  // ─── Detail Panel ──────────────────────────────────────────
  Widget _buildDetailPanel() {
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
              child: Icon(LucideIcons.mousePointerClick,
                  size: 40, color: AppColors.mutedColor.withOpacity(0.3)),
            ),
            const SizedBox(height: 20),
            const Text(
              'اختر وردية لعرض تفاصيلها',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 6),
            Text(
              'اختر إحدى الورديات من القائمة لعرض سجل العمليات والتقرير المالي',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.mutedColor, fontSize: 12, fontFamily: 'Cairo'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Shift Detail Header Card
        _buildDetailHeader(_selectedSession!),

        // Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.mutedColor,
            indicatorColor: AppColors.primaryColor,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
            unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFamily: 'Cairo'),
            dividerColor: AppColors.borderColor.withOpacity(0.5),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(LucideIcons.list, size: 15),
                    SizedBox(width: 7),
                    Text('سجل العمليات'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(LucideIcons.fileText, size: 15),
                    SizedBox(width: 7),
                    Text('التقرير المالي'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildActivityLog(),
              _buildReportPreview(),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Detail Header ─────────────────────────────────────────
  Widget _buildDetailHeader(Session session) {
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor.withOpacity(0.5)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: title + actions
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.secondaryColor],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.calendarClock,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وردية #${(session.id.length > 12 ? session.id.substring(0, 12) : session.id).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: session.isOpen
                                ? AppColors.successColor.withOpacity(0.08)
                                : AppColors.mutedColor.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: session.isOpen
                                  ? AppColors.successColor.withOpacity(0.2)
                                  : AppColors.mutedColor.withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: session.isOpen
                                      ? AppColors.successColor
                                      : AppColors.mutedColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                session.isOpen
                                    ? 'وردية نشطة'
                                    : 'وردية مغلقة',
                                style: TextStyle(
                                  color: session.isOpen
                                      ? AppColors.successColor
                                      : AppColors.textSecondary,
                                  fontSize: 10.5,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(LucideIcons.user,
                            size: 12, color: AppColors.mutedColor),
                        const SizedBox(width: 4),
                        Text(
                          session.openedByUserId,
                          style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action buttons
              if (!session.isOpen) ...[
                _buildActionBtn(
                  icon: LucideIcons.printer,
                  tooltip: 'طباعة التقرير',
                  color: AppColors.primaryColor,
                  onPressed: () => _handlePrintReport(session),
                ),
                const SizedBox(width: 8),
              ],
              _buildActionBtn(
                icon: LucideIcons.trash2,
                tooltip: 'حذف الوردية',
                color: AppColors.errorColor,
                onPressed: () => _deleteSession(session),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats chips row
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildStatChip(
                LucideIcons.logIn,
                'بدء الوردية',
                '${dateFormat.format(session.openTime)}  ${timeFormat.format(session.openTime)}',
                AppColors.successColor,
              ),
              if (session.closeTime != null) ...[
                _buildStatChip(
                  LucideIcons.logOut,
                  'إغلاق الوردية',
                  '${dateFormat.format(session.closeTime!)}  ${timeFormat.format(session.closeTime!)}',
                  AppColors.warningColor,
                ),
                _buildStatChip(
                  LucideIcons.clock,
                  'إجمالي المدة',
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

  Widget _buildActionBtn({
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
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.15)),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 9.5,
                      color: AppColors.mutedColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo')),
              const SizedBox(height: 1),
              Text(value,
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Cairo')),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Activity Log ──────────────────────────────────────────
  Widget _buildActivityLog() {
    return Column(
      children: [
        // Filter toolbar
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                  color: AppColors.borderColor.withOpacity(0.4)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.borderColor.withOpacity(0.4)),
                  ),
                  child: TextField(
                    style: const TextStyle(
                        fontFamily: 'Cairo', fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: 'بحث بالعملية أو اسم المستخدم...',
                      hintStyle: TextStyle(
                          color: AppColors.mutedColor.withOpacity(0.55),
                          fontSize: 12,
                          fontFamily: 'Cairo'),
                      prefixIcon: Icon(LucideIcons.search,
                          size: 16,
                          color: AppColors.mutedColor.withOpacity(0.5)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 9),
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                      _applyFilters();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  border: Border.all(
                      color: AppColors.borderColor.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ActivityType?>(
                    value: _filterType,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textPrimary,
                        fontSize: 12),
                    hint: Text('كل العمليات',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedColor,
                            fontFamily: 'Cairo')),
                    icon: Icon(LucideIcons.chevronDown,
                        size: 14, color: AppColors.mutedColor),
                    isDense: true,
                    items: [
                      const DropdownMenuItem(
                          value: null,
                          child: Text('كل العمليات',
                              style: TextStyle(
                                  fontSize: 12, fontFamily: 'Cairo'))),
                      ...ActivityType.values.map((type) =>
                          DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Icon(_getIconForType(type),
                                    size: 12,
                                    color: _getColorForType(type)),
                                const SizedBox(width: 6),
                                Text(_getTypeName(type),
                                    style: const TextStyle(
                                        fontSize: 12, fontFamily: 'Cairo')),
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

        // Timeline
        Expanded(
          child: _loadingActivities
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryColor, strokeWidth: 2.5))
              : _filteredActivities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.04),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(LucideIcons.filterX,
                                size: 36,
                                color:
                                    AppColors.mutedColor.withOpacity(0.3)),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'لا توجد عمليات تطابق البحث',
                            style: TextStyle(
                                color: AppColors.mutedColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      itemCount: _filteredActivities.length,
                      itemBuilder: (context, index) =>
                          _buildTimelineItem(index),
                    ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(int index) {
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
          // Timeline line + icon
          SizedBox(
            width: 42,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: color.withOpacity(0.22)),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(_getIconForType(activity.type),
                      color: color, size: 13),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.25),
                            AppColors.borderColor.withOpacity(0.15),
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
          const SizedBox(width: 10),
          // Content card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: isSessionEvent
                    ? color.withOpacity(0.04)
                    : Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: isSessionEvent
                      ? color.withOpacity(0.18)
                      : AppColors.borderColor.withOpacity(0.4),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x04000000),
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
                            color: isSessionEvent
                                ? color
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        timeFormat.format(activity.timestamp),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color:
                                AppColors.mutedColor.withOpacity(0.75),
                            fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(LucideIcons.user,
                          size: 11,
                          color: AppColors.primaryColor.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Text(
                        activity.userName,
                        style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                  if (activity.details != null &&
                      activity.details!.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      ActivityLogger.formatDetailsArabic(
                          activity.type, activity.details),
                      style: TextStyle(
                          fontSize: 11,
                          color:
                              AppColors.textSecondary.withOpacity(0.8),
                          fontFamily: 'Cairo'),
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
  }

  // ─── Report Preview ────────────────────────────────────────
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
              child: Icon(LucideIcons.fileClock,
                  size: 42, color: AppColors.mutedColor.withOpacity(0.35)),
            ),
            const SizedBox(height: 18),
            const Text(
              'التقرير يتاح بعد إغلاق الوردية',
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 6),
            Text(
              'أغلق الوردية الحالية لإنشاء التقرير المالي وعرض الإحصائيات',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.mutedColor,
                  fontFamily: 'Cairo'),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<DailyReport?>(
      future: _reportFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
                color: AppColors.primaryColor, strokeWidth: 2.5),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.alertTriangle,
                      size: 38,
                      color: AppColors.errorColor.withOpacity(0.6)),
                ),
                const SizedBox(height: 14),
                const Text('فشل تحميل التقرير المالي',
                    style: TextStyle(
                        color: AppColors.errorColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Cairo')),
                const SizedBox(height: 4),
                Text('${snapshot.error}',
                    style: TextStyle(
                        color: AppColors.mutedColor,
                        fontSize: 11,
                        fontFamily: 'Cairo')),
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
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.fileQuestion,
                      size: 38,
                      color: AppColors.mutedColor.withOpacity(0.35)),
                ),
                const SizedBox(height: 14),
                const Text('لم يتم العثور على تقرير مالي',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo')),
                const SizedBox(height: 4),
                Text('تأكد من إغلاق الوردية بنجاح',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedColor,
                        fontFamily: 'Cairo')),
              ],
            ),
          );
        }

        final report = snapshot.data!;

        return Column(
          children: [
            // Report summary strip
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(
                        color: AppColors.borderColor.withOpacity(0.4))),
              ),
              child: Row(
                children: [
                  _buildReportStat(
                    'صافي المبيعات',
                    '${report.netRevenue.toStringAsFixed(0)} ج.م',
                    const Color(0xFF059669),
                    LucideIcons.trendingUp,
                  ),
                  _buildReportStatDivider(),
                  _buildReportStat(
                    'عمليات البيع',
                    '${report.totalTransactions}',
                    AppColors.secondaryColor,
                    LucideIcons.receipt,
                  ),
                  _buildReportStatDivider(),
                  _buildReportStat(
                    'المرتجعات',
                    '${report.totalRefunds.toStringAsFixed(0)} ج.م',
                    AppColors.errorColor,
                    LucideIcons.cornerUpLeft,
                  ),
                  const Spacer(),
                  _buildReportActionBtn(
                    icon: LucideIcons.printer,
                    label: 'طباعة',
                    color: AppColors.primaryColor,
                    onTap: () => _handlePrintReport(_selectedSession!),
                  ),
                  const SizedBox(width: 8),
                  _buildReportActionBtn(
                    icon: LucideIcons.table,
                    label: 'الجدول',
                    color: AppColors.secondaryColor,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          insetPadding: const EdgeInsets.all(32),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            width:
                                MediaQuery.of(context).size.width * 0.85,
                            height:
                                MediaQuery.of(context).size.height * 0.85,
                            child: DailyReportDatasheetScreen(
                                report: report),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // PDF Preview
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

  Widget _buildReportStat(
      String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 9.5,
                      color: AppColors.mutedColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo')),
              const SizedBox(height: 1),
              Text(value,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontFamily: 'Cairo')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportStatDivider() {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: AppColors.borderColor.withOpacity(0.3),
    );
  }

  Widget _buildReportActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontFamily: 'Cairo')),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Print Report ──────────────────────────────────────────
  Future<void> _handlePrintReport(Session session) async {
    try {
      final repo = getIt<SessionRepositoryImpl>();
      final report = await repo.generateDailyReport(session.id);

      if (report == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يوجد تقرير لهذه الوردية',
                  style: TextStyle(fontFamily: 'Cairo')),
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
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            width: 900,
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: AppColors.borderColor.withOpacity(0.5))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'معاينة التقرير قبل الطباعة',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontFamily: 'Cairo'),
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
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(bottom: Radius.circular(16)),
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
          SnackBar(
            content: Text('فشل تحميل التقرير: $e',
                style: const TextStyle(fontFamily: 'Cairo')),
          ),
        );
      }
    }
  }

  // ─── Helper Maps ───────────────────────────────────────────
  IconData _getIconForType(ActivityType type) {
    switch (type) {
      case ActivityType.sale:
        return LucideIcons.shoppingCart;
      case ActivityType.refund:
        return LucideIcons.cornerUpLeft;
      case ActivityType.productAdd:
        return LucideIcons.packagePlus;
      case ActivityType.productUpdate:
        return LucideIcons.pencil;
      case ActivityType.productDelete:
        return LucideIcons.trash2;
      case ActivityType.productQuantityUpdate:
        return LucideIcons.package;
      case ActivityType.userAdd:
        return LucideIcons.userPlus;
      case ActivityType.userUpdate:
        return LucideIcons.userCheck;
      case ActivityType.userDelete:
        return LucideIcons.userMinus;
      case ActivityType.sessionOpen:
        return LucideIcons.logIn;
      case ActivityType.sessionClose:
        return LucideIcons.logOut;
      case ActivityType.restock:
        return LucideIcons.packagePlus;
      case ActivityType.expense:
        return LucideIcons.banknote;
      case ActivityType.invoiceDelete:
        return LucideIcons.fileMinus;
      case ActivityType.printReport:
        return LucideIcons.printer;
      case ActivityType.login:
        return LucideIcons.key;
    }
  }

  Color _getColorForType(ActivityType type) {
    switch (type) {
      case ActivityType.sale:
        return AppColors.successColor;
      case ActivityType.refund:
        return AppColors.warningColor;
      case ActivityType.productAdd:
        return AppColors.primaryColor;
      case ActivityType.productUpdate:
        return AppColors.accentGold;
      case ActivityType.productDelete:
        return AppColors.errorColor;
      case ActivityType.productQuantityUpdate:
        return Colors.purple;
      case ActivityType.userAdd:
        return Colors.blue;
      case ActivityType.userUpdate:
        return Colors.teal;
      case ActivityType.userDelete:
        return Colors.red;
      case ActivityType.sessionOpen:
        return Colors.green;
      case ActivityType.sessionClose:
        return Colors.orange;
      case ActivityType.restock:
        return Colors.indigo;
      case ActivityType.expense:
        return Colors.brown;
      case ActivityType.invoiceDelete:
        return AppColors.errorColor;
      case ActivityType.printReport:
        return Colors.blueGrey;
      case ActivityType.login:
        return Colors.cyan;
    }
  }

  String _getTypeName(ActivityType type) {
    switch (type) {
      case ActivityType.sale:
        return 'عملية بيع';
      case ActivityType.refund:
        return 'مرتجع';
      case ActivityType.productAdd:
        return 'إضافة منتج';
      case ActivityType.productUpdate:
        return 'تعديل منتج';
      case ActivityType.productDelete:
        return 'حذف منتج';
      case ActivityType.productQuantityUpdate:
        return 'تعديل كمية';
      case ActivityType.userAdd:
        return 'إضافة مستخدم';
      case ActivityType.userUpdate:
        return 'تعديل صلاحيات';
      case ActivityType.userDelete:
        return 'حذف مستخدم';
      case ActivityType.sessionOpen:
        return 'فتح وردية';
      case ActivityType.sessionClose:
        return 'إغلاق وردية';
      case ActivityType.restock:
        return 'شحنة جديدة';
      case ActivityType.expense:
        return 'مصروفات';
      case ActivityType.invoiceDelete:
        return 'حذف فاتورة';
      case ActivityType.printReport:
        return 'طباعة تقرير';
      case ActivityType.login:
        return 'تسجيل دخول';
    }
  }
}

// ─── Pulse Indicator Widget ─────────────────────────────────
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
