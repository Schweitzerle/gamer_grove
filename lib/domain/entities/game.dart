// lib/domain/entities/game.dart (UPDATED)
import 'package:equatable/equatable.dart';
import 'genre.dart';
import 'platform.dart';
import 'game_mode.dart';
import 'involved_company.dart';
import 'website.dart';
import 'game_video.dart';
import 'age_rating.dart';
import 'game_engine.dart';
import 'keyword.dart';
import 'multiplayer_mode.dart';
import 'player_perspective.dart';
import 'franchise.dart';
import 'collection.dart';
import 'external_game.dart';
import 'language_support.dart';

class Game extends Equatable {
  // GRUNDLEGENDE DATEN
  final int id;
  final String name;
  final String? summary;
  final String? storyline;
  final double? rating;
  final int? ratingCount;
  final String? coverUrl;
  final DateTime? releaseDate;

  // MEDIEN
  final List<String> screenshots;
  final List<String> artworks;
  final List<GameVideo> videos;

  // KATEGORISIERUNG
  final List<Genre> genres;
  final List<Platform> platforms;
  final List<GameMode> gameModes;
  final List<String> themes;
  final List<Keyword> keywords;
  final List<PlayerPerspective> playerPerspectives;

  // UNTERNEHMEN & ENTWICKLUNG
  final List<InvolvedCompany> involvedCompanies;
  final List<GameEngine> gameEngines;

  // EXTERNE LINKS & STORES
  final List<Website> websites;
  final List<ExternalGame> externalGames;

  // BEWERTUNGEN & REGULIERUNG
  final List<AgeRating> ageRatings;

  // MULTIPLAYER & FEATURES
  final List<MultiplayerMode> multiplayerModes;
  final List<LanguageSupport> languageSupports;

  // SERIEN & SAMMLUNGEN
  final List<Franchise> franchises;
  final List<Collection> collections;
  final List<Game> similarGames;
  final List<Game> dlcs;
  final List<Game> expansions;

  // ALTERNATIVE NAMEN
  final List<String> alternativeNames;

  // COMMUNITY & HYPE
  final int? follows;
  final int? hypes;

  // USER DATEN (nicht von IGDB API)
  final bool isWishlisted;
  final bool isRecommended;
  final double? userRating;
  final bool isInTopThree;
  final int? topThreePosition;

  // ZUSÄTZLICHE METADATEN
  final DateTime? firstReleaseDate;
  final String? status; // "released", "alpha", "beta", "early_access", etc.
  final List<String> releaseDates; // Verschiedene Release Dates für verschiedene Regionen
  final String? versionTitle; // z.B. "Director's Cut", "GOTY Edition"
  final bool isBundle;
  final bool isExpansion;
  final bool isStandalone;
  final Game? parentGame; // Für DLCs/Expansions

  const Game({
    required this.id,
    required this.name,
    this.summary,
    this.storyline,
    this.rating,
    this.ratingCount,
    this.coverUrl,
    this.releaseDate,
    this.screenshots = const [],
    this.artworks = const [],
    this.videos = const [],
    this.genres = const [],
    this.platforms = const [],
    this.gameModes = const [],
    this.themes = const [],
    this.keywords = const [],
    this.playerPerspectives = const [],
    this.involvedCompanies = const [],
    this.gameEngines = const [],
    this.websites = const [],
    this.externalGames = const [],
    this.ageRatings = const [],
    this.multiplayerModes = const [],
    this.languageSupports = const [],
    this.franchises = const [],
    this.collections = const [],
    this.similarGames = const [],
    this.dlcs = const [],
    this.expansions = const [],
    this.alternativeNames = const [],
    this.follows,
    this.hypes,
    this.isWishlisted = false,
    this.isRecommended = false,
    this.userRating,
    this.isInTopThree = false,
    this.topThreePosition,
    this.firstReleaseDate,
    this.status,
    this.releaseDates = const [],
    this.versionTitle,
    this.isBundle = false,
    this.isExpansion = false,
    this.isStandalone = true,
    this.parentGame,
  });

  // HELPER GETTERS
  double get displayUserRating =>
      userRating! *10;

  List<InvolvedCompany> get developers =>
      involvedCompanies.where((c) => c.isDeveloper).toList();

  List<InvolvedCompany> get publishers =>
      involvedCompanies.where((c) => c.isPublisher).toList();

  Website? get officialWebsite =>
      websites.where((w) => w.category == WebsiteCategory.official).firstOrNull;

  Website? get steamPage =>
      websites.where((w) => w.category == WebsiteCategory.steam).firstOrNull;

  ExternalGame? get steamStore =>
      externalGames.where((e) => e.category == ExternalGameCategory.steam).firstOrNull;

  List<Website> get socialMediaLinks => websites.where((w) =>
      [WebsiteCategory.facebook, WebsiteCategory.twitter, WebsiteCategory.instagram,
        WebsiteCategory.youtube, WebsiteCategory.twitch, WebsiteCategory.discord].contains(w.category)
  ).toList();

