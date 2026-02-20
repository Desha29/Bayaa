import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:lucide_icons/lucide_icons.dart';

import 'package:printing/printing.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/models/activity_log.dart';
import '../../../../core/services/activity_logger.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../data/repositories/session_repository_impl.dart';
import '../../data/models/session_model.dart';
import '../../data/models/daily_report_model.dart';
import '../../domain/arp_repository.dart';
import '../../domain/daily_report_pdf_service.dart';
import '../../../auth/presentation/cubit/user_cubit.dart';
import '../../../auth/data/models/user_model.dart';
import 'daily_report_preview_screen.dart';
import 'daily_report_datasheet_screen.dart';

/// Consolidated Session History Screen
/// Features:
/// - Master-Detail layout for Sessions
/// - Activity Logs with filtering
/// - Daily Report Preview (Embedded)
/// - Session Management (Delete, Print)
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
        // Auto-select the first session so operations are visible immediately
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

  // --- Actions ---

  Future<void> _deleteSession(Session session) async {
    final currentUser = getIt<UserCubit>().currentUser;
    if (currentUser.userType != UserType.manager) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('فقط المدير يمكنه حذف الأيام.'),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (session.isOpen) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('لا يمكن حذف اليوم الحالي وهو مفتوح.'),
          backgroundColor: AppColors.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.alertTriangle, color: AppColors.errorColor, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('تأكيد حذف اليوم', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
            'هل أنت متأكد من حذف هذا اليوم؟ سيتم حذف تقرير الإغلاق المرتبط به نهائياً ولا يمكن التراجع.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final sessionRepo = getIt<SessionRepositoryImpl>();
      final arpRepo = getIt<ArpRepository>();

      await sessionRepo.deleteSession(session);
      if (session.dailyReportId != null) {
        try {
          await arpRepo.deleteReport(session.dailyReportId!);
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
            content: const Text('تم حذف اليوم بنجاح.'),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف اليوم: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      return '${hours}س ${minutes}د';
    }
    return '${minutes}د';
  }

  // --- UI ---

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
          color: AppColors.borderColor.withOpacity(0.5),
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
                        'سجل الأيام',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_sessions.length} يوم',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
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
            Text('جاري التحميل...', style: TextStyle(color: AppColors.mutedColor, fontSize: 13)),
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
            const Text('لا توجد أيام', style: TextStyle(color: AppColors.mutedColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('ستظهر الأيام هنا عند إنشائها', style: TextStyle(color: AppColors.mutedColor.withOpacity(0.6), fontSize: 12)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // List header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              const Text(
                'الأيام',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_sessions.length}',
                  style: const TextStyle(
                    fontSize: 12,
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
                            ? AppColors.primaryColor.withOpacity(0.06)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryColor.withOpacity(0.3)
                              : AppColors.borderColor.withOpacity(0.4),
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
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
                              // Status indicator
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: session.isOpen ? AppColors.successColor : AppColors.mutedColor,
                                  shape: BoxShape.circle,
                                  boxShadow: session.isOpen
                                      ? [
                                          BoxShadow(
                                            color: AppColors.successColor.withOpacity(0.4),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: session.isOpen
                                      ? AppColors.successColor.withOpacity(0.12)
                                      : AppColors.mutedColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  session.isOpen ? 'نشط' : 'مغلق',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: session.isOpen ? AppColors.successColor : AppColors.mutedColor,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Duration badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.clock, size: 11, color: AppColors.secondaryColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDuration(session),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.secondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'يوم #${session.id.substring(0, 8)}...',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isSelected ? AppColors.primaryColor : AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'بواسطة: ${session.openedByUserId}',
                             style: const TextStyle(
                               fontSize: 12,
                               color: AppColors.textSecondary,
                             ),
                          ),
                          const SizedBox(height: 8),
                          // Time row
                          Row(
                            children: [
                              _buildTimeChip(
                                LucideIcons.logIn,
                                Colors.green,
                                '${dateFormat.format(session.openTime)} ${timeFormat.format(session.openTime)}',
                              ),
                              if (session.closeTime != null) ...[
                                const SizedBox(width: 4),
                                Icon(LucideIcons.arrowLeft, size: 12, color: AppColors.mutedColor.withOpacity(0.5)),
                                const SizedBox(width: 4),
                                _buildTimeChip(
                                  LucideIcons.logOut,
                                  Colors.orange,
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
        Icon(icon, size: 12, color: color.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withOpacity(0.8)),
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
              'اختر يوم لعرض التفاصيل',
              style: TextStyle(color: AppColors.mutedColor, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'اضغط على أي يوم من القائمة لعرض سجل العمليات والتقرير',
              style: TextStyle(color: AppColors.mutedColor.withOpacity(0.6), fontSize: 12),
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
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.list, size: 18),
                      const SizedBox(width: 8),
                      const Text('سجل العمليات'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.fileText, size: 18),
                      const SizedBox(width: 8),
                      const Text('التقرير اليومي'),
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
           gradient: LinearGradient(
             colors: [
               AppColors.primaryColor.withOpacity(0.08),
               AppColors.primaryColor.withOpacity(0.02)
             ],
             begin: Alignment.topCenter,
             end: Alignment.bottomCenter,
           ),
           border: Border(bottom: BorderSide(color: AppColors.borderColor.withOpacity(0.6))),
        ),
        child: Column(
          children: [
            Row(
               children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor.withOpacity(0.12),
                          AppColors.secondaryColor.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.monitor, color: AppColors.primaryColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                     child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                              'يوم #${session.id.substring(0, 12)}...',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                           ),
                           const SizedBox(height: 6),
                           Row(
                             children: [
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                 decoration: BoxDecoration(
                                   color: session.isOpen ? AppColors.successColor.withOpacity(0.1) : AppColors.mutedColor.withOpacity(0.08),
                                   borderRadius: BorderRadius.circular(20),
                                   border: Border.all(
                                     color: session.isOpen ? AppColors.successColor.withOpacity(0.25) : AppColors.mutedColor.withOpacity(0.15),
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
                                        session.isOpen ? 'مفتوحة' : 'مغلقة',
                                        style: TextStyle(
                                           color: session.isOpen ? AppColors.successColor : AppColors.textSecondary,
                                           fontSize: 12,
                                           fontWeight: FontWeight.w600,
                                        ),
                                     ),
                                   ],
                                 ),
                               ),
                               const SizedBox(width: 12),
                               Icon(LucideIcons.user, size: 14, color: AppColors.mutedColor),
                               const SizedBox(width: 4),
                               Text(
                                  session.openedByUserId,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                    tooltip: 'حذف اليوم',
                    color: AppColors.errorColor,
                    onPressed: () => _deleteSession(session),
                  ),
               ],
            ),
            const SizedBox(height: 16),
            // Session Stats Row
            Row(
              children: [
                _buildHeaderStat(
                  LucideIcons.logIn, 
                  'وقت الفتح', 
                  '${dateFormat.format(session.openTime)} ${timeFormat.format(session.openTime)}',
                  AppColors.successColor,
                ),
                if (session.closeTime != null) ...[
                  const SizedBox(width: 24),
                  _buildHeaderStat(
                    LucideIcons.logOut, 
                    'وقت الإغلاق', 
                    '${dateFormat.format(session.closeTime!)} ${timeFormat.format(session.closeTime!)}',
                    AppColors.warningColor,
                  ),
                  const SizedBox(width: 24),
                  _buildHeaderStat(
                    LucideIcons.clock,
                    'المدة',
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
              color: color.withOpacity(0.08),
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
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.mutedColor, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
                    decoration: InputDecoration(
                      hintText: 'بحث في العمليات...',
                      hintStyle: TextStyle(color: AppColors.mutedColor.withOpacity(0.6), fontSize: 13),
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
                     hint: Text('كل العمليات', style: TextStyle(fontSize: 13, color: AppColors.mutedColor)),
                     icon: Icon(LucideIcons.chevronDown, size: 16, color: AppColors.mutedColor),
                     items: [
                       const DropdownMenuItem(value: null, child: Text('كل العمليات', style: TextStyle(fontSize: 13))),
                       ...ActivityType.values.map((type) => DropdownMenuItem(
                           value: type,
                           child: Row(
                             children: [
                               Icon(_getIconForType(type), size: 14, color: _getColorForType(type)),
                               const SizedBox(width: 8),
                               Text(_getTypeName(type), style: const TextStyle(fontSize: 13)),
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
        
        // List
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
                            style: TextStyle(color: AppColors.mutedColor, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
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
                              // Timeline
                              SizedBox(
                                width: 40,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [color.withOpacity(0.2), color.withOpacity(0.08)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: color.withOpacity(0.2)),
                                      ),
                                      child: Icon(_getIconForType(activity.type), color: color, size: 16),
                                    ),
                                    if (!isLast)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withOpacity(0.2),
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
                              // Content
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
                                          ? color.withOpacity(0.15)
                                          : AppColors.borderColor.withOpacity(0.3),
                                    ),
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
                                                fontWeight: isSessionEvent ? FontWeight.w700 : FontWeight.w600,
                                                fontSize: 13,
                                                color: isSessionEvent ? color : AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            timeFormat.format(activity.timestamp),
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedColor.withOpacity(0.7)),
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
                                            style: TextStyle(fontSize: 12, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      if (activity.details != null && activity.details!.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                              ActivityLogger.formatDetailsArabic(activity.type, activity.details),
                                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withOpacity(0.7)),
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
                    'التقرير اليومي يتاح فقط بعد إغلاق اليوم',
                    style: TextStyle(fontSize: 15, color: AppColors.mutedColor, fontWeight: FontWeight.w600),
                 ),
                 const SizedBox(height: 6),
                 Text(
                    'قم بإغلاق اليوم لعرض التقرير',
                   style: TextStyle(fontSize: 12, color: AppColors.mutedColor.withOpacity(0.6)),
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
                    Text('فشل تحميل التقرير', style: TextStyle(color: AppColors.errorColor, fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text('${snapshot.error}', style: TextStyle(color: AppColors.mutedColor, fontSize: 12)),
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
                     const Text('لم يتم العثور على تقرير لهذا اليوم', style: TextStyle(color: AppColors.mutedColor, fontWeight: FontWeight.w600)),
                     const SizedBox(height: 6),
                     Text('قد يكون التقرير حُذف أو لم يُنشأ', style: TextStyle(fontSize: 12, color: AppColors.mutedColor.withOpacity(0.6))),
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
                   border: Border(bottom: BorderSide(color: AppColors.borderColor.withOpacity(0.3))),
                 ),
                 child: Row(
                   children: [
                     _buildReportStat('صافي المبيعات', '${report.netRevenue.toStringAsFixed(0)} ج.م', const Color(0xFF059669), LucideIcons.trendingUp),
                     _buildReportStatDivider(),
                     _buildReportStat('المعاملات', '${report.totalTransactions}', AppColors.secondaryColor, LucideIcons.receipt),
                     _buildReportStatDivider(),
                     _buildReportStat('المرتجعات', '${report.totalRefunds.toStringAsFixed(0)} ج.م', AppColors.errorColor, LucideIcons.cornerUpLeft),
                     const Spacer(),
                     // Actions
                     _buildReportAction(
                       icon: LucideIcons.printer,
                       label: 'طباعة',
                       color: AppColors.primaryColor,
                       onTap: () => _handlePrintReport(_selectedSession!),
                     ),
                     const SizedBox(width: 8),
                     _buildReportAction(
                       icon: LucideIcons.table,
                       label: 'جدول',
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
               // PDF preview
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
            const SnackBar(content: Text('لا يوجد تقرير لهذا اليوم')),
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
                          'معاينة التقرير', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
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
          SnackBar(content: Text('فشل تحميل التقرير: $e')),
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: AppColors.mutedColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
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
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
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
      case ActivityType.productUpdate: return LucideIcons.edit3;
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
      case ActivityType.invoiceDelete: return Colors.redAccent;
      case ActivityType.printReport: return Colors.blueGrey;
      case ActivityType.login: return Colors.cyan;
    }
  }

  String _getTypeName(ActivityType type) {
      switch (type) {
      case ActivityType.sale: return 'بيع';
      case ActivityType.refund: return 'استرجاع';
      case ActivityType.productAdd: return 'إضافة منتج';
      case ActivityType.productUpdate: return 'تعديل منتج';
      case ActivityType.productDelete: return 'حذف منتج';
      case ActivityType.productQuantityUpdate: return 'تعديل كمية';
      case ActivityType.userAdd: return 'إضافة مستخدم';
      case ActivityType.userUpdate: return 'تعديل مستخدم';
      case ActivityType.userDelete: return 'حذف مستخدم';
      case ActivityType.sessionOpen: return 'فتح يوم';
      case ActivityType.sessionClose: return 'إغلاق يوم';
      case ActivityType.restock: return 'شحنة جديدة';
      case ActivityType.expense: return 'مصروفات';
      case ActivityType.invoiceDelete: return 'حذف فاتورة';
      case ActivityType.printReport: return 'طباعة تقرير';
      case ActivityType.login: return 'تسجيل دخول';
    }
  }
}
