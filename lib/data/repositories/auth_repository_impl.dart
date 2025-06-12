// data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/cache_datasource.dart';
import '../datasources/remote/supabase_remote_datasource.dart';
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
  Future<Either<Failure, User>> signIn({
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
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final user = await remoteDataSource.signUp(email, password, username);

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
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Try to get from cache first
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }

      // If not in cache, get from remote
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      final user = await remoteDataSource.getCurrentUser();
      if (user == null) {
        return const Left(AuthenticationFailure(message: 'No user logged in'));
      }

      // Cache the user
      await localDataSource.cacheUser(user);

      return Right(user);
    } catch (e) {
      return const Left(ServerFailure());
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
        UserAttributes(password: newPassword),
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
  Stream<User?> get authStateChanges {
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

