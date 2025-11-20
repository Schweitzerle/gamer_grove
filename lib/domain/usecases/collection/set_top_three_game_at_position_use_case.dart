import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class SetTopThreeGameAtPositionUseCase extends UseCase<void, SetTopThreeGameAtPositionParams> {

  SetTopThreeGameAtPositionUseCase(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, void>> call(SetTopThreeGameAtPositionParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }
    if (params.position < 1 || params.position > 3) {
      return const Left(ValidationFailure(message: 'Position must be 1, 2, or 3'));
    }

    return repository.setTopThreeGameAtPosition(
      userId: params.userId,
      position: params.position,
      gameId: params.gameId,
    );
  }
}

class SetTopThreeGameAtPositionParams extends Equatable {

  const SetTopThreeGameAtPositionParams({
    required this.userId,
    required this.gameId,
    required this.position,
  });
  final String userId;
  final int gameId;
  final int position;

  @override
  List<Object> get props => [userId, gameId, position];
}
