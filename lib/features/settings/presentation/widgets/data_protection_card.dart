import 'package:flutter/material.dart';
import 'package:crazy_phone_pos/core/data/services/persistence_initializer.dart';
import 'package:crazy_phone_pos/core/functions/messege.dart';

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
        MotionSnackBarSuccess(context, 'تم تفعيل نظام الحماية بنجاح');
        
        // Restart app prompt
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('إعادة تشغيل التطبيق'),
            content: const Text(
              'تم تفعيل نظام الحماية بنجاح!\\n\\n'
              'للاستفادة الكاملة من النظام، يُفضل إعادة تشغيل التطبيق.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        MotionSnackBarError(context, 'تم إلغاء العملية');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        'نظام الحماية من فقدان البيانات',
                        style: TextStyle(
                          fontSize: widget.isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isEnabled ? 'مُفعّل' : 'غير مُفعّل',
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
                        const Text(
                          'النظام مُفعّل',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'بياناتك محمية من:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildFeature('الحذف الغير مقصود', Icons.delete_outline),
                    _buildFeature('الأعطال والانهيارات', Icons.error_outline),
                    _buildFeature('انقطاع الكهرباء', Icons.power_off),
                    _buildFeature('إعادة تثبيت Windows', Icons.refresh),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.folder_outlined, 
                          size: 16, 
                          color: Colors.green.shade700
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'موقع البيانات:\\n$_dataPath',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
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
                        const Text(
                          'النظام غير مُفعّل',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'حالياً، بياناتك معرضة للفقدان في حالة:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildWarning('حذف البرنامج'),
                    _buildWarning('إعادة تثبيت Windows'),
                    _buildWarning('فحص الفيروسات'),
                    _buildWarning('انهيار النظام'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _enablePersistence,
                        icon: const Icon(Icons.shield),
                        label: const Text('تفعيل نظام الحماية الآن'),
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
