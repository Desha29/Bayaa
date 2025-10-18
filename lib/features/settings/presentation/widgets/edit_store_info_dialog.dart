// edit_store_info_dialog.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/messege.dart';

class EditStoreInfoDialog extends StatefulWidget {
  final Map<String, String> storeInfo;

  const EditStoreInfoDialog({
    super.key,
    required this.storeInfo,
  });

  @override
  State<EditStoreInfoDialog> createState() => _EditStoreInfoDialogState();
}

class _EditStoreInfoDialogState extends State<EditStoreInfoDialog> {
  late final TextEditingController nameCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController vatCtrl;
  late final TextEditingController addressCtrl;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.storeInfo['name'] ?? '');
    phoneCtrl = TextEditingController(text: widget.storeInfo['phone'] ?? '');
    emailCtrl = TextEditingController(text: widget.storeInfo['email'] ?? '');
    vatCtrl = TextEditingController(text: widget.storeInfo['vat'] ?? '');
    addressCtrl =
        TextEditingController(text: widget.storeInfo['address'] ?? '');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    vatCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (nameCtrl.text.trim().isEmpty) {
      MotionSnackBarError(context, 'يرجى إدخال اسم المتجر');
      return;
    }

    final Map<String, String> updatedInfo = {
      'name': nameCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'vat': vatCtrl.text.trim(),
      'address': addressCtrl.text.trim(),
    };

    MotionSnackBarSuccess(context, 'تم حفظ المعلومات بنجاح');

    Navigator.of(context).pop(updatedInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, AppColors.surfaceColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.store_outlined,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'تعديل معلومات المتجر',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Form
              Flexible(
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 500;
                      return Column(
                        children: [
                          if (isWide) ...[
                            _buildTwoColumnRow([
                              _buildTextField(
                                nameCtrl,
                                'اسم المتجر *',
                                Icons.store,
                              ),
                              _buildTextField(
                                phoneCtrl,
                                'رقم الهاتف',
                                Icons.phone,
                                TextInputType.phone,
                              ),
                            ]),
                            const SizedBox(height: 16),
                            _buildTwoColumnRow([
                              _buildTextField(
                                emailCtrl,
                                'البريد الإلكتروني',
                                Icons.email,
                                TextInputType.emailAddress,
                              ),
                              _buildTextField(
                                vatCtrl,
                                'الرقم الضريبي',
                                Icons.receipt_long,
                              ),
                            ]),
                          ] else ...[
                            _buildTextField(
                              nameCtrl,
                              'اسم المتجر *',
                              Icons.store,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              phoneCtrl,
                              'رقم الهاتف',
                              Icons.phone,
                              TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              emailCtrl,
                              'البريد الإلكتروني',
                              Icons.email,
                              TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              vatCtrl,
                              'الرقم الضريبي',
                              Icons.receipt_long,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              addressCtrl,
                              'العنوان',
                              Icons.location_on,
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.primaryForeground,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('حفظ التعديلات'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTwoColumnRow(List<Widget> children) {
    return Row(
      children: [
        Expanded(child: children[0]),
        const SizedBox(width: 16),
        Expanded(child: children[1]),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType? keyboardType,
  ]) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
