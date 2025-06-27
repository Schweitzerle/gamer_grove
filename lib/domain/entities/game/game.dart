// lib/domain/entities/game.dart (VOLLSTÄNDIG ERWEITERT)
import 'package:equatable/equatable.dart';
import '../genre.dart';
import '../platform/platform.dart';
import 'game_mode.dart';
import '../involved_company.dart';
import '../website.dart';
import 'game_video.dart';
import '../ageRating/age_rating.dart';
import 'game_engine.dart';
import '../keyword.dart';
import '../multiplayer_mode.dart';
import '../player_perspective.dart';
import '../franchise.dart';
import '../collection.dart';
import '../externalGame/external_game.dart';
import '../language_support.dart';
import '../release_date.dart';
import 'game_localization.dart';

// NEUE ENUMS FÜR GAME
enum GameType {
  mainGame,
  dlcAddon,
  expansion,
  bundle,
  standaloneExpansion,
  mod,
  episode,
  season,
  remake,
  remaster,
  expandedGame,
  port,
  fork,
  pack,
  update,
  unknown,
}

enum GameStatus {
  released,
  alpha,
  beta,
  earlyAccess,
  offline,
  cancelled,
  rumored,
  delisted,
  unknown,
}

class Game extends Equatable {
  // ===== GRUNDLEGENDE DATEN =====
  final int id;
  final String name;
  final String? summary;
  final String? storyline;
  final String? slug;
  final String? url;
  final String? checksum;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ===== BEWERTUNGEN =====
  final double? totalRating;           // Kombinierte Bewertung (User + Kritiker)
  final int? totalRatingCount;         // Anzahl kombinierte Bewertungen
  final double? rating;                // Nur IGDB User Bewertungen
  final int? ratingCount;              // Anzahl IGDB User Bewertungen
  final double? aggregatedRating;      // Nur Kritiker Bewertungen
  final int? aggregatedRatingCount;    // Anzahl Kritiker Bewertungen

  // ===== RELEASE & STATUS =====
  final DateTime? firstReleaseDate;
  final List<ReleaseDate> releaseDates;
  final GameStatus gameStatus;
  final GameType gameType;
  final String? versionTitle;
  final Game? versionParent;

  // ===== MEDIEN =====
  final String? coverUrl;
  final List<String> screenshots;
  final List<String> artworks;
  final List<GameVideo> videos;

  // ===== KATEGORISIERUNG =====
  final List<Genre> genres;
  final List<Platform> platforms;
  final List<GameMode> gameModes;
  final List<String> themes;
  final List<Keyword> keywords;
  final List<PlayerPerspective> playerPerspectives;
  final List<int> tags;

  // ===== UNTERNEHMEN & ENTWICKLUNG =====
  final List<InvolvedCompany> involvedCompanies;
  final List<GameEngine> gameEngines;

  // ===== EXTERNE LINKS & STORES =====
  final List<Website> websites;
  final List<ExternalGame> externalGames;

  // ===== BEWERTUNGEN & REGULIERUNG =====
  final List<AgeRating> ageRatings;

  // ===== MULTIPLAYER & FEATURES =====
  final List<MultiplayerMode> multiplayerModes;
  final List<LanguageSupport> languageSupports;
  final List<GameLocalization> gameLocalizations;

  // ===== SERIEN & SAMMLUNGEN =====
  final Franchise? mainFranchise;      // Haupt-Franchise (singular)
  final List<Franchise> franchises;    // Alle Franchises
  final List<Collection> collections;

  // ===== VERWANDTE SPIELE =====
  final List<Game> similarGames;
  final List<Game> dlcs;
  final List<Game> expansions;
  final List<Game> standaloneExpansions;
  final List<Game> bundles;
  final List<Game> expandedGames;
  final List<Game> forks;
  final List<Game> ports;
  final List<Game> remakes;
  final List<Game> remasters;
  final Game? parentGame;

  // ===== ALTERNATIVE NAMEN =====
  final List<String> alternativeNames;

  // ===== COMMUNITY & HYPE =====
  final int? hypes;

  // ===== USER DATEN (nicht von IGDB API) =====
  final bool isWishlisted;
  final bool isRecommended;
  final double? userRating;
  final bool isInTopThree;
  final int? topThreePosition;

