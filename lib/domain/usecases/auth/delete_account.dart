// ============================================================
// DELETE ACCOUNT USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/auth_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Permanently deletes the signed-in user's account and all their data.
///
/// Irreversible: profile, collections, ratings, wishlist, follows and the
/// login identity itself are removed. The caller is signed out afterwards.
class DeleteAccountUseCase implements UseCase<void, NoParams> {
  DeleteAccountUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return repository.deleteAccount();
  }
}
