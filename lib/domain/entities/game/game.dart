// lib/domain/entities/game.dart (VOLLSTÄNDIG ERWEITERT)
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/artwork.dart';
import 'package:gamer_grove/domain/entities/theme.dart';
import '../character/character.dart';
import '../collection/collection.dart';
import '../event/event.dart';
import '../genre.dart';
import '../language/language_support.dart';
import '../platform/platform.dart';
import '../screenshot.dart';
import '../website/website_type.dart';
import 'game_mode.dart';
import '../involved_company.dart';
import '../website/website.dart';
import 'game_status.dart';
import 'game_time_to_beat.dart';
import 'game_type.dart';
import 'game_video.dart';
import '../ageRating/age_rating.dart';
import 'game_engine.dart';
import '../keyword.dart';
import '../multiplayer_mode.dart';
import '../player_perspective.dart';
import '../franchise.dart';
import '../externalGame/external_game.dart';
import '../releaseDate/release_date.dart';
import 'game_localization.dart';

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

  final int? gameStatusId;
  final int? gameTypeId;
  final GameStatus? gameStatus;
  final GameType? gameType;

  // Time to Beat
  final GameTimeToBeat? timeToBeat;

  // Version Information (for DLCs, expansions, etc.)
  final String? versionTitle;
  final int? versionParentId;
  final Game? versionParent;

  // Popularity Metrics
  final int? hypes;
  final int? follows;

  // Tags (combination of all tag numbers)
  final List<int> tags;

  // Related Games Lists (these should already exist but ensure they're included)
  final List<Game> dlcs;
  final List<Game> expansions;
  final List<Game> standaloneExpansions;
  final List<Game> remakes;
  final List<Game> remasters;
  final List<Game> ports;
  final List<Game> bundles;
  final List<Game> similarGames;
  final List<Game> expandedGames;
  final List<Game> forks;

  // Game Localizations
  final List<GameLocalization> gameLocalizations;

  // Parent/Child Relationships
  final Game? parentGame;
  final List<Game> childGames; // All versions of this game

  // ===== BEWERTUNGEN =====
  final double? totalRating; // Kombinierte Bewertung (User + Kritiker)
  final int? totalRatingCount; // Anzahl kombinierte Bewertungen
  final double? rating; // Nur IGDB User Bewertungen
  final int? ratingCount; // Anzahl IGDB User Bewertungen
  final double? aggregatedRating; // Nur Kritiker Bewertungen
  final int? aggregatedRatingCount; // Anzahl Kritiker Bewertungen

  // ===== RELEASE & STATUS =====
  final DateTime? firstReleaseDate;
  final List<ReleaseDate> releaseDates;

  // ===== MEDIEN =====
  final String? coverUrl;
  final List<Screenshot> screenshots;
  final List<Artwork> artworks;
  final List<GameVideo> videos;

  // ===== KATEGORISIERUNG =====
  final List<Genre> genres;
  final List<Platform> platforms;
  final List<GameMode> gameModes;
  final List<IGDBTheme> themes;
  final List<Keyword> keywords;
  final List<PlayerPerspective> playerPerspectives;

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

  // ===== SERIEN & SAMMLUNGEN =====
  final Franchise? mainFranchise; // Haupt-Franchise (singular)
  final List<Franchise> franchises; // Alle Franchises
  final List<Collection> collections;

  // ===== ALTERNATIVE NAMEN =====
  final List<String> alternativeNames;

  // ===== USER DATEN (nicht von IGDB API) =====
  final bool isWishlisted;
  final bool isRecommended;
  final double? userRating;
  final bool isInTopThree;
  final int? topThreePosition;

  List<Character> characters;
  List<Event> events;

  Game({
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
    this.gameStatusId,
    this.gameTypeId,
    this.gameStatus,
    this.gameType,
    this.timeToBeat,
    this.versionTitle,
    this.versionParentId,
    this.versionParent,
    this.hypes,
    this.follows,
    this.tags = const [],
    this.dlcs = const [],
    this.expansions = const [],
    this.standaloneExpansions = const [],
    this.remakes = const [],
    this.remasters = const [],
    this.ports = const [],
    this.bundles = const [],
    this.similarGames = const [],
    this.expandedGames = const [],
    this.forks = const [],
    this.gameLocalizations = const [],
    this.parentGame,
    this.childGames = const [],
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
    this.involvedCompanies = const [],
    this.gameEngines = const [],
    this.websites = const [],
    this.externalGames = const [],
    this.ageRatings = const [],
    this.multiplayerModes = const [],
    this.languageSupports = const [],
    this.mainFranchise,
    this.franchises = const [],
    this.collections = const [],
    this.alternativeNames = const [],
    this.isWishlisted = false,
    this.isRecommended = false,
    this.userRating,
    this.isInTopThree = false,
    this.topThreePosition,
    this.characters = const [],
    this.events = const [],
  });

  // ===== COMPUTED PROPERTIES =====

  bool get isMainGame => gameType?.id == 0 || gameTypeId == 0;

  bool get isDLC => gameType?.id == 1 || gameTypeId == 1;

  bool get isExpansion => gameType?.id == 2 || gameTypeId == 2;

  bool get isBundle => gameType?.id == 3 || gameTypeId == 3;

  bool get isStandaloneExpansion => gameType?.id == 4 || gameTypeId == 4;

  bool get isMod => gameType?.id == 5 || gameTypeId == 5;

  bool get isEpisode => gameType?.id == 6 || gameTypeId == 6;

  bool get isSeason => gameType?.id == 7 || gameTypeId == 7;

  bool get isRemake => gameType?.id == 8 || gameTypeId == 8;

  bool get isRemaster => gameType?.id == 9 || gameTypeId == 9;

  bool get isReleased => gameStatus?.id == 0 || gameStatusId == 0;

  bool get isAlpha => gameStatus?.id == 2 || gameStatusId == 2;

  bool get isBeta => gameStatus?.id == 3 || gameStatusId == 3;

  bool get isEarlyAccess => gameStatus?.id == 4 || gameStatusId == 4;

  bool get isCancelled => gameStatus?.id == 6 || gameStatusId == 6;

  bool get isRumored => gameStatus?.id == 7 || gameStatusId == 7;

  // Time to beat helpers
  String? get averageTimeToBeat => timeToBeat?.normallyFormatted;

  String? get quickestTimeToBeat => timeToBeat?.hastilyFormatted;

  String? get completionistTimeToBeat => timeToBeat?.completelyFormatted;

  /// Gibt die beste verfügbare Bewertung zurück
  double? get bestRating => totalRating ?? rating ?? aggregatedRating;

  /// Gibt die beste verfügbare Bewertungsanzahl zurück
  int? get bestRatingCount =>
      totalRatingCount ?? ratingCount ?? aggregatedRatingCount;

  /// Gibt das beste verfügbare Release-Datum zurück
  DateTime? get bestReleaseDate =>
      firstReleaseDate ??
      (releaseDates.isNotEmpty ? releaseDates.first.date : null);

  // ===== MULTIPLAYER PROPERTIES =====

  /// Prüft ob das Spiel Multiplayer-Modi hat
  bool get hasMultiplayer => multiplayerModes.isNotEmpty;

  /// Prüft ob das Spiel Online-Multiplayer unterstützt
  bool get hasOnlineMultiplayer => multiplayerModes.any((mode) =>
      mode.onlineCoop || mode.onlineMax > 1 || mode.splitscreenOnline);

  /// Prüft ob das Spiel lokalen Multiplayer unterstützt
  bool get hasLocalMultiplayer => multiplayerModes.any(
      (mode) => mode.offlineCoop || mode.offlineMax > 1 || mode.splitscreen);

  /// Prüft ob das Spiel Co-op unterstützt
  bool get hasCooperative => multiplayerModes.any((mode) =>
      mode.campaignCoop || mode.onlineCoop || mode.offlineCoop || mode.lancoop);

  /// Prüft ob das Spiel Split-Screen unterstützt
  bool get hasSplitScreen => multiplayerModes
      .any((mode) => mode.splitscreen || mode.splitscreenOnline);

  /// Maximale Anzahl Online-Spieler
  int get maxOnlinePlayers => multiplayerModes.isEmpty
      ? 1
      : multiplayerModes
          .map((mode) => mode.onlineMax)
          .reduce((a, b) => a > b ? a : b);

  /// Maximale Anzahl Offline-Spieler
  int get maxOfflinePlayers => multiplayerModes.isEmpty
      ? 1
      : multiplayerModes
          .map((mode) => mode.offlineMax)
          .reduce((a, b) => a > b ? a : b);

  /// Gibt alle Social Media Links zurück
  List<Website> get socialMediaLinks => websites
      .where((website) => [
            WebsiteCategory.facebook,
            WebsiteCategory.twitter,
            WebsiteCategory.instagram,
            WebsiteCategory.youtube,
            WebsiteCategory.twitch,
            WebsiteCategory.discord
          ].contains(website.type))
      .toList();

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
  List<InvolvedCompany> get developers =>
      involvedCompanies.where((company) => company.isDeveloper).toList();

  /// Gibt alle Publisher-Unternehmen zurück
  List<InvolvedCompany> get publishers =>
      involvedCompanies.where((company) => company.isPublisher).toList();

  /// Gibt alle Porting-Unternehmen zurück
  List<InvolvedCompany> get porters =>
      involvedCompanies.where((company) => company.isPorting).toList();

  /// Gibt alle Supporting-Unternehmen zurück
  List<InvolvedCompany> get supporters =>
      involvedCompanies.where((company) => company.isSupporting).toList();

  /// Gibt Entwickler-Namen als String-Liste zurück
  List<String> get developerNames =>
      developers.map((company) => company.company.name).toList();

  /// Gibt Publisher-Namen als String-Liste zurück
  List<String> get publisherNames =>
      publishers.map((company) => company.company.name).toList();

  /// Gibt den Haupt-Entwickler zurück (ersten in der Liste)
  InvolvedCompany? get mainDeveloper =>
      developers.isNotEmpty ? developers.first : null;

  /// Gibt den Haupt-Publisher zurück (ersten in der Liste)
  InvolvedCompany? get mainPublisher =>
      publishers.isNotEmpty ? publishers.first : null;

  /// Prüft ob das Spiel einen Publisher hat
  bool get hasPublisher => publishers.isNotEmpty;

  /// Prüft ob Developer und Publisher unterschiedlich sind
  bool get hasSeperatePublisher =>
      developers.isNotEmpty &&
      publishers.isNotEmpty &&
      !developers.any(
          (dev) => publishers.any((pub) => dev.company.id == pub.company.id));

  // ===== GAME MODE PROPERTIES =====

  /// Prüft ob das Spiel Single-Player unterstützt
  bool get hasSinglePlayer =>
      gameModes.any((mode) => mode.name.toLowerCase().contains('single'));

  /// Prüft ob das Spiel MMO ist
  bool get isMMO =>
      gameModes.any((mode) => mode.name.toLowerCase().contains('mmo'));

  /// Prüft ob das Spiel Battle Royale ist
  bool get isBattleRoyale => gameModes
      .any((mode) => mode.name.toLowerCase().contains('battle royale'));

  // ===== CONVENIENCE EXTENSIONS =====

  /// Erste Person Perspektive verfügbar
  bool get hasFirstPersonPerspective =>
      playerPerspectives.any((pp) => pp.name.toLowerCase().contains('first'));

  /// Dritte Person Perspektive verfügbar
  bool get hasThirdPersonPerspective =>
      playerPerspectives.any((pp) => pp.name.toLowerCase().contains('third'));

  /// Top-Down/Isometric Perspektive verfügbar
  bool get hasTopDownPerspective => playerPerspectives.any((pp) =>
      pp.name.toLowerCase().contains('bird') ||
      pp.name.toLowerCase().contains('isometric'));

  bool get hasEvents => events.isNotEmpty;
  int get eventsCount => events.length;
  bool get hasLiveEvents => events.any((event) => event.isLive);
  bool get hasUpcomingEvents => events.any((event) => event.isUpcoming);

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
    List<Screenshot>? screenshots,
    List<Artwork>? artworks,
    List<GameVideo>? videos,
    List<Genre>? genres,
    List<Platform>? platforms,
    List<GameMode>? gameModes,
    List<IGDBTheme>? themes,
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
    List<Character>? characters,
    List<Event>? events,
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
      aggregatedRatingCount:
          aggregatedRatingCount ?? this.aggregatedRatingCount,
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
      characters: characters ?? this.characters,
      events: events ?? this.events,
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
    List<Screenshot>? screenshots,
    List<Artwork>? artworks,
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
        id,
        name,
        summary,
        storyline,
        slug,
        url,
        checksum,
        createdAt,
        updatedAt,
        totalRating,
        totalRatingCount,
        rating,
        ratingCount,
        aggregatedRating,
        aggregatedRatingCount,
        firstReleaseDate,
        releaseDates,
        coverUrl,
        screenshots,
        artworks,
        videos,
        genres,
        platforms,
        gameModes,
        themes,
        keywords,
        playerPerspectives,
        involvedCompanies,
        gameEngines,
        websites,
        externalGames,
        ageRatings,
        multiplayerModes,
        languageSupports,
        mainFranchise,
        franchises,
        collections,
        alternativeNames,
        isWishlisted,
        isRecommended,
        userRating,
        isInTopThree,
        topThreePosition,
        gameStatusId,
        gameTypeId,
        gameStatus,
        gameType,
        timeToBeat,
        versionTitle,
        versionParentId,
        versionParent,
        hypes,
        follows,
        tags,
        dlcs,
        expansions,
        standaloneExpansions,
        remakes,
        remasters,
        ports,
        bundles,
        similarGames,
        expandedGames,
        forks,
        gameLocalizations,
        parentGame,
        childGames,
        characters,
        events,
      ];
}