  const Game({
    required this.id,
    required this.name,
    this.summary,
    this.storyline,
    this.slug,
    this.url,
    this.checksum,
    this.createdAt,
    this.updatedAt,
    this.totalRating,
    this.totalRatingCount,
    this.rating,
    this.ratingCount,
    this.aggregatedRating,
    this.aggregatedRatingCount,
    this.firstReleaseDate,
    this.releaseDates = const [],
    this.gameStatus = GameStatus.unknown,
    this.gameType = GameType.unknown,
    this.versionTitle,
    this.versionParent,
    this.coverUrl,
    this.screenshots = const [],
    this.artworks = const [],
    this.videos = const [],
    this.genres = const [],
    this.platforms = const [],
    this.gameModes = const [],
    this.themes = const [],
    this.keywords = const [],
    this.playerPerspectives = const [],
    this.tags = const [],
    this.involvedCompanies = const [],
    this.gameEngines = const [],
    this.websites = const [],
    this.externalGames = const [],
    this.ageRatings = const [],
    this.multiplayerModes = const [],
    this.languageSupports = const [],
    this.gameLocalizations = const [],
    this.mainFranchise,
    this.franchises = const [],
    this.collections = const [],
    this.similarGames = const [],
    this.dlcs = const [],
    this.expansions = const [],
    this.standaloneExpansions = const [],
    this.bundles = const [],
    this.expandedGames = const [],
    this.forks = const [],
    this.ports = const [],
    this.remakes = const [],
    this.remasters = const [],
    this.parentGame,
    this.alternativeNames = const [],
    this.hypes,
    this.isWishlisted = false,
    this.isRecommended = false,
    this.userRating,
    this.isInTopThree = false,
    this.topThreePosition,
  });

  // ===== COMPUTED PROPERTIES =====

  /// Gibt die beste verfügbare Bewertung zurück
  double? get bestRating => totalRating ?? rating ?? aggregatedRating;

  /// Gibt die beste verfügbare Bewertungsanzahl zurück
  int? get bestRatingCount => totalRatingCount ?? ratingCount ?? aggregatedRatingCount;

  /// Prüft ob das Spiel veröffentlicht ist
  bool get isReleased => gameStatus == GameStatus.released;

  /// Prüft ob das Spiel ein Hauptspiel ist
  bool get isMainGame => gameType == GameType.mainGame;

  /// Prüft ob das Spiel DLC/Expansion ist
  bool get isDLC => gameType == GameType.dlcAddon || gameType == GameType.expansion;

  /// Prüft ob das Spiel ein Bundle ist
  bool get isBundle => gameType == GameType.bundle;

  /// Gibt das beste verfügbare Release-Datum zurück
  DateTime? get bestReleaseDate => firstReleaseDate ??
      (releaseDates.isNotEmpty ? releaseDates.first.date : null);

  // ===== MULTIPLAYER PROPERTIES =====

  /// Prüft ob das Spiel Multiplayer-Modi hat
  bool get hasMultiplayer => multiplayerModes.isNotEmpty;

  /// Prüft ob das Spiel Online-Multiplayer unterstützt
  bool get hasOnlineMultiplayer => multiplayerModes.any((mode) =>
  mode.onlineCoop || mode.onlineMax > 1 || mode.splitscreenOnline);

  /// Prüft ob das Spiel lokalen Multiplayer unterstützt
  bool get hasLocalMultiplayer => multiplayerModes.any((mode) =>
  mode.offlineCoop || mode.offlineMax > 1 || mode.splitscreen);

  /// Prüft ob das Spiel Co-op unterstützt
  bool get hasCooperative => multiplayerModes.any((mode) =>
  mode.campaignCoop || mode.onlineCoop || mode.offlineCoop || mode.lancoop);

  /// Prüft ob das Spiel Split-Screen unterstützt
  bool get hasSplitScreen => multiplayerModes.any((mode) =>
  mode.splitscreen || mode.splitscreenOnline);

  /// Maximale Anzahl Online-Spieler
  int get maxOnlinePlayers => multiplayerModes.isEmpty ? 1 :
  multiplayerModes.map((mode) => mode.onlineMax).reduce((a, b) => a > b ? a : b);

  /// Maximale Anzahl Offline-Spieler
  int get maxOfflinePlayers => multiplayerModes.isEmpty ? 1 :
  multiplayerModes.map((mode) => mode.offlineMax).reduce((a, b) => a > b ? a : b);

  // ===== CONTENT & RATING PROPERTIES =====

