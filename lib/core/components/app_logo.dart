import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/settings/presentation/cubit/settings_states.dart';
import '../di/dependency_injection.dart';

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
    return BlocBuilder<SettingsCubit, SettingsStates>(
      bloc: getIt<SettingsCubit>(), 
      builder: (context, state) {
        final storeInfo = getIt<SettingsCubit>().currentStoreInfo;

        if (storeInfo != null &&
            storeInfo.logoPath != null &&
            storeInfo.logoPath!.isNotEmpty) {
          final file = File(storeInfo.logoPath!);
          if (file.existsSync()) {
            return Image.file(
              file,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, __, ___) => _buildAssetLogo(),
            );
          }
        }
        return _buildAssetLogo();
      },
    );
  }

  Widget _buildAssetLogo() {
    return Image.asset(
      'assets/images/logo.png',
      width: width,
      height: height,
      fit: fit,
    );
  }
}
