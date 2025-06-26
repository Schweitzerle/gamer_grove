// domain/entities/game.dart
import 'package:equatable/equatable.dart';
import 'genre.dart';
import 'platform.dart';
import 'game_mode.dart';

class Game extends Equatable {
  final int id;
  final String name;
  final String? summary;
  final String? storyline;
  final double? rating;
  final int? ratingCount;
  final String? coverUrl;
  final List<String> screenshots;
  final List<String> artworks;
  final DateTime? releaseDate;
  final List<Genre> genres;
  final List<Platform> platforms;
  final List<GameMode> gameModes;
  final List<String> themes;
  final int? follows;
  final int? hypes;

  // User specific data
  final bool isWishlisted;
  final bool isRecommended;
  final double? userRating;
  final bool? isInTopThree;
  final int? topThreePosition; // NEU: Position in Top 3 (1, 2, oder 3)

  const Game({
    required this.id,
    required this.name,
    this.summary,
    this.storyline,
    this.rating,
    this.ratingCount,
    this.coverUrl,
    this.screenshots = const [],
    this.artworks = const [],
    this.releaseDate,
    this.genres = const [],
    this.platforms = const [],
    this.gameModes = const [],
    this.themes = const [],
    this.follows,
    this.hypes,
    this.isWishlisted = false,
    this.isRecommended = false,
    this.userRating,
    this.isInTopThree,
    this.topThreePosition, // NEU
  });

  @override
  List<Object?> get props => [
    id,
    name,
    summary,
    storyline,
    rating,
    ratingCount,
    coverUrl,
    screenshots,
    artworks,
    releaseDate,
    genres,
    platforms,
    gameModes,
    themes,
    follows,
    hypes,
    isWishlisted,
    isRecommended,
    userRating,
  ];

  double? get displayUserRating => userRating != null ? userRating! * 10 : null;

  Game copyWith({
    int? id,
    String? name,
    String? summary,
    String? storyline,
    double? rating,
    int? ratingCount,
    String? coverUrl,
    List<String>? screenshots,
    List<String>? artworks,
    DateTime? releaseDate,
    List<Genre>? genres,
    List<Platform>? platforms,
    List<GameMode>? gameModes,
    List<String>? themes,
    int? follows,
    int? hypes,
    bool? isWishlisted,
    bool? isRecommended,
    double? userRating,
    bool? isInTopThree,
    int? topThreePosition, // NEU
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      summary: summary ?? this.summary,
      storyline: storyline ?? this.storyline,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      coverUrl: coverUrl ?? this.coverUrl,
      screenshots: screenshots ?? this.screenshots,
      artworks: artworks ?? this.artworks,
      releaseDate: releaseDate ?? this.releaseDate,
      genres: genres ?? this.genres,
      platforms: platforms ?? this.platforms,
      gameModes: gameModes ?? this.gameModes,
      themes: themes ?? this.themes,
      follows: follows ?? this.follows,
      hypes: hypes ?? this.hypes,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      isRecommended: isRecommended ?? this.isRecommended,
      userRating: userRating ?? this.userRating,
      isInTopThree: isInTopThree ?? this.isInTopThree,
      topThreePosition: topThreePosition ?? this.topThreePosition,
    );
  }
}