  /// Gibt die ESRB-Bewertung zurück (falls vorhanden)
  AgeRating? get esrbRating => ageRatings
      .where((rating) => rating.organization == AgeRatingOrganization.esrb)
      .firstOrNull;

  /// Gibt die PEGI-Bewertung zurück (falls vorhanden)
  AgeRating? get pegiRating => ageRatings
      .where((rating) => rating.organization == AgeRatingOrganization.pegi)
      .firstOrNull;

  /// Gibt die USK-Bewertung zurück (falls vorhanden)
  AgeRating? get uskRating => ageRatings
      .where((rating) => rating.organization == AgeRatingOrganization.usk)
      .firstOrNull;

  // ===== STORE & PLATFORM PROPERTIES =====

  /// Gibt alle Steam Store-Links zurück
  List<ExternalGame> get steamStore => externalGames
      .where((game) => game.category == ExternalGameCategory.steam)
      .toList();

  /// Gibt alle Epic Games Store-Links zurück
  List<ExternalGame> get epicStore => externalGames
      .where((game) => game.category == ExternalGameCategory.epicGames)
      .toList();

  /// Gibt alle Social Media Links zurück
  List<Website> get socialMediaLinks => websites.where((website) =>
      [WebsiteCategory.facebook, WebsiteCategory.twitter,
        WebsiteCategory.instagram, WebsiteCategory.youtube,
        WebsiteCategory.twitch, WebsiteCategory.discord].contains(website.category)
  ).toList();

  /// Prüft ob das Spiel auf PC verfügbar ist
  bool get isAvailableOnPC => platforms.any((platform) =>
  platform.name.toLowerCase().contains('pc') ||
      platform.name.toLowerCase().contains('windows'));

  /// Prüft ob das Spiel auf Konsolen verfügbar ist
  bool get isAvailableOnConsoles => platforms.any((platform) =>
  !platform.name.toLowerCase().contains('pc') &&
      !platform.name.toLowerCase().contains('windows'));

  // ===== CONTENT PROPERTIES =====

  /// Prüft ob das Spiel Multiple-Language-Support hat
  bool get hasMultipleLanguages => languageSupports.length > 1;


  /// Gibt alle unterstützten Sprachen als String-Liste zurück
  List<String> get supportedLanguages => languageSupports
      .map((support) => support.languageName)
      .toSet() // Remove duplicates
      .toList();

  // ===== COMPANY & DEVELOPMENT PROPERTIES =====

  /// Gibt alle Entwickler-Unternehmen zurück
  List<InvolvedCompany> get developers => involvedCompanies
      .where((company) => company.isDeveloper)
      .toList();

  /// Gibt alle Publisher-Unternehmen zurück
  List<InvolvedCompany> get publishers => involvedCompanies
      .where((company) => company.isPublisher)
      .toList();

  /// Gibt alle Porting-Unternehmen zurück
  List<InvolvedCompany> get porters => involvedCompanies
      .where((company) => company.isPorting)
      .toList();

  /// Gibt alle Supporting-Unternehmen zurück
  List<InvolvedCompany> get supporters => involvedCompanies
      .where((company) => company.isSupporting)
      .toList();

  /// Gibt Entwickler-Namen als String-Liste zurück
  List<String> get developerNames => developers
      .map((company) => company.company.name)
      .toList();

  /// Gibt Publisher-Namen als String-Liste zurück
  List<String> get publisherNames => publishers
      .map((company) => company.company.name)
      .toList();

  /// Gibt den Haupt-Entwickler zurück (ersten in der Liste)
  InvolvedCompany? get mainDeveloper => developers.isNotEmpty
      ? developers.first
      : null;

  /// Gibt den Haupt-Publisher zurück (ersten in der Liste)
  InvolvedCompany? get mainPublisher => publishers.isNotEmpty
      ? publishers.first
      : null;

  /// Prüft ob das Spiel einen Publisher hat
  bool get hasPublisher => publishers.isNotEmpty;

  /// Prüft ob Developer und Publisher unterschiedlich sind
  bool get hasSeperatePublisher => developers.isNotEmpty &&
      publishers.isNotEmpty &&
      !developers.any((dev) => publishers.any((pub) =>
      dev.company.id == pub.company.id));



  // ===== GAME MODE PROPERTIES =====

  /// Prüft ob das Spiel Single-Player unterstützt
  bool get hasSinglePlayer => gameModes.any((mode) =>
      mode.name.toLowerCase().contains('single'));

