// ==========================================

// lib/domain/usecases/discovery/get_games_by_mood.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../entities/recommendations/game_mood.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGamesByMood extends UseCase<List<Game>, GetGamesByMoodParams> {
  final GameRepository repository;

  GetGamesByMood(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetGamesByMoodParams params) async {
    return await repository.getGamesByMood(
      mood: params.mood,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetGamesByMoodParams extends Equatable {
  final GameMood mood;
  final int limit;
  final int offset;

  const GetGamesByMoodParams({
    required this.mood,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [mood, limit, offset];
}