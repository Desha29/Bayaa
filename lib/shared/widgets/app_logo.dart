import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bayaa_pos/features/settings/presentation/controllers/settings_cubit.dart';
import 'package:bayaa_pos/features/settings/presentation/controllers/settings_state.dart';
import 'package:bayaa_pos/app/bootstrap/service_locator.dart';

class AppLogo extends StatelessWidget {
  final double width;
  final double height;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: getIt<SettingsCubit>(),
      builder: (context, state) {
        final storeInfo = getIt<SettingsCubit>().currentStoreInfo;

        if (storeInfo != null &&
            storeInfo.logoPath != null &&
            storeInfo.logoPath!.startsWith('assets/')) {
          return Image.asset(
            storeInfo.logoPath!,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => _buildAssetLogo(context),
          );
        }
        return _buildAssetLogo(context);
      },
    );
  }

  Widget _buildAssetLogo(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final logoPath = locale.languageCode == 'en'
        ? 'assets/images/logo_en.png'
        : 'assets/images/logo.png';
    return Image.asset(
      logoPath,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
