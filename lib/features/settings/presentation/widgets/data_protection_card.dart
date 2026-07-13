import 'package:flutter/material.dart';
import 'package:bayaa_pos/core/data/services/persistence_initializer.dart';
import 'package:bayaa_pos/core/functions/messege.dart';
import '../../../../l10n/app_localizations.dart';

class DataProtectionCard extends StatefulWidget {
  final bool isMobile;

  const DataProtectionCard({super.key, required this.isMobile});

  @override
  State<DataProtectionCard> createState() => _DataProtectionCardState();
}

class _DataProtectionCardState extends State<DataProtectionCard> {
  bool _isEnabled = false;
  String? _dataPath;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() {
    setState(() {
      _isEnabled = PersistenceInitializer.isEnabled;
      if (_isEnabled) {
        _dataPath = PersistenceInitializer.persistenceManager?.pathResolver.dataRootPath;
      }
    });
  }

  Future<void> _enablePersistence() async {
    final success = await PersistenceInitializer.promptForDataPath(context);
    
    if (success) {
      setState(() {
        _isEnabled = true;
        _dataPath = PersistenceInitializer.persistenceManager?.pathResolver.dataRootPath;
      });
      
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        MotionSnackBarSuccess(context, l10n.protectionActivated);
        
        // Restart app prompt
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.restartApp),
            content: Text(l10n.protectionActivatedMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        MotionSnackBarError(context, AppLocalizations.of(context).operationCancelled);
      }
    }
  }

  Future<void> _changeDataLocation() async {
    final success = await PersistenceInitializer.changeDataLocation(context);
    
    if (success) {
      _checkStatus();
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        MotionSnackBarSuccess(context, l10n.dataMigrationSuccess);
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 10),
                Text(l10n.migrationSuccess),
              ],
            ),
            content: Text(
              l10n.migrationDetails(_dataPath!),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        MotionSnackBarError(context, AppLocalizations.of(context).migrationFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(widget.isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isEnabled ? Colors.green.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isEnabled ? Icons.shield : Icons.shield_outlined,
                    color: _isEnabled ? Colors.green : Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dataProtection,
                        style: TextStyle(
                          fontSize: widget.isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isEnabled ? l10n.protectionEnabled : l10n.protectionDisabled,
                        style: TextStyle(
                          fontSize: 14,
                          color: _isEnabled ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isEnabled)
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
              ],
            ),
            const SizedBox(height: 16),
            if (_isEnabled) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, 
                          color: Colors.green.shade700, 
                          size: 20
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.protectionSystemActive,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.yourDataProtected,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildFeature(l10n.accidentalDeletion, Icons.delete_outline),
                    _buildFeature(l10n.systemCrashes, Icons.error_outline),
                    _buildFeature(l10n.powerOutage, Icons.power_off),
                    _buildFeature(l10n.windowsReinstall, Icons.refresh),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.folder_outlined, 
                          size: 16, 
                          color: Colors.green.shade700
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${l10n.dataLocation}\n$_dataPath',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _changeDataLocation,
                        icon: const Icon(Icons.drive_file_move_outline, size: 18),
                        label: Text(l10n.changeLocation),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange.shade800,
                          side: BorderSide(color: Colors.orange.shade300, width: 1.5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, 
                          color: Colors.orange.shade700, 
                          size: 20
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.protectionInactive,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.dataAtRisk,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildWarning(l10n.appDeletion),
                    _buildWarning(l10n.windowsReinstall),
                    _buildWarning(l10n.virusScan),
                    _buildWarning(l10n.systemCrash),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _enablePersistence,
                        icon: const Icon(Icons.shield),
                        label: Text(l10n.enableProtection),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarning(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.close, size: 14, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
