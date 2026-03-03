import 'package:crazy_phone_pos/features/activation/activation_screen.dart'
    show ActivationScreen;
import 'package:crazy_phone_pos/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'dart:io';
import 'dart:async';

import 'core/constants/bloc_observer.dart';
import 'core/di/dependency_injection.dart';
import 'core/theme/app_theme.dart';
import 'core/components/message_overlay.dart';
import 'core/logging/file_logger.dart';
import 'core/logging/crash_logger.dart';
import 'features/auth/presentation/cubit/user_cubit.dart';
import 'features/auth/presentation/cubit/user_states.dart';
import 'secrets.dart';
import 'core/data/services/persistence_initializer.dart';
import 'features/sessions/data/repositories/session_repository_impl.dart';
import 'core/services/activity_logger.dart';
import 'core/data/services/recovery_service.dart';
import 'core/data/services/checkpoint_service.dart';
import 'core/data/services/backup_manager.dart';

Future<void> _initializePersistenceSystem() async {
  try {
    final initialized = await PersistenceInitializer.initialize();

    if (initialized) {
      print(
          '📁 Data root: ${PersistenceInitializer.persistenceManager!.pathResolver.dataRootPath}');

      FileLogger.info('Persistence system initialized successfully',
          source: 'Init');

      try {
        final settings =
            await PersistenceInitializer.settingsRepository!.getStoreSettings();

        FileLogger.info('Store settings loaded: ${settings.storeName}',
            source: 'Init');
      } catch (e) {
        FileLogger.warning('Store settings error', error: e, source: 'Init');
      }

      // Load current session
      await getIt<SessionRepositoryImpl>().loadCurrentSession();
      final session = getIt<SessionRepositoryImpl>().getCurrentSession();
      if (session != null) {
        FileLogger.info('Resumed open session: ${session.id}', source: 'Init');
      } else {
        FileLogger.info('No open session to resume', source: 'Init');
      }

      await RecoveryService().check();

      await getIt<ActivityLogger>().loadRecentActivities();

      // Create startup checkpoint
      await CheckpointService()
          .createCheckpoint(reason: 'startup', userName: 'system');

      // Register BackupManager in GetIt for data_management_screen access
      if (!getIt.isRegistered<BackupManager>()) {
        getIt.registerSingleton<BackupManager>(
          PersistenceInitializer.persistenceManager!.backupManager,
        );
      }

      // Start periodic auto-backup every 30 minutes
      PersistenceInitializer.persistenceManager!.backupManager
          .startPeriodicBackup();
    } else {
      FileLogger.info('First launch detected, awaiting data path configuration',
          source: 'Init');
    }
  } catch (e, stackTrace) {
    FileLogger.critical('Persistence system initialization failed',
        error: e, stackTrace: stackTrace, source: 'Init');
    CrashLogger.logException(e,
        stackTrace: stackTrace,
        context: 'Persistence initialization',
        isFatal: false);
  }
}

void main() async {
  // Wrap entire app in error zone to catch all async errors
  runZonedGuarded(
    () async {
      try {
        WidgetsFlutterBinding.ensureInitialized();

        // 1. Initialize Window Manager for Desktop
        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          await windowManager.ensureInitialized();
          await _setupWindow();
        }

        Bloc.observer = MyBlocObserver();

        // 2. Setup Dependency Injection
        setup();

        // 3. Initialize Persistence System (includes logging)
        try {
          await _initializePersistenceSystem().timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              FileLogger.warning('Persistence initialization timed out',
                  source: 'Main');
            },
          );
        } catch (e, stack) {
          FileLogger.error('Persistence initialization error',
              error: e, stackTrace: stack, source: 'Main');
        }

        // 4. Check activation and Run App
        bool fileExists = await File(requiredFilePath).exists();
        if (fileExists) {
          FileLogger.info('App starting normally', source: 'Main');
          runApp(const MyApp());
        } else {
          FileLogger.info('App starting in activation mode', source: 'Main');
          runApp(const ActivationScreen());
        }
      } catch (e, stack) {
        FileLogger.critical('Critical startup error',
            error: e, stackTrace: stack, source: 'Main');
        CrashLogger.logException(e,
            stackTrace: stack, context: 'App startup', isFatal: true);

        runApp(MaterialApp(
          home: Scaffold(
            body: Center(
              child: SelectableText('Failed to start application: $e'),
            ),
          ),
        ));
      }
    },
    (error, stack) {
      // Catch all unhandled async errors

      FileLogger.critical('Unhandled async error',
          error: error, stackTrace: stack, source: 'ErrorZone');
      CrashLogger.logException(error,
          stackTrace: stack, context: 'Unhandled async error', isFatal: true);
    },
  );
}

Future<void> _setupWindow() async {
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
    title: 'Bayaa',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.maximize();
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserCubit>.value(
      value: getIt<UserCubit>(),
      child: MessageOverlay(
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Bayaa',
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

            return BlocListener<UserCubit, UserStates>(
              listener: (context, state) {
                if (state is UserInitial) {
                  // Global logout handler
                  navigatorKey.currentState?.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              ),
            );
          },
        ),
      ),
    );
  }
}