  /// Prüft ob das Spiel MMO ist
  bool get isMMO => gameModes.any((mode) =>
      mode.name.toLowerCase().contains('mmo'));

  /// Prüft ob das Spiel Battle Royale ist
  bool get isBattleRoyale => gameModes.any((mode) =>
      mode.name.toLowerCase().contains('battle royale'));

  // ===== CONVENIENCE EXTENSIONS =====

  /// Erste Person Perspektive verfügbar
  bool get hasFirstPersonPerspective => playerPerspectives.any((pp) =>
      pp.name.toLowerCase().contains('first'));

  /// Dritte Person Perspektive verfügbar
  bool get hasThirdPersonPerspective => playerPerspectives.any((pp) =>
      pp.name.toLowerCase().contains('third'));

  /// Top-Down/Isometric Perspektive verfügbar
  bool get hasTopDownPerspective => playerPerspectives.any((pp) =>
  pp.name.toLowerCase().contains('bird') ||
      pp.name.toLowerCase().contains('isometric'));

  // ===== NULLABLE EXTENSIONS =====

  /// Extension für sichere firstOrNull Operation
  T? _firstOrNull<T>(Iterable<T> iterable) {
    try {
      return iterable.first;
    } catch (e) {
      return null;
    }
  }

  /// Erstellt eine Kopie der Game-Instanz mit geänderten Werten
  ///
  /// Alle Parameter sind optional. Wenn ein Parameter nicht angegeben wird,
  /// wird der aktuelle Wert der Instanz verwendet.
  ///
  /// Beispiel:
  /// ```dart
  /// final updatedGame = game.copyWith(
  ///   name: 'Neuer Name',
  ///   totalRating: 95.0,
  ///   isWishlisted: true,
  /// );
  /// ```
  Game copyWith({
    int? id,
    String? name,
    String? summary,
    String? storyline,
    String? slug,
    String? url,
    String? checksum,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalRating,
    int? totalRatingCount,
    double? rating,
    int? ratingCount,
    double? aggregatedRating,
    int? aggregatedRatingCount,
    DateTime? firstReleaseDate,
    List<ReleaseDate>? releaseDates,
    GameStatus? gameStatus,
    GameType? gameType,
    String? versionTitle,
    Game? versionParent,
    String? coverUrl,
    List<String>? screenshots,
    List<String>? artworks,
    List<GameVideo>? videos,
    List<Genre>? genres,
    List<Platform>? platforms,
    List<GameMode>? gameModes,
    List<String>? themes,
    List<Keyword>? keywords,
    List<PlayerPerspective>? playerPerspectives,
    List<int>? tags,
    List<InvolvedCompany>? involvedCompanies,
    List<GameEngine>? gameEngines,
    List<Website>? websites,
    List<ExternalGame>? externalGames,
    List<AgeRating>? ageRatings,
    List<MultiplayerMode>? multiplayerModes,
    List<LanguageSupport>? languageSupports,
    List<GameLocalization>? gameLocalizations,
    Franchise? mainFranchise,
    List<Franchise>? franchises,
    List<Collection>? collections,
    List<Game>? similarGames,
    List<Game>? dlcs,
    List<Game>? expansions,
    List<Game>? standaloneExpansions,
    List<Game>? bundles,
    List<Game>? expandedGames,
    List<Game>? forks,
    List<Game>? ports,
    List<Game>? remakes,
    List<Game>? remasters,
    Game? parentGame,
    List<String>? alternativeNames,
    int? hypes,
    bool? isWishlisted,
    bool? isRecommended,
    double? userRating,
    bool? isInTopThree,
    int? topThreePosition,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      summary: summary ?? this.summary,
      storyline: storyline ?? this.storyline,
      slug: slug ?? this.slug,
      url: url ?? this.url,
      checksum: checksum ?? this.checksum,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalRating: totalRating ?? this.totalRating,
      totalRatingCount: totalRatingCount ?? this.totalRatingCount,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      aggregatedRating: aggregatedRating ?? this.aggregatedRating,
      aggregatedRatingCount: aggregatedRatingCount ?? this.aggregatedRatingCount,
      firstReleaseDate: firstReleaseDate ?? this.firstReleaseDate,
      releaseDates: releaseDates ?? this.releaseDates,
      gameStatus: gameStatus ?? this.gameStatus,
      gameType: gameType ?? this.gameType,
      versionTitle: versionTitle ?? this.versionTitle,
      versionParent: versionParent ?? this.versionParent,
      coverUrl: coverUrl ?? this.coverUrl,
      screenshots: screenshots ?? this.screenshots,
      artworks: artworks ?? this.artworks,
      videos: videos ?? this.videos,
      genres: genres ?? this.genres,
      platforms: platforms ?? this.platforms,
      gameModes: gameModes ?? this.gameModes,
      themes: themes ?? this.themes,
      keywords: keywords ?? this.keywords,
      playerPerspectives: playerPerspectives ?? this.playerPerspectives,
      tags: tags ?? this.tags,
      involvedCompanies: involvedCompanies ?? this.involvedCompanies,
      gameEngines: gameEngines ?? this.gameEngines,
      websites: websites ?? this.websites,
      externalGames: externalGames ?? this.externalGames,
      ageRatings: ageRatings ?? this.ageRatings,
      multiplayerModes: multiplayerModes ?? this.multiplayerModes,
      languageSupports: languageSupports ?? this.languageSupports,
      gameLocalizations: gameLocalizations ?? this.gameLocalizations,
      mainFranchise: mainFranchise ?? this.mainFranchise,
      franchises: franchises ?? this.franchises,
      collections: collections ?? this.collections,
      similarGames: similarGames ?? this.similarGames,
      dlcs: dlcs ?? this.dlcs,
      expansions: expansions ?? this.expansions,
      standaloneExpansions: standaloneExpansions ?? this.standaloneExpansions,
      bundles: bundles ?? this.bundles,
      expandedGames: expandedGames ?? this.expandedGames,
      forks: forks ?? this.forks,
      ports: ports ?? this.ports,
      remakes: remakes ?? this.remakes,
      remasters: remasters ?? this.remasters,
      parentGame: parentGame ?? this.parentGame,
      alternativeNames: alternativeNames ?? this.alternativeNames,
      hypes: hypes ?? this.hypes,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      isRecommended: isRecommended ?? this.isRecommended,
      userRating: userRating ?? this.userRating,
      isInTopThree: isInTopThree ?? this.isInTopThree,
      topThreePosition: topThreePosition ?? this.topThreePosition,
    );
  }

