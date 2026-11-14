import 'package:bayaa_pos/shared/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bayaa_pos/shared/widgets/message_overlay.dart';
import 'package:bayaa_pos/app/bootstrap/service_locator.dart';
import 'package:bayaa_pos/shared/localization/locale_provider.dart';
import 'package:bayaa_pos/shared/theme/app_theme.dart';
import 'package:bayaa_pos/features/auth/presentation/controllers/user_cubit.dart';
import 'package:bayaa_pos/features/auth/presentation/controllers/user_state.dart';
import 'package:bayaa_pos/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class BayaaApp extends StatelessWidget {
  const BayaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final locale = getIt<LocaleProvider>();
    return ListenableBuilder(
      listenable: Listenable.merge([locale, ThemeController.instance]),
      builder: (context, _) => BlocProvider<UserCubit>.value(
        value: getIt<UserCubit>(),
        child: MessageOverlay(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            title: locale.isArabic ? 'بياع' : 'Bayaa POS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const SignInScreen(),
            locale: locale.locale,
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              GlobalMessage.initialize(context);
              return BlocListener<UserCubit, UserState>(
                listener: (context, state) {
                  if (state is UserInitial) {
                    navigatorKey.currentState?.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                      (_) => false,
                    );
                  }
                },
                child: Directionality(
                  textDirection:
                      locale.isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: child!,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
