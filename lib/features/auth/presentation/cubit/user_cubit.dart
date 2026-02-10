
import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';
import 'package:crazy_phone_pos/features/auth/domain/repository/user_repository_int.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_states.dart';
import 'package:crazy_phone_pos/features/arp/data/repositories/session_repository_impl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../sales/data/repository/sales_repository_impl.dart';
import '../../../arp/data/models/product_performance_model.dart';
import '../../../../core/services/activity_logger.dart';
import '../../../../core/data/models/activity_log.dart';
import '../../../arp/data/models/session_model.dart';


class UserCubit extends Cubit<UserStates> {
  UserCubit({
    required this.userRepository,
    required this.sessionRepository,
  }) : super(UserInitial());

  final UserRepositoryInt userRepository;
  final SessionRepositoryImpl sessionRepository;

  static UserCubit get(context) => BlocProvider.of(context);
  late User currentUser;
  bool _isPasswordVisible = false;

  bool get isPasswordVisible => _isPasswordVisible;

  List<User> _users = [];
  List<User> get users => _users; // Access cached users even if state is not Loaded

  void getAllUsers() async {
    emit(UserLoading());
    final result = await userRepository.getAllUsers();
    result.fold(
      (failure) => emit(UserFailure(failure.message)),
      (usersList) async {
        if (usersList.isEmpty) {
          print('ℹ️ No users found. Seeding default admin...');
          final defaultAdmin = User(
            username: 'admin',
            password: 'admin',
            name: 'مدير النظام',
            userType: UserType.manager,
            phone: '000',
          );
          await userRepository.saveUser(defaultAdmin);
          getAllUsers(); // Retry loading
          return;
        }

        // Sort: Managers first
        usersList.sort((a, b) {
           if (a.userType == UserType.manager && b.userType != UserType.manager) return -1;
           if (a.userType != UserType.manager && b.userType == UserType.manager) return 1;
           return 0;
        });
        _users = usersList;
        emit(UsersLoaded(usersList));
      },
    );
  }

 void deleteUser(String username) async {
  emit(UserLoading());
  final result = await userRepository.deleteUser(username);
  result.fold(
    (failure) => emit(UserFailure(failure.message)),
    (_) {
      emit(UserSuccess("تم حذف المستخدم بنجاح"));
      
      // Log activity
      getIt<ActivityLogger>().logActivity(
        type: ActivityType.userDelete,
        description: 'حذف مستخدم: $username',
        userName: currentUser.name,
      );
      
      getAllUsers(); 
    },
  );
}

void saveUser(User user) async {
  emit(UserLoading());
  final result = await userRepository.saveUser(user);
  result.fold(
    (failure) => emit(UserFailure(failure.message)),
    (_) {
      emit(UserSuccess("تم إضافة المستخدم بنجاح"));
      
      // Check if update (simple check if username exists in list, though list might be empty if not loaded)
      // Since we just saved successfully, we can't check _users easily if username is same vs new?
      // Actually saveUser is usually Upsert.
      final isUpdate = _users.any((u) => u.username == user.username);

      // Log activity
      getIt<ActivityLogger>().logActivity(
        type: isUpdate ? ActivityType.userUpdate : ActivityType.userAdd, // Assuming userUpdate exists in enum, if not use generic
        description: isUpdate ? 'تحديث مستخدم: ${user.name}' : 'إضافة مستخدم: ${user.name}',
        userName: currentUser.name,
      );
      
      getAllUsers(); 
    },
  );
}
void updateUser(User user) async {
  emit(UserLoading());
  final result = await userRepository.updateUser(user);
  result.fold(
    (failure) => emit(UserFailure(failure.message)),
    (_) {
      if (currentUser.username == user.username) {
        currentUser = user;
      }
      emit(UserSuccess("تم تحديث المستخدم بنجاح"));
      
      // Log activity
      getIt<ActivityLogger>().logActivity(
        type: ActivityType.userUpdate,
        description: 'تحديث مستخدم: ${user.name}',
        userName: currentUser.name,
      );
      
      getAllUsers(); 
    },
  );
}
  void getUser(String username) async {
    emit(UserLoading());
    final result = await userRepository.getUser(username);
    result.fold(
      (failure) => emit(UserFailure(failure.message)),
      (user) =>
          emit(UserSuccess("User fetched successfully: ${user.username}")),
    );
  }

  void login(String username, String password) async {
    emit(UserLoading());
    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();
    
    final result = await userRepository.getUser(trimmedUsername);
    result.fold(
      (failure) => emit(UserFailure(failure.message)),
      (user) async {
        print("🔐 Login Attempt: '${trimmedUsername}'");
        print("   Input Password: '${trimmedPassword}'");
        print("   Stored Password: '${user.password}'");
        
        if (user.password == trimmedPassword) {
          currentUser = user;
          try {
             // Open Session on Login
             await sessionRepository.openSession(user);
             
             // Log activity
             getIt<ActivityLogger>().logActivity(
               type: ActivityType.sessionOpen,
               description: 'فتح جلسة جديدة',
               userName: user.name,
             );
             
             emit(UserSuccess("تم تسجيل الدخول بنجاح"));
          } catch (e) {
             emit(UserFailure("فشل فتح الجلسة: $e"));
          }
        } else {
          print("   ❌ Password Mismatch!");
          emit(UserFailure("كلمة المرور غير صحيحة"));
        }
      },
    );
  }

