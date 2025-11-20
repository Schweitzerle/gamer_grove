// ==========================================

// lib/domain/usecases/search/get_search_screen_data.dart
// Composite Use Case for efficient search screen loading
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/genre.dart';
import 'package:gamer_grove/domain/entities/platform/platform.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';
import 'package:gamer_grove/domain/usecases/game/get_all_genres.dart';
import 'package:gamer_grove/domain/usecases/game/get_all_platforms.dart';
import 'package:gamer_grove/domain/usecases/game/get_search_suggestions.dart';

class GetSearchScreenData
    extends UseCase<SearchScreenData, GetSearchScreenDataParams> {

  GetSearchScreenData({
    required this.getAllGenres,
    required this.getAllPlatforms,
    required this.getSearchSuggestions,
  });
  final GetAllGenres getAllGenres;
  final GetAllPlatforms getAllPlatforms;
  final GetSearchSuggestions getSearchSuggestions;

  @override
  Future<Either<Failure, SearchScreenData>> call(
      GetSearchScreenDataParams params,) async {
    try {
      // Get all genres
      final genresResult = await getAllGenres();
      final genres = genresResult.fold((l) => <Genre>[], (r) => r);

      // Get all platforms
      final platformsResult = await getAllPlatforms();
      final platforms = platformsResult.fold((l) => <Platform>[], (r) => r);

      // Get search suggestions if partial query exists
      var suggestions = <String>[];
      if (params.partialQuery?.isNotEmpty ?? false) {
        final suggestionsResult = await getSearchSuggestions(
            GetSearchSuggestionsParams(partialQuery: params.partialQuery!),);
        suggestions = suggestionsResult.fold((l) => <String>[], (r) => r);
      }

      return Right(SearchScreenData(
        genres: genres,
        platforms: platforms,
        suggestions: suggestions,
      ),);
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to load search screen data: $e'),);
    }
  }
}

class GetSearchScreenDataParams extends Equatable {

  const GetSearchScreenDataParams({this.partialQuery});
  final String? partialQuery;

  @override
  List<Object?> get props => [partialQuery];
}

class SearchScreenData extends Equatable {

  const SearchScreenData({
    required this.genres,
    required this.platforms,
    required this.suggestions,
  });
  final List<Genre> genres;
  final List<Platform> platforms;
  final List<String> suggestions;

  @override
  List<Object> get props => [genres, platforms, suggestions];
}
