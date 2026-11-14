import 'package:bayaa_pos/shared/feedback/preview_action.dart';
import 'package:bayaa_pos/shared/widgets/asset_image_view.dart';
import 'package:flutter/material.dart';
import 'package:bayaa_pos/features/auth/presentation/models/user_view_data.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';

class AddEditUserDialog extends StatefulWidget {
  final UserViewData? userToEdit;
  final bool profileOnly;

  const AddEditUserDialog({
    super.key,
    this.userToEdit,
    this.profileOnly = false,
  });

  @override
  State<AddEditUserDialog> createState() => _AddEditUserDialogState();
}

class _AddEditUserDialogState extends State<AddEditUserDialog> {
  late final TextEditingController nameCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController usernameCtrl;
  late final TextEditingController passwordCtrl;
  late PreviewRole selectedUserType;
  String? _selectedImagePath;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    final user = widget.userToEdit;
    nameCtrl = TextEditingController(text: user?.name ?? '');
    phoneCtrl = TextEditingController(text: user?.phone ?? '');
    usernameCtrl = TextEditingController(text: user?.username ?? '');
    passwordCtrl = TextEditingController(text: user?.password ?? '');
    selectedUserType = user?.userType ?? PreviewRole.cashier;
    _selectedImagePath = user?.imagePath;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  final bool _isSubmitting = false;

  Future<void> _pickImage() async {
    showPreviewAction(context);
  }

  Future<void> _submit() async {
    final navigator = Navigator.of(context);
    final feedbackContext = navigator.context;
    navigator.pop();
    showPreviewAction(feedbackContext);
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surfaceColor,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                          ? l10n.addNewUser
                          : l10n.editUser,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.localeName == 'ar' ? 'إغلاق' : 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildImagePicker(l10n),
              const SizedBox(height: 20),

              // Form
              Column(
                children: [
                  _buildTextField(nameCtrl, l10n.nameRequired, Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(phoneCtrl, l10n.storePhone, Icons.phone,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildTextField(
                    usernameCtrl,
                    l10n.usernameRequired,
                    Icons.account_circle,
                    readOnly: widget.userToEdit != null,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(l10n),
                  if (!widget.profileOnly) ...[
                    const SizedBox(height: 16),
                    _buildUserTypeDropdown(l10n),
                  ],
                ],
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
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.primaryForeground,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              widget.userToEdit == null
                                  ? l10n.addUserButton
                                  : l10n.saveChanges,
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

  Widget _buildImagePicker(AppLocalizations l10n) {
    final isArabic = l10n.localeName == 'ar';
    final initial = nameCtrl.text.trim().isNotEmpty
        ? nameCtrl.text.trim().substring(0, 1).toUpperCase()
        : '?';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(.045),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: LayoutBuilder(builder: (context, size) {
        final image = AssetImageView(
          path: _selectedImagePath,
          width: 72,
          height: 72,
          borderRadius: 36,
          fallback: Container(
            color: AppColors.primaryColor,
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'صورة الملف الشخصي' : 'Profile image',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              isArabic
                  ? 'اختيارية ويمكن تغييرها لاحقاً'
                  : 'Optional and changeable later',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.mutedColor,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_camera_outlined, size: 17),
                  label: Text(isArabic ? 'اختيار صورة' : 'Choose image'),
                ),
                if (_selectedImagePath != null)
                  TextButton.icon(
                    onPressed: () => setState(() => _selectedImagePath = null),
                    icon: const Icon(Icons.delete_outline, size: 17),
                    label: Text(isArabic ? 'إزالة' : 'Remove'),
                  ),
              ],
            ),
          ],
        );
        if (size.maxWidth < 340 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.4) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [image, const SizedBox(height: 12), details]);
        }
        return Row(children: [
          image,
          const SizedBox(width: 14),
          Expanded(child: details)
        ]);
      }),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType, bool readOnly = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.mutedColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        readOnly: readOnly,
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

  Widget _buildPasswordField(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.mutedColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: passwordCtrl,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: l10n.passwordRequired,
          prefixIcon: Icon(Icons.lock, color: AppColors.primaryColor),
          suffixIcon: IconButton(
            tooltip: _isPasswordVisible
                ? (l10n.localeName == 'ar'
                    ? 'إخفاء كلمة المرور'
                    : 'Hide password')
                : (l10n.localeName == 'ar'
                    ? 'إظهار كلمة المرور'
                    : 'Show password'),
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: AppColors.mutedColor,
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

  Widget _buildUserTypeDropdown(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.mutedColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<PreviewRole>(
        isExpanded: true,
        value: selectedUserType,
        items: [
          DropdownMenuItem(
            value: PreviewRole.manager,
            child: Text(l10n.roleManager),
          ),
          DropdownMenuItem(
            value: PreviewRole.cashier,
            child: Text(l10n.roleCashier),
          ),
        ],
        onChanged: (v) =>
            setState(() => selectedUserType = v ?? PreviewRole.cashier),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: l10n.userType,
          prefixIcon:
              Icon(Icons.admin_panel_settings, color: AppColors.primaryColor),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
