import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class RemoveFromTopThreeUseCase extends UseCase<void, RemoveFromTopThreeParams> {

  RemoveFromTopThreeUseCase(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, void>> call(RemoveFromTopThreeParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return repository.removeFromTopThree(
      userId: params.userId,
      gameId: params.gameId,
    );
  }
}

class RemoveFromTopThreeParams extends Equatable {

  const RemoveFromTopThreeParams({
    required this.userId,
    required this.gameId,
  });
  final String userId;
  final int gameId;

  @override
  List<Object> get props => [userId, gameId];
}
