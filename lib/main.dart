//import 'package:crazy_phone_pos/features/auth/presentation/login_screen.dart';
import 'package:crazy_phone_pos/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';

import 'core/di/dependency_injection.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/models/user_model.dart';


void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(UserTypeAdapter());
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<User>('userBox');
  Hive.box<User>('userBox').put(
      "admin",
      User(
          name: "Mostafa",
          phone: "01060030388",
          username: 'admin',
          password: '123456789',
          userType: UserType.maneger));
  setup();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crazy Phone POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      home: LoginScreen(),

      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'), // العربية
        Locale('en'), // الإنجليزية
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}
