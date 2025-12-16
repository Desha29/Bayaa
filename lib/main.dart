import 'package:crazy_phone_pos/features/activation/activation_screen.dart'
    show ActivationScreen;
import 'package:crazy_phone_pos/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'dart:io';

import 'core/constants/bloc_observer.dart';
import 'core/di/dependency_injection.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/hive_helper.dart';
import 'core/components/message_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = MyBlocObserver();

  await HiveHelper.initialize();

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();

    final primaryDisplay = await screenRetriever.getPrimaryDisplay();
    final screenWidth = primaryDisplay.size.width;
    final screenHeight = primaryDisplay.size.height;

    WindowOptions windowOptions = WindowOptions(
      size: Size(screenWidth, screenHeight - 60),
      minimumSize: Size(screenWidth, screenHeight - 60),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Amr Store',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.maximize();
    });
  }

  setup();
  const String requiredFilePath =
      r"C:\Program Files (x86)\App\Bin\Plugins\drv_7lhxk3.sys";

  bool fileExists = await File(requiredFilePath).exists();
  print('File exists: $fileExists');
  if (fileExists) {
    runApp(const MyApp());
  } else {
    runApp(const ActivationScreen());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MessageOverlay(
      child: MaterialApp(
        title: 'Amr Store',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          // Initialize global message context
          GlobalMessage.initialize(context);

          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
      ),
    );
  }
}
