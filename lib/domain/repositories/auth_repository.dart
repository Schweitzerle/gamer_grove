// domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String username,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, void>> resetPassword(String email);

  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, void>> deleteAccount();

  Stream<User?> get authStateChanges;
}