import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class RemoveFromTopThreeUseCase extends UseCase<void, RemoveFromTopThreeParams> {
  final UserRepository repository;

  RemoveFromTopThreeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFromTopThreeParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.removeFromTopThree(
      userId: params.userId,
      gameId: params.gameId,
    );
  }
}

class RemoveFromTopThreeParams extends Equatable {
  final String userId;
  final int gameId;

  const RemoveFromTopThreeParams({
    required this.userId,
    required this.gameId,
  });

  @override
  List<Object> get props => [userId, gameId];
}
