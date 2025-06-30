// ==========================================

// lib/domain/usecases/recommendations/get_games_to_play_next.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGamesToPlayNext extends UseCase<List<Game>, GetGamesToPlayNextParams> {
  final GameRepository repository;

  GetGamesToPlayNext(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetGamesToPlayNextParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getGamesToPlayNext(
      userId: params.userId,
      limit: params.limit,
    );
  }
}

class GetGamesToPlayNextParams extends Equatable {
  final String userId;
  final int limit;

  const GetGamesToPlayNextParams({
    required this.userId,
    this.limit = 10,
  });

  @override
  List<Object> get props => [userId, limit];
}