  AgeRating? get esrbRating =>
      ageRatings.where((r) => r.category == AgeRatingCategory.esrb).firstOrNull;

  AgeRating? get pegiRating =>
      ageRatings.where((r) => r.category == AgeRatingCategory.pegi).firstOrNull;

  bool get hasMultiplayer => multiplayerModes.isNotEmpty;

  bool get hasOnlineMultiplayer => multiplayerModes.any((m) =>
  m.onlineCoop || m.onlineMax);

  bool get hasLocalMultiplayer => multiplayerModes.any((m) =>
  m.offlineCoop || m.offlineMax || m.splitscreen);

  @override
  List<Object?> get props => [
    id, name, summary, storyline, rating, ratingCount, coverUrl, releaseDate,
    screenshots, artworks, videos, genres, platforms, gameModes, themes, keywords,
    playerPerspectives, involvedCompanies, gameEngines, websites, externalGames,
    ageRatings, multiplayerModes, languageSupports, franchises, collections,
    similarGames, dlcs, expansions, alternativeNames, follows, hypes,
    isWishlisted, isRecommended, userRating, isInTopThree, topThreePosition,
    firstReleaseDate, status, releaseDates, versionTitle, isBundle, isExpansion,
    isStandalone, parentGame
  ];

  Game copyWith({
    int? id,
    String? name,
    String? summary,
    String? storyline,
    double? rating,
    int? ratingCount,
    String? coverUrl,
    DateTime? releaseDate,
    List<String>? screenshots,
    List<String>? artworks,
    List<GameVideo>? videos,
    List<Genre>? genres,
    List<Platform>? platforms,
    List<GameMode>? gameModes,
    List<String>? themes,
    List<Keyword>? keywords,
    List<PlayerPerspective>? playerPerspectives,
    List<InvolvedCompany>? involvedCompanies,
    List<GameEngine>? gameEngines,
    List<Website>? websites,
    List<ExternalGame>? externalGames,
    List<AgeRating>? ageRatings,
    List<MultiplayerMode>? multiplayerModes,
    List<LanguageSupport>? languageSupports,
    List<Franchise>? franchises,
    List<Collection>? collections,
    List<Game>? similarGames,
    List<Game>? dlcs,
    List<Game>? expansions,
    List<String>? alternativeNames,
    int? follows,
    int? hypes,
    bool? isWishlisted,
    bool? isRecommended,
    double? userRating,
    bool? isInTopThree,
    int? topThreePosition,
    DateTime? firstReleaseDate,
    String? status,
    List<String>? releaseDates,
    String? versionTitle,
    bool? isBundle,
    bool? isExpansion,
    bool? isStandalone,
    Game? parentGame,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      summary: summary ?? this.summary,
      storyline: storyline ?? this.storyline,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      coverUrl: coverUrl ?? this.coverUrl,
      releaseDate: releaseDate ?? this.releaseDate,
      screenshots: screenshots ?? this.screenshots,
      artworks: artworks ?? this.artworks,
      videos: videos ?? this.videos,
      genres: genres ?? this.genres,
      platforms: platforms ?? this.platforms,
      gameModes: gameModes ?? this.gameModes,
      themes: themes ?? this.themes,
      keywords: keywords ?? this.keywords,
      playerPerspectives: playerPerspectives ?? this.playerPerspectives,
      involvedCompanies: involvedCompanies ?? this.involvedCompanies,
      gameEngines: gameEngines ?? this.gameEngines,
      websites: websites ?? this.websites,
      externalGames: externalGames ?? this.externalGames,
      ageRatings: ageRatings ?? this.ageRatings,
      multiplayerModes: multiplayerModes ?? this.multiplayerModes,
      languageSupports: languageSupports ?? this.languageSupports,
      franchises: franchises ?? this.franchises,
      collections: collections ?? this.collections,
      similarGames: similarGames ?? this.similarGames,
      dlcs: dlcs ?? this.dlcs,
      expansions: expansions ?? this.expansions,
      alternativeNames: alternativeNames ?? this.alternativeNames,
      follows: follows ?? this.follows,
      hypes: hypes ?? this.hypes,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      isRecommended: isRecommended ?? this.isRecommended,
      userRating: userRating ?? this.userRating,
      isInTopThree: isInTopThree ?? this.isInTopThree,
      topThreePosition: topThreePosition ?? this.topThreePosition,
      firstReleaseDate: firstReleaseDate ?? this.firstReleaseDate,
      status: status ?? this.status,
      releaseDates: releaseDates ?? this.releaseDates,
      versionTitle: versionTitle ?? this.versionTitle,
      isBundle: isBundle ?? this.isBundle,
      isExpansion: isExpansion ?? this.isExpansion,
      isStandalone: isStandalone ?? this.isStandalone,
      parentGame: parentGame ?? this.parentGame,
    );
  }
}