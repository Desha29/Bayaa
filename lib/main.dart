import 'package:crazy_phone_pos/features/auth/presentation/login_screen.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';

import 'core/constants/bloc_observer.dart';
import 'core/di/dependency_injection.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/data_sources/user_data_source.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/auth/data/repository/user_repository_imp.dart';
import 'features/settings/data/models/store_info_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await Hive.initFlutter();
  //  // 🚨 DELETE CORRUPTED BOX - Run once, then remove this block
  // try {
  //   await Hive.deleteBoxFromDisk('storeBox');
  //   print('✅ Deleted corrupted storeBox');
  // } catch (e) {
  //   print('⚠️ storeBox already clean');
  // }
  // Register Adapters
  Hive.registerAdapter(UserTypeAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(StoreInfoAdapter());

  // Open Boxes
  await Hive.openBox<User>('userBox');
  await Hive.openBox<StoreInfo>('storeBox');

  Hive.box<User>('userBox').put(
    "admin",
    User(
      name: "Mostafa",
      phone: "01060030388",
      username: 'admin',
      password: '123456789',
      userType: UserType.manager,
    ),
  );
final storeBox = Hive.box<StoreInfo>('storeBox');
  if (!storeBox.containsKey('store_info')) {
    storeBox.put(
      'store_info',
      StoreInfo(
        name: 'Crazy Phone',
        phone: '01000000000',
        email: 'info@crazyphone.com',
        address: "امام شارع الحجار - الخانكة - القليوبية",
        vat: '123456789',
      ),
    );
  }


  setup();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Provide UserCubit at the app level
      create: (context) => UserCubit(
        userRepository: UserRepositoryImp(
          userDataSource: UserDataSource(),
        )..getAllUsers(),
      ),
      child: MaterialApp(
        title: 'Crazy Phone POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
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
      ),
    );
  }
}
