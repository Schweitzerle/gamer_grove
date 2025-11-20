// ============================================================
// GET TOP THREE USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Use case for getting user's top 3 games.
///
/// Example:
/// ```dart
/// final useCase = GetTopThreeUseCase(userRepository);
/// final result = await useCase(GetTopThreeParams(userId: 'uuid'));
///
/// result.fold(
///   (games) {
///     if (games.isNotEmpty) {
///     } else {
///     }
///   },
/// );
/// ```
class GetTopThreeUseCase
    implements UseCase<List<Map<String, dynamic>>, GetTopThreeParams> {

  GetTopThreeUseCase(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
      GetTopThreeParams params,) async {
    return repository.getUserTopThreeGames(userId: params.userId);
  }
}

class GetTopThreeParams extends Equatable {

  const GetTopThreeParams({required this.userId});
  final String userId;

  @override
  List<Object> get props => [userId];
}