  Future<void> closeSession() async {
    emit(CloseSessionLoading());
    try {
      final session = sessionRepository.getCurrentSession();
      if (session == null) {
        emit(UserFailure("لا توجد جلسة مفتوحة لإغلاقها."));
        return;
      }

      // Robust Session Capture: Time-Based + ID-Based
      // We explicitly scan recent sales to ensure nothing is missed
      final salesRepo = getIt<SalesRepositoryImpl>();
      final legacyResult = await salesRepo.getRecentSales(limit: 200000);
      final allRecent = legacyResult.getOrElse(() => []);
      
      final sales = allRecent.where((s) {
           // 1. Explicit Session Match
           if (s.sessionId == session.id) return true;
           
           // 2. Time Window Match (Fallback for orphans or missing IDs)
           // "From Start to End" as requested by user
           if (s.date.isAfter(session.openTime) && s.date.isBefore(DateTime.now())) {
             // If manual linking failed, time is the source of truth
             return true; 
           }
           return false;
      }).toList();

      // Ensure all found sales are linked to this session in DB
      // This fixes "No Data" bug for orphans found by time-window
      if (sales.isNotEmpty) {
        await salesRepo.linkSalesToSession(sales.map((e) => e.id).toList(), session.id);
      }

      double totalSales = 0.0;
      double totalRefunds = 0.0;
      final Map<String, ProductPerformanceModel> productStats = {};
      final Map<String, ProductPerformanceModel> refundStats = {};

      for (final sale in sales) {
        final isRefund = sale.isRefund;
        final sign = isRefund ? -1.0 : 1.0;

        if (isRefund) {
          totalRefunds += sale.total.abs();
        } else {
          totalSales += sale.total;
        }

        for (final item in sale.saleItems) {
          final revenue = (item.price * item.quantity) * sign;
          final cost = (item.wholesalePrice * item.quantity) * sign;

          // Main Stats (Net)
          if (productStats.containsKey(item.productId)) {
            final existing = productStats[item.productId]!;
            productStats[item.productId] = ProductPerformanceModel(
              productId: existing.productId,
              productName: existing.productName,
              quantitySold: existing.quantitySold + (item.quantity * (isRefund ? -1 : 1)),
              revenue: existing.revenue + revenue,
              cost: existing.cost + cost,
              profit: 0,
              profitMargin: 0,
            );
          } else {
            productStats[item.productId] = ProductPerformanceModel(
              productId: item.productId,
              productName: item.name,
              quantitySold: item.quantity * (isRefund ? -1 : 1),
              revenue: revenue,
              cost: cost,
              profit: 0,
              profitMargin: 0,
            );
          }
          
          // Refund Specific Stats
          if (isRefund) {
             if (refundStats.containsKey(item.productId)) {
                final existing = refundStats[item.productId]!;
                refundStats[item.productId] = existing.copyWith(
                   quantitySold: existing.quantitySold + item.quantity,
                   revenue: existing.revenue + item.total, // Refund amount
                );
             } else {
                refundStats[item.productId] = ProductPerformanceModel(
                  productId: item.productId,
                  productName: item.name,
                  quantitySold: item.quantity,
                  revenue: item.total, // Refunded Amount
                  cost: item.wholesalePrice * item.quantity, // Cost not usually subtracted on refund list view
                  profit: 0,
                  profitMargin: 0,
                );
             }
          }
        }
      }

      final List<ProductPerformanceModel> topProducts = productStats.values.map((p) {
        final profit = p.revenue - p.cost;
        final margin = p.revenue > 0 ? (profit / p.revenue) * 100 : 0.0;
        return p.copyWith(profit: profit, profitMargin: margin);
      }).toList()
        ..sort((a, b) => b.revenue.compareTo(a.revenue));

      final List<ProductPerformanceModel> refundedProducts = refundStats.values.toList();
      
      final netRevenue = totalSales - totalRefunds;

      // Close session with session-based snapshot data (including refunds)
      final report = await sessionRepository.closeSession(
        currentUser,
        totalSales: totalSales,
        totalRefunds: totalRefunds,
        netRevenue: netRevenue,
        totalTransactions: sales.length,
        topProducts: topProducts,
        refundedProducts: refundedProducts,
        transactions: sales,
      );
      
      // Log activity
      getIt<ActivityLogger>().logActivity(
        type: ActivityType.sessionClose,
        description: 'إغلاق جلسة: ${totalSales.toStringAsFixed(2)} ج.م',
        userName: currentUser.name,
      );
      
      // Create closed session for navigation
      final closedSession = Session(
        id: session.id,
        openTime: session.openTime,
        closeTime: report.date,
        isOpen: false,
        openedByUserId: session.openedByUserId,
        closedByUserId: currentUser.username, // User model uses username as ID
        invoiceIds: session.invoiceIds,
        dailyReportId: report.id,
      );

      emit(UserSuccessWithReport("تم إغلاق اليومية بنجاح.", report, closedSession));
    } catch (e) {
      emit(UserFailure("فشل إغلاق اليومية: $e"));
    }
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    emit(PasswordVisibilityChanged(_isPasswordVisible));
  }

  void logout() {
    currentUser = User(
        name: '',
        phone: '',
        username: '',
        password: '',
        userType: UserType.cashier);
    emit(UserInitial());
  }
}
