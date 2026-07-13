import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:path/path.dart' as path;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/data/services/backup_manager.dart';
import '../../../../core/data/services/checkpoint_service.dart';
import '../../../../core/functions/messege.dart';
import '../../../../core/data/services/persistence_initializer.dart';
import '../../../../core/data/services/debug_seeder.dart';
import '../../../../l10n/app_localizations.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Directory> _backups = [];
  List<Map<String, dynamic>> _checkpoints = [];
  bool _isPersistenceReady = false;

  BackupManager? get _backupManager {
    if (getIt.isRegistered<BackupManager>()) {
      return getIt<BackupManager>();
    }
    return null;
  }

  final _checkpointService = CheckpointService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _isPersistenceReady = getIt.isRegistered<BackupManager>();
    if (_isPersistenceReady) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final manager = _backupManager;
    if (manager == null) {
      setState(() => _isPersistenceReady = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final backups = await manager.getAllBackups();
      final checkpoints = await _checkpointService.getAllCheckpoints();
      setState(() {
        _backups = backups;
        _checkpoints = checkpoints;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) MotionSnackBarError(context, AppLocalizations.of(context).loadDataError(e.toString()));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _createBackup() async {
    final manager = _backupManager;
    if (manager == null) return;
    setState(() => _isLoading = true);
    try {
      final success = await manager.createBackup();
      if (success) {
        if (mounted) MotionSnackBarSuccess(context, AppLocalizations.of(context).msgDataSaved);
        await _loadData();
      } else {
        if (mounted) MotionSnackBarError(context, AppLocalizations.of(context).backupFailed);
      }
    } catch (e) {
      if (mounted) MotionSnackBarError(context, AppLocalizations.of(context).error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreBackup(String backupPath) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await _showConfirmDialog(
      l10n.confirmRestore,
      l10n.confirmRestoreMessage,
      icon: LucideIcons.triangleAlert,
      iconColor: AppColors.warningColor,
    );
    if (!confirm) return;

    setState(() => _isLoading = true);
    try {
      final manager = _backupManager;
      if (manager == null) return;
      final success = await manager.restoreFromBackup(backupPath);
      if (success) {
        if (mounted) {
          MotionSnackBarSuccess(context, l10n.restoreSuccess);
          await Future.delayed(const Duration(seconds: 2));
          exit(0);
        }
      } else {
        if (mounted) MotionSnackBarError(context, l10n.restoreFailed);
      }
    } catch (e) {
      if (mounted) MotionSnackBarError(context, l10n.restoreError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreCheckpoint(String checkpointPath) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await _showConfirmDialog(
      l10n.confirmAutoRestore,
      l10n.confirmAutoRestoreMessage,
      icon: LucideIcons.triangleAlert,
      iconColor: AppColors.warningColor,
    );
    if (!confirm) return;

    setState(() => _isLoading = true);
    try {
      final success = await _checkpointService.restoreFromCheckpoint(checkpointPath);
      if (success) {
        if (mounted) {
          MotionSnackBarSuccess(context, l10n.autoRestoreSuccess);
          await Future.delayed(const Duration(seconds: 2));
          exit(0);
        }
      } else {
        if (mounted) MotionSnackBarError(context, l10n.autoRestoreFailed);
      }
    } catch (e) {
      if (mounted) MotionSnackBarError(context, l10n.restoreError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBackup(String backupPath) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await _showConfirmDialog(
      l10n.deleteBackup,
      l10n.deleteBackupMessage,
      icon: LucideIcons.trash2,
      iconColor: AppColors.errorColor,
    );
    if (!confirm) return;

    setState(() => _isLoading = true);
    try {
      final dir = Directory(backupPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        if (mounted) MotionSnackBarSuccess(context, l10n.deleteBackupSuccess);
        await _loadData();
      }
    } catch (e) {
      if (mounted) MotionSnackBarError(context, l10n.deleteBackupFailed(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _showConfirmDialog(
    String title,
    String content, {
    IconData icon = LucideIcons.circleAlert,
    Color iconColor = AppColors.primaryColor,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(AppLocalizations.of(context).cancelBtn, style: TextStyle(color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor == AppColors.errorColor
                  ? AppColors.errorColor
                  : AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context).confirmBtn, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('yyyy/MM/dd');
    final timeFormat = DateFormat('hh:mm a');

    return Directionality(
      textDirection: l10n.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: !_isPersistenceReady
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.shieldOff, size: 64, color: Colors.orange.shade300),
                    const SizedBox(height: 16),
                    Text(
                      l10n.protectionInactive,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.enableProtection,
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.arrowRight),
                      label: Text(l10n.cancel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
          children: [
            // Custom header
            _buildHeader(),
            // Tabs
            _buildTabBar(),
            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.primaryColor),
                          const SizedBox(height: 16),
                          Text(
                            l10n.loadingData,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBackupsTab(dateFormat, timeFormat),
                        _buildCheckpointsTab(dateFormat, timeFormat),
                        _buildAppModeTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 16,
        right: 16,
        left: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          Material(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(LucideIcons.arrowRight, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title & subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dataManagementTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.backupAndRestore,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Stats badges
          _buildStatBadge(
            icon: LucideIcons.database,
            count: _backups.length,
            label: l10n.backupLabel,
          ),
          const SizedBox(width: 8),
          _buildStatBadge(
            icon: LucideIcons.clock,
            count: _checkpoints.length,
            label: l10n.restorePointLabel,
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required int count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 2),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
      final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.database, size: 16),
                const SizedBox(width: 8),
                Text(l10n.backupSection),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.clock, size: 16),
                const SizedBox(width: 8),
                Text(l10n.autoSaveSection),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.settings, size: 16),
                const SizedBox(width: 8),
                Text(l10n.systemStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupsTab(DateFormat dateFormat, DateFormat timeFormat) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // Create backup button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _isLoading ? null : _createBackup,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.save, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.createBackup,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Backup list
        Expanded(
          child: _backups.isEmpty
              ? _buildEmptyState(
                  icon: LucideIcons.database,
                  title: l10n.noBackups,
                  subtitle: l10n.createBackupHint,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: _backups.length,
                  itemBuilder: (context, index) {
                    final backup = _backups[index];
                    final stat = backup.statSync();
                    final name = path.basename(backup.path);
                    final date = stat.modified;
                    final sizeBytes = _getDirSize(backup);
                    final isLatest = index == 0;

                    return _buildBackupCard(
                      name: name,
                      date: date,
                      sizeBytes: sizeBytes,
                      isLatest: isLatest,
                      dateFormat: dateFormat,
                      timeFormat: timeFormat,
                      onRestore: () => _restoreBackup(backup.path),
                      onDelete: () => _deleteBackup(backup.path),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCheckpointsTab(DateFormat dateFormat, DateFormat timeFormat) {
    final l10n = AppLocalizations.of(context);
    if (_checkpoints.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.clock,
        title: l10n.noAutoSavePoints,
        subtitle: l10n.autoSaveHint,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _checkpoints.length,
      itemBuilder: (context, index) {
        final chk = _checkpoints[index];
        final reason = chk['reason'] as String? ?? l10n.autoSavePoint;
        final user = chk['user'] as String? ?? l10n.systemLabel;
        final timestampStr = chk['timestamp'] as String?;
        final date = timestampStr != null ? DateTime.parse(timestampStr) : DateTime.now();
        final isLatest = index == 0;

        return _buildCheckpointCard(
          reason: reason,
          user: user,
          date: date,
          isLatest: isLatest,
          dateFormat: dateFormat,
          timeFormat: timeFormat,
          onRestore: () => _restoreCheckpoint(chk['path']),
        );
      },
    );
  }

  Widget _buildBackupCard({
    required String name,
    required DateTime date,
    required int sizeBytes,
    required bool isLatest,
    required DateFormat dateFormat,
    required DateFormat timeFormat,
    required VoidCallback onRestore,
    required VoidCallback onDelete,
  }) {
    final sizeMB = (sizeBytes / 1024 / 1024).toStringAsFixed(2);
  final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLatest ? AppColors.primaryColor.withOpacity(0.3) : AppColors.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLatest
                      ? [AppColors.primaryColor.withOpacity(0.15), AppColors.primaryColor.withOpacity(0.05)]
                      : [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.04)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                LucideIcons.database,
                color: isLatest ? AppColors.primaryColor : Colors.blue,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isLatest)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.newestFirst,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.successColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: LucideIcons.calendar,
                        text: dateFormat.format(date),
                      ),
                      const SizedBox(width: 10),
                      _buildInfoChip(
                        icon: LucideIcons.clock,
                        text: timeFormat.format(date),
                      ),
                      const SizedBox(width: 10),
                      _buildInfoChip(
                        icon: LucideIcons.hardDrive,
                        text: '$sizeMB MB',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(
                  icon: LucideIcons.rotateCcw,
                  color: AppColors.primaryColor,
                  tooltip: l10n.restoreBtn,
                  onTap: onRestore,
                ),
                const SizedBox(width: 6),
                _buildActionButton(
                  icon: LucideIcons.trash2,
                  color: AppColors.errorColor,
                  tooltip: l10n.deleteBtn2,
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckpointCard({
    required String reason,
    required String user,
    required DateTime date,
    required bool isLatest,
    required DateFormat dateFormat,
    required DateFormat timeFormat,
    required VoidCallback onRestore,
  }) {
      final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLatest ? Colors.green.withOpacity(0.3) : AppColors.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLatest
                      ? [Colors.green.withOpacity(0.15), Colors.green.withOpacity(0.05)]
                      : [Colors.teal.withOpacity(0.1), Colors.teal.withOpacity(0.04)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                LucideIcons.clock,
                color: isLatest ? Colors.green : Colors.teal,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reason,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isLatest)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.newestFirst,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.successColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: LucideIcons.user,
                        text: user,
                      ),
                      const SizedBox(width: 10),
                      _buildInfoChip(
                        icon: LucideIcons.calendar,
                        text: dateFormat.format(date),
                      ),
                      const SizedBox(width: 10),
                      _buildInfoChip(
                        icon: LucideIcons.clock,
                        text: timeFormat.format(date),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Restore action
            _buildActionButton(
              icon: LucideIcons.rotateCcw,
              color: Colors.green,
              tooltip: l10n.restoreBtn,
              onTap: onRestore,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: AppColors.primaryColor.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  int _getDirSize(Directory dir) {
    int size = 0;
    try {
      if (dir.existsSync()) {
        dir.listSync(recursive: true, followLinks: false).forEach((FileSystemEntity entity) {
          if (entity is File) {
            size += entity.lengthSync();
          }
        });
      }
    } catch (_) {}
    return size;
  }

  Widget _buildAppModeTab() {
    final currentMode = PersistenceInitializer.persistenceManager?.config.appMode ?? 'release';
    final isDebug = currentMode == 'debug';
  final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mode switch card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.settings,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.currentMode,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isDebug
                                ? l10n.debugModeDesc
                                : l10n.releaseModeDesc,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDebug ? Colors.orange.shade700 : AppColors.successColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  l10n.chooseMode,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildModeOptionCard(
                        title: l10n.releaseMode,
                        description: l10n.releaseModeDesc2,
                        icon: LucideIcons.shieldCheck,
                        isActive: !isDebug,
                        activeColor: AppColors.successColor,
                        onTap: () => _changeMode('release'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildModeOptionCard(
                        title: l10n.debugMode,
                        description: l10n.debugModeDesc2,
                        icon: LucideIcons.code,
                        isActive: isDebug,
                        activeColor: Colors.orange,
                        onTap: () => _changeMode('debug'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Debug actions card (only visible in debug mode)
          if (isDebug)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Icon(
                          LucideIcons.triangleAlert,
                          color: Colors.red.shade700,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.demoDataDangerZone,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              l10n.dbToolsDesc,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    l10n.reseedWarning,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _resetAndSeedData,
                    icon: const Icon(LucideIcons.rotateCcw),
                    label: Text(
                      l10n.reseedDatabase,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isActive ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? activeColor : AppColors.borderColor,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? activeColor : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isActive ? activeColor : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isActive)
                  Icon(
                    LucideIcons.checkCircle2,
                    color: activeColor,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: isActive ? activeColor.withOpacity(0.8) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeMode(String mode) async {
    final manager = PersistenceInitializer.persistenceManager;
    if (manager == null) return;
    setState(() => _isLoading = true);
    try {
      manager.config.appMode = mode;
      await manager.config.save();
      
      if (mode == 'debug') {
        await DebugSeeder.seedIfNeeded();
      }
      
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        MotionSnackBarSuccess(context, l10n.modeChanged(mode == 'debug' ? l10n.modeDebug : l10n.modeRelease));
      }
    } catch (e) {
      if (mounted) MotionSnackBarError(context, AppLocalizations.of(context).saveSettingsFailed(e.toString()));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetAndSeedData() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await _showConfirmDialog(
      l10n.confirmReseed,
      l10n.reseedConfirmMessage,
      icon: LucideIcons.triangleAlert,
      iconColor: AppColors.errorColor,
    );
    if (!confirm) return;

    setState(() => _isLoading = true);
    try {
      await DebugSeeder.clearAndReSeed();
      if (mounted) {
        MotionSnackBarSuccess(context, l10n.reseedSuccess);
      }
    } catch (e) {
      if (mounted) MotionSnackBarError(context, l10n.reseedError(e.toString()));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
