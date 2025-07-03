// ==========================================

// lib/domain/usecases/search/get_search_screen_data.dart
// Composite Use Case for efficient search screen loading
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/genre.dart';
import '../../entities/platform/platform.dart';
import '../base_usecase.dart';
import '../game/get_all_genres.dart';
import '../game/get_all_platforms.dart';
import '../game/get_search_suggestions.dart';
import '../game/search_games_with_filter.dart';

class GetSearchScreenData extends UseCase<SearchScreenData, GetSearchScreenDataParams> {
  final GetAllGenres getAllGenres;
  final GetAllPlatforms getAllPlatforms;
  final GetSearchSuggestions getSearchSuggestions;

  GetSearchScreenData({
    required this.getAllGenres,
    required this.getAllPlatforms,
    required this.getSearchSuggestions,
  });

  @override
  Future<Either<Failure, SearchScreenData>> call(GetSearchScreenDataParams params) async {
    try {
      // Get all genres
      final genresResult = await getAllGenres();
      final genres = genresResult.fold((l) => <Genre>[], (r) => r);

      // Get all platforms
      final platformsResult = await getAllPlatforms();
      final platforms = platformsResult.fold((l) => <Platform>[], (r) => r);

      // Get search suggestions if partial query exists
      List<String> suggestions = [];
      if (params.partialQuery?.isNotEmpty == true) {
        final suggestionsResult = await getSearchSuggestions(
            GetSearchSuggestionsParams(partialQuery: params.partialQuery!)
        );
        suggestions = suggestionsResult.fold((l) => <String>[], (r) => r);
      }

      return Right(SearchScreenData(
        genres: genres,
        platforms: platforms,
        suggestions: suggestions,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load search screen data: $e'));
    }
  }
}

class GetSearchScreenDataParams extends Equatable {
  final String? partialQuery;

  const GetSearchScreenDataParams({this.partialQuery});

  @override
  List<Object?> get props => [partialQuery];
}

class SearchScreenData extends Equatable {
  final List<Genre> genres;
  final List<Platform> platforms;
  final List<String> suggestions;

  const SearchScreenData({
    required this.genres,
    required this.platforms,
    required this.suggestions,
  });

  @override
  List<Object> get props => [genres, platforms, suggestions];
}