  /// Praktische copyWith-Methoden für häufige Use Cases

  /// Aktualisiert nur User-spezifische Daten
  Game copyWithUserData({
    bool? isWishlisted,
    bool? isRecommended,
    double? userRating,
    bool? isInTopThree,
    int? topThreePosition,
  }) {
    return copyWith(
      isWishlisted: isWishlisted,
      isRecommended: isRecommended,
      userRating: userRating,
      isInTopThree: isInTopThree,
      topThreePosition: topThreePosition,
    );
  }

  /// Aktualisiert nur Bewertungsdaten
  Game copyWithRatings({
    double? totalRating,
    int? totalRatingCount,
    double? rating,
    int? ratingCount,
    double? aggregatedRating,
    int? aggregatedRatingCount,
  }) {
    return copyWith(
      totalRating: totalRating,
      totalRatingCount: totalRatingCount,
      rating: rating,
      ratingCount: ratingCount,
      aggregatedRating: aggregatedRating,
      aggregatedRatingCount: aggregatedRatingCount,
    );
  }

  /// Aktualisiert nur Medien-Daten
  Game copyWithMedia({
    String? coverUrl,
    List<String>? screenshots,
    List<String>? artworks,
    List<GameVideo>? videos,
  }) {
    return copyWith(
      coverUrl: coverUrl,
      screenshots: screenshots,
      artworks: artworks,
      videos: videos,
    );
  }

  @override
  List<Object?> get props => [
    id, name, summary, storyline, slug, url, checksum,
    createdAt, updatedAt, totalRating, totalRatingCount,
    rating, ratingCount, aggregatedRating, aggregatedRatingCount,
    firstReleaseDate, releaseDates, gameStatus, gameType,
    versionTitle, versionParent, coverUrl, screenshots,
    artworks, videos, genres, platforms, gameModes, themes,
    keywords, playerPerspectives, tags, involvedCompanies,
    gameEngines, websites, externalGames, ageRatings,
    multiplayerModes, languageSupports, gameLocalizations,
    mainFranchise, franchises, collections, similarGames,
    dlcs, expansions, standaloneExpansions, bundles,
    expandedGames, forks, ports, remakes, remasters,
    parentGame, alternativeNames, hypes, isWishlisted,
    isRecommended, userRating, isInTopThree, topThreePosition,
  ];
}