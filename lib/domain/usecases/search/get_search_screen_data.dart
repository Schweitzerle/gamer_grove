// ==========================================

// lib/domain/usecases/search/get_search_screen_data.dart
// Composite Use Case for efficient search screen loading
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/genre.dart';
import '../../entities/platform/platform.dart';
import '../base_usecase.dart';
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
      // Execute concurrent requests for better performance
      final results = await Future.wait([
        getAllGenres(),
        getAllPlatforms(),
        if (params.partialQuery?.isNotEmpty == true)
          getSearchSuggestions(GetSearchSuggestionsParams(partialQuery: params.partialQuery!))
        else
          Future.value(const Right(<String>[])),
      ]);

      // Check if any request failed
      for (final result in results) {
        if (result.isLeft()) {
          return result.fold(
                (failure) => Left(failure),
                (data) => throw Exception('Unexpected success in fold'),
          );
        }
      }

      // Extract successful results
      final genres = results[0].fold((l) => <Genre>[], (r) => r as List<Genre>);
      final platforms = results[1].fold((l) => <Platform>[], (r) => r as List<Platform>);
      final suggestions = results[2].fold((l) => <String>[], (r) => r as List<String>);

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