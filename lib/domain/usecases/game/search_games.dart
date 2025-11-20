// domain/usecases/game/search_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class SearchGames extends UseCase<List<Game>, SearchGamesParams> {

  SearchGames(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(SearchGamesParams params) async {
    if (params.query.isEmpty) {
      return const Left(ValidationFailure(message: 'Search query cannot be empty'));
    }

    return repository.searchGames(
      params.query,
      params.limit,
      params.offset,
    );
  }
}

class SearchGamesParams extends Equatable {

  const SearchGamesParams({
    required this.query,
    this.limit = 20,
    this.offset = 0,
  });
  final String query;
  final int limit;
  final int offset;

  @override
  List<Object> get props => [query, limit, offset];
}
