// domain/usecases/game/search_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class SearchGames extends UseCase<List<Game>, SearchGamesParams> {
  final GameRepository repository;

  SearchGames(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(SearchGamesParams params) async {
    if (params.query.isEmpty) {
      return const Left(ValidationFailure(message: 'Search query cannot be empty'));
    }

    return await repository.searchGames(
      query: params.query,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class SearchGamesParams extends Equatable {
  final String query;
  final int limit;
  final int offset;

  const SearchGamesParams({
    required this.query,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [query, limit, offset];
}