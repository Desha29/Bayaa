import 'package:crazy_phone_pos/features/auth/presentation/login_screen.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';

import 'core/constants/bloc_observer.dart';
import 'core/di/dependency_injection.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/data/models/user_model.dart';

import 'features/products/data/models/product_model.dart';
import 'features/settings/data/models/store_info_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(UserTypeAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(StoreInfoAdapter());
  Hive.registerAdapter(ProductAdapter());
  // Open Boxes
  await Hive.openBox<User>('userBox');
  await Hive.openBox<Product>('productsBox');
  await Hive.openBox('categoryBox');
  await Hive.openBox<StoreInfo>('storeBox');
  Hive.box<User>("userBox").put(
      'admin',
      User(
          name: "Mostafa",
          phone: "01000000000",
          username: 'admin',
          password: 'admin',
          userType: UserType.manager));

  Hive.box<Product>('productsBox').put(
      '600600',
      Product(
        name: 'سماعة ابل',
        barcode: '600600',
        price: 500,
        quantity: 10,
        minQuantity: 2,
        category: 'الكل',
      ));
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
    );
  }
}
