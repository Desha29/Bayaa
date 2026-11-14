import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bayaa_pos/app/bootstrap/service_locator.dart';
import 'package:bayaa_pos/app/shell/erp_shell.dart';
import 'package:bayaa_pos/features/auth/presentation/controllers/user_cubit.dart';
import 'package:bayaa_pos/features/auth/presentation/controllers/user_state.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/shared/localization/locale_provider.dart';
import 'package:bayaa_pos/shared/localization/translation_helper.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/app_logo.dart';
import 'package:bayaa_pos/shared/feedback/app_messages.dart';

/// Presentation-only sign-in. The sample session does not check credentials.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    getIt<UserCubit>().getAllUsers();
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool get _arabic => Localizations.localeOf(context).languageCode == 'ar';
  String _copy(String ar, String en) => _arabic ? ar : en;
  void _enter() => getIt<UserCubit>().login('', '');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider.value(
      value: getIt<UserCubit>(),
      child: BlocListener<UserCubit, UserState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const ErpShell()));
          } else if (state is UserFailure) {
            showErrorMessage(
                context, TranslationHelper.translate(context, state.error));
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: LayoutBuilder(builder: (context, size) {
              final wide = size.maxWidth >= 1000 && size.maxHeight >= 640;
              final padding = size.maxWidth < 500 ? 16.0 : 32.0;
              final form = _form(l10n);
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: wide ? 1120 : 480),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.borderColor),
                        boxShadow: [
                          BoxShadow(
                              color:
                                  AppColors.primaryColor.withValues(alpha: .04),
                              blurRadius: 40,
                              offset: const Offset(0, 16))
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: wide
                            ? Stack(children: [
                                Positioned.fill(
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                            child: ColoredBox(
                                                color: AppColors.sidebarColor)),
                                        const Expanded(child: SizedBox()),
                                      ]),
                                ),
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: _brandPanel()),
                                      Expanded(
                                          child: Padding(
                                              padding: const EdgeInsets.all(40),
                                              child: form)),
                                    ]),
                              ])
                            : Padding(
                                padding: EdgeInsets.all(
                                    size.maxWidth < 380 ? 20 : 28),
                                child: form),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _form(AppLocalizations l10n) => AutofillGroup(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const AppLogo(width: 58, height: 58),
                const Spacer(),
                TextButton.icon(
                  onPressed: getIt<LocaleProvider>().toggleLocale,
                  icon: const Icon(Icons.language_outlined, size: 18),
                  label: Text(
                      _arabic ? l10n.switchToEnglish : l10n.switchToArabic),
                ),
              ]),
              const SizedBox(height: 28),
              Text(
                  _copy('مساحة عملك، في مكان واحد',
                      'Your workspace, all together'),
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryColor,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(l10n.loginWelcome,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.35)),
              const SizedBox(height: 10),
              Text(
                  _copy('ادخل إلى مساحة البيع وإدارة المتجر.',
                      'Enter your retail and store workspace.'),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.mutedColor)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _username,
                autofillHints: const [AutofillHints.username],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                decoration: InputDecoration(
                    labelText: l10n.username,
                    hintText: l10n.usernameHint,
                    prefixIcon: const Icon(Icons.person_outline_rounded)),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _password,
                focusNode: _passwordFocus,
                obscureText: !_showPassword,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _enter(),
                decoration: InputDecoration(
                  labelText: l10n.password,
                  hintText: l10n.passwordHint,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _showPassword
                        ? _copy('إخفاء كلمة المرور', 'Hide password')
                        : _copy('إظهار كلمة المرور', 'Show password'),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                    icon: Icon(_showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              BlocBuilder<UserCubit, UserState>(
                  builder: (context, state) => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accentColor,
                              foregroundColor: AppColors.accentForeground,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: state is UserLoading ? null : _enter,
                          icon: state is UserLoading
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.login_rounded, size: 19),
                          label: Text(l10n.loginButton,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      )),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 17, color: AppColors.secondaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(
                              _copy(
                                  'نسخة استعراض الواجهة — يمكنك الدخول دون بيانات حساب.',
                                  'Interface preview — enter without account credentials.'),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  height: 1.6,
                                  color: AppColors.textSecondary))),
                    ]),
              ),
              const SizedBox(height: 22),
              Text(_copy('حسابات العرض', 'Demo accounts'),
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              BlocBuilder<UserCubit, UserState>(
                  builder: (context, state) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: getIt<UserCubit>()
                          .users
                          .map((user) => ActionChip(
                                avatar: Icon(
                                    user.username == 'demo'
                                        ? Icons.admin_panel_settings_outlined
                                        : Icons.person_outline_rounded,
                                    size: 16,
                                    color: AppColors.secondaryColor),
                                label: Text(user.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11)),
                                tooltip: user.username,
                                onPressed: () {
                                  _username.text = user.username;
                                  _password.clear();
                                  _passwordFocus.requestFocus();
                                },
                                backgroundColor: AppColors.surfaceColor,
                                side: BorderSide(color: AppColors.borderColor),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ))
                          .toList())),
            ]),
      );

  Widget _brandPanel() => Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(14)),
                    child: const AppLogo(width: 48, height: 48)),
                const SizedBox(width: 14),
                Expanded(
                    child: Text(_copy('بياع', 'Bayaa'),
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.sidebarForeground))),
              ]),
              const SizedBox(height: 64),
              Text(
                  _copy('كل تفاصيل متجرك.\nمساحة واحدة للعمل.',
                      'Every part of your store.\nOne place to work.'),
                  style: TextStyle(
                      fontSize: 32,
                      height: 1.45,
                      fontWeight: FontWeight.w800,
                      color: AppColors.sidebarForeground)),
              const SizedBox(height: 18),
              Text(
                  _copy(
                      'من أول عملية بيع إلى آخر تقرير، واجهة واضحة تبقي يومك منظماً.',
                      'From the first sale to the final report, a clear workspace keeps your day organized.'),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.9,
                      color:
                          AppColors.sidebarForeground.withValues(alpha: .7))),
              const SizedBox(height: 32),
              _brandFeature(Icons.point_of_sale_outlined,
                  _copy('نقطة البيع والفواتير', 'Sales & invoicing')),
              const SizedBox(height: 16),
              _brandFeature(Icons.inventory_2_outlined,
                  _copy('المنتجات والمخزون', 'Products & inventory')),
              const SizedBox(height: 16),
              _brandFeature(
                  Icons.bar_chart_rounded,
                  _copy(
                      'التقارير وأداء المتجر', 'Reports & store performance')),
              const SizedBox(height: 48),
              Divider(
                  color: AppColors.sidebarForeground.withValues(alpha: .15)),
              const SizedBox(height: 14),
              Text(
                  _copy('بياع · نظام إدارة متاجر التجزئة',
                      'Bayaa · Retail workspace'),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color:
                          AppColors.sidebarForeground.withValues(alpha: .6))),
            ]),
      );

  Widget _brandFeature(IconData icon, String label) => Row(children: [
        Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: AppColors.accentColor.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 19, color: AppColors.accentColor)),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.sidebarForeground))),
      ]);
}
