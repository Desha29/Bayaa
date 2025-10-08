// add_edit_user_dialog.dart
import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/messege.dart';

class AddEditUserDialog extends StatefulWidget {
  final User? userToEdit;

  const AddEditUserDialog({
    super.key,
    this.userToEdit,
  });

  @override
  State<AddEditUserDialog> createState() => _AddEditUserDialogState();
}

class _AddEditUserDialogState extends State<AddEditUserDialog> {
  late final TextEditingController nameCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController usernameCtrl;
  late final TextEditingController passwordCtrl;
  late UserType selectedUserType;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    final user = widget.userToEdit;
    nameCtrl = TextEditingController(text: user?.name ?? '');
    phoneCtrl = TextEditingController(text: user?.phone ?? '');
    usernameCtrl = TextEditingController(text: user?.username ?? '');
    passwordCtrl = TextEditingController(text: user?.password ?? '');
    selectedUserType = user?.userType ?? UserType.cashier;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (nameCtrl.text.trim().isEmpty || 
        usernameCtrl.text.trim().isEmpty ||
        passwordCtrl.text.trim().isEmpty) {
    MotionSnackBarError(context, 'يرجى ملء الحقول المطلوبة');
      return;
    }

    final User user = User(
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      username: usernameCtrl.text.trim(),
      password: passwordCtrl.text.trim(),
      userType: selectedUserType,
    );

    if (widget.userToEdit == null) {
      getIt<UserCubit>().saveUser(user);
      MotionSnackBarSuccess(context, 'تم إضافة المستخدم بنجاح');
      getIt<UserCubit>().getAllUsers(); 
    } else {
      getIt<UserCubit>().updateUser(user);
      MotionSnackBarSuccess(context, 'تم تعديل المستخدم بنجاح');
    }

    
     

    Navigator.of(context).pop(user);
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
                      widget.userToEdit == null
                          ? Icons.person_add_outlined
                          : Icons.edit_outlined,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.userToEdit == null
                          ? 'إضافة مستخدم جديد'
                          : 'تعديل المستخدم',
                      style: const TextStyle(
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
                  child: Column(
                    children: [
                      _buildTextField(nameCtrl, 'الاسم *', Icons.person),
                      const SizedBox(height: 16),
                      _buildTextField(
                        phoneCtrl, 
                        'رقم الهاتف', 
                        Icons.phone,
                        TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        usernameCtrl, 
                        'اسم المستخدم *', 
                        Icons.account_circle,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 16),
                      _buildUserTypeDropdown(),
                    ],
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
                      child: Text(
                        widget.userToEdit == null
                            ? 'إضافة المستخدم'
                            : 'حفظ التعديلات',
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

  Widget _buildPasswordField() {
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
        controller: passwordCtrl,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: 'كلمة المرور *',
          prefixIcon: Icon(Icons.lock, color: AppColors.primaryColor),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeDropdown() {
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
      child: DropdownButtonFormField<UserType>(
        value: selectedUserType,
        items: [
          DropdownMenuItem(
            value: UserType.manager,
            child: const Text('مدير النظام'),
          ),
          DropdownMenuItem(
            value: UserType.cashier,
            child: const Text('كاشير'),
          ),
        ],
        onChanged: (v) => setState(() => selectedUserType = v ?? UserType.cashier),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: 'نوع المستخدم',
          prefixIcon: Icon(Icons.admin_panel_settings, color: AppColors.primaryColor),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
