// lib/domain/usecases/game/toggle_recommend.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class ToggleRecommend extends UseCase<void, ToggleRecommendParams> {
  final GameRepository repository;

  ToggleRecommend(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleRecommendParams params) async {
    return await repository.toggleRecommended(
      gameId: params.gameId,
      userId: params.userId,
    );
  }
}

class ToggleRecommendParams extends Equatable {
  final int gameId;
  final String userId;

  const ToggleRecommendParams({
    required this.gameId,
    required this.userId,
  });

  @override
  List<Object> get props => [gameId, userId];
}

