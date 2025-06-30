// data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/cache_datasource.dart';
import '../datasources/remote/supabase/supabase_remote_datasource.dart';
import '../models/user_model.dart';
import '../../main.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseRemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, domain.User>> signIn({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final user = await remoteDataSource.signIn(email, password);

      // Cache user data
      await localDataSource.cacheUser(user);

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, domain.User>> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    print('🌐 AuthRepository: Checking network connection...');

    if (!await networkInfo.isConnected) {
      print('❌ AuthRepository: No network connection');
      return const Left(NetworkFailure());
    }

    print('✅ AuthRepository: Network connected, calling remote data source...');

    try {
      final user = await remoteDataSource.signUp(email, password, username);
      print('✅ AuthRepository: Remote signup successful for: ${user.username}');

      // Cache user data
      print('💾 AuthRepository: Caching user data...');
      await localDataSource.cacheUser(user);
      print('✅ AuthRepository: User data cached successfully');

      return Right(user);
    } on AuthException catch (e) {
      print('🔐 AuthRepository: Auth exception: ${e.message}');
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      print('🖥️ AuthRepository: Server exception: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      print('💥 AuthRepository: Unexpected error: $e');
      print('📚 AuthRepository: Stack trace: $stackTrace');
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to sign out'));
    }
  }

  @override
  Future<Either<Failure, domain.User>> getCurrentUser() async {
    try {
      // Check if network is available for remote check
      if (await networkInfo.isConnected) {
        // Try to get from remote first
        final user = await remoteDataSource.getCurrentUser();
        if (user != null) {
          // Cache the user
          await localDataSource.cacheUser(user);
          return Right(user);
        }
      }

      // If no remote user, try cache
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }

      // No user found anywhere
      return const Left(AuthenticationFailure(message: 'No user logged in'));
    } catch (e) {
      return const Left(AuthenticationFailure(message: 'Failed to get current user'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await supabase.auth.resetPasswordForEmail(email);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to send reset email'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await supabase.auth.updateUser(
        sb.UserAttributes(password: newPassword),
      );
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to update password'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      // Note: This requires server-side implementation
      // For now, we just sign out
      await signOut();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to delete account'));
    }
  }

  @override
  Stream<domain.User?> get authStateChanges {
    return remoteDataSource.authStateChanges.asyncMap((authState) async {
      if (authState.session != null) {
        final user = await remoteDataSource.getCurrentUser();
        if (user != null) {
          await localDataSource.cacheUser(user);
        }
        return user;
      }
      return null;
    });
  }
}