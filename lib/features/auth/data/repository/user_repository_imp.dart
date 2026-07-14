import 'package:bayaa_pos/core/data/services/persistence_initializer.dart';
import 'package:bayaa_pos/core/data/services/repository_persistence_mixin.dart';
import 'package:bayaa_pos/core/error/failure.dart';
import 'package:bayaa_pos/core/error/error_handler.dart';
import 'package:bayaa_pos/core/state/state_synchronizer.dart';
import 'package:bayaa_pos/features/auth/data/models/user_model.dart';
import 'package:bayaa_pos/features/auth/domain/repository/user_repository_int.dart';
import 'package:either_dart/either.dart';

class UserRepositoryImp extends UserRepositoryInt with RepositoryPersistenceMixin {
  // Removed UserDataSource dependency
  UserRepositoryImp();

  @override
  Future<Either<Failure, void>> deleteUser(String username) async {
    try {
      await deleteCritical(
        entity: 'user',
        id: username,
        sqliteWrite: () async {
          final db = PersistenceInitializer.persistenceManager!.sqliteManager;
          await db.delete('users', where: 'username = ?', whereArgs: [username]);
        },
      );
      return const Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure("Failed to delete user: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getAllUsers() async {
    try {
      print('👥 === LOADING USERS (SQLite) ===');
      
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final results = await db.query('users', where: 'is_active = 1');
      print('  👤 Users found in SQL: ${results.length}');
      
      final users = results.map((m) => User(
        name: m['display_name'] as String,
        username: m['username'] as String,
        password: m['password_hash'] as String? ?? '',
        userType: _mapRoleToUserType(m['role'] as String),
        phone: m['phone'] as String? ?? '',
        imagePath: m['image_path'] as String?,
      )).toList();
      
      for (var user in users) {
        print('     - ${user.name} (@${user.username}) - ${user.userType == UserType.manager ? "Manager" : "Cashier"}');
      }
      
      return Right(users);
    } on Exception catch (e) {
      print('  ❌ Failed to load users: $e');
      return Left(CacheFailure("Failed to fetch users: ${e.toString()}"));
    }
  }

  UserType _mapRoleToUserType(String role) {
    switch (role) {
      case 'manager':
      case 'admin':
        return UserType.manager;
      default:
        return UserType.cashier;
    }
  }

  @override
  Future<Either<Failure, User>> getUser(String username) async {
    try {
      print('👤 === GETTING USER: $username (SQLite) ===');
      
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final results = await db.query('users', 
        where: 'username = ? AND is_active = 1', 
        whereArgs: [username]
      );
      
      if (results.isNotEmpty) {
        final userMap = results.first;
        final user = User(
          name: userMap['display_name'] as String,
          username: userMap['username'] as String,
          password: userMap['password_hash'] as String,
          userType: _mapRoleToUserType(userMap['role'] as String),
          phone: userMap['phone'] as String? ?? '',
          imagePath: userMap['image_path'] as String?,
        );
        
        print('  ✅ User found: ${user.name}');
        return Right(user);
      } else {
        print('  ❌ User not found');
        return Left(CacheFailure("User not found"));
      }
    } on Exception catch (e) {
      print('  ❌ Failed to get user: $e');
      return Left(CacheFailure("Failed to fetch user: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, void>> saveUser(User user) async {
    return ErrorHandler.executeWithErrorHandlingEitherDart(
      operation: () async {
        print('👤 === SAVING USER (SQLite) ===');
        print('  📝 Name: ${user.name}');
        print('  👤 Username: ${user.username}');
        
        final isUpdate = await _userExists(user.username);
        
        await writeCritical(
          entity: 'user',
          id: user.username,
          data: user.toMap(),
          sqliteWrite: () async {
            final db = PersistenceInitializer.persistenceManager!.sqliteManager;
            
            final existing = await db.query('users', where: 'username = ?', whereArgs: [user.username]);
            print('  🗄️ Database Action: ${existing.isNotEmpty ? "UPDATE" : "INSERT"}');

            final values = <String, Object?>{
              'username': user.username,
              'display_name': user.name,
              'phone': user.phone,
              'image_path': user.imagePath,
              'password_hash': user.password,
              'role': user.userType == UserType.manager ? 'manager' : 'cashier',
              'is_active': 1,
            };
            if (existing.isNotEmpty) {
              await db.update(
                'users',
                values,
                where: 'username = ?',
                whereArgs: [user.username],
              );
            } else {
              await db.insert('users', {
                'id': user.username,
                ...values,
                'created_at': DateTime.now().toIso8601String(),
              });
            }
          },
        );
        
        // Notify state change
        StateSynchronizer.notify(DataChangeEvent(
          entityType: 'user',
          operation: isUpdate ? 'update' : 'create',
          id: user.username,
        ));
        
        print('  ✅ User saved successfully\n');
        return const Right(null);
      },
      operationName: 'saveUser',
      userFriendlyMessage: 'Failed to save user',
      source: 'UserRepository',
    );
  }
  
  Future<bool> _userExists(String username) async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final result = await db.query('users', where: 'username = ?', whereArgs: [username]);
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(User user) async {
    return saveUser(user);
  }
}
