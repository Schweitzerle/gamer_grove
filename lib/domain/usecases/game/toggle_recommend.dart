// lib/domain/usecases/game/toggle_recommend.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class ToggleRecommend extends UseCase<void, ToggleRecommendParams> {

  ToggleRecommend(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, void>> call(ToggleRecommendParams params) async {
    return repository.toggleRecommend(
      params.gameId,
      params.userId,
    );
  }
}

class ToggleRecommendParams extends Equatable {

  const ToggleRecommendParams({
    required this.gameId,
    required this.userId,
  });
  final int gameId;
  final String userId;

  @override
  List<Object> get props => [gameId, userId];
}

