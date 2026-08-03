import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/presentation/widgets/loading/loading_step.dart';

// Predefined step sequences, one per kind of detail screen. Moved out of
// live_loading_progress.dart so that file is the widget and this one is the
// copy — they change for entirely different reasons.
class EventLoadingSteps {
  static List<LoadingStep> eventDetails(BuildContext context) => [
        LoadingStep(
          text: 'Initializing event loader...',
          substep: 'Setting up data sources',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Fetching event details from IGDB...',
          substep: 'Retrieving event metadata',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        LoadingStep(
          text: 'Loading featured games...',
          substep: 'Processing game collections',
          color: Theme.of(context).colorScheme.primary,
        ),
        LoadingStep(
          text: 'Enriching event data...',
          substep: 'Fetching networks and media',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Finalizing event details...',
          substep: 'Preparing UI components',
          color: Theme.of(context).colorScheme.primary,
        ),
      ];

  /// The steps for a game the app already knows something about.
  ///
  /// The generic list said "Connecting to game database…" — true of every game
  /// and therefore about none of them. The card that was tapped already carries
  /// the name, the genres and often the studio, so the wait can name what it is
  /// waiting for. It is the same information the page is about to show, said
  /// while it is still on its way.
  static List<LoadingStep> forGame(BuildContext context, Game game) {
    final scheme = Theme.of(context).colorScheme;
    final genre = game.genres.isEmpty ? null : game.genres.first.name;
    final studio =
        game.developers.isEmpty ? null : game.developers.first.company.name;

    return [
      LoadingStep(
        text: 'Opening ${game.name}',
        substep: genre == null ? null : 'A $genre game',
        color: scheme.primary,
      ),
      LoadingStep(
        text: studio == null ? 'Finding who made it' : 'Made by $studio',
        substep: 'Studios, platforms, release',
        color: scheme.secondary,
      ),
      LoadingStep(
        text: 'Gathering screenshots and video',
        color: scheme.tertiary,
      ),
      LoadingStep(
        text: genre == null
            ? 'Looking for related games'
            : 'Looking for more $genre',
        substep: 'DLC, versions, similar games',
        color: scheme.primary,
      ),
    ];
  }

  static List<LoadingStep> gameDetails(BuildContext context) => [
        LoadingStep(
          text: 'Connecting to game database...',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Fetching game information...',
          substep: 'Loading metadata and screenshots',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        LoadingStep(
          text: 'Processing user data...',
          substep: 'Checking ratings and collections',
          color: Theme.of(context).colorScheme.primary,
        ),
        LoadingStep(
          text: 'Loading related content...',
          substep: 'Franchises, DLCs, and similar games',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Finalizing game details...',
          color: Theme.of(context).colorScheme.primary,
        ),
      ];
}

class CharacterLoadingSteps {
  static List<LoadingStep> characterDetails(BuildContext context) => [
        LoadingStep(
          text: 'Connecting to character database...',
          substep: 'Initializing IGDB connection',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Fetching character profile...',
          substep: 'Loading character metadata and images',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        LoadingStep(
          text: 'Processing character games...',
          substep: 'Retrieving games featuring this character',
          color: Theme.of(context).colorScheme.primary,
        ),
        LoadingStep(
          text: 'Enriching character data...',
          substep: 'Loading additional character information',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Finalizing character details...',
          substep: 'Preparing character profile display',
          color: Theme.of(context).colorScheme.primary,
        ),
      ];
}

class PlatformLoadingSteps {
  static List<LoadingStep> platformDetails(BuildContext context) => [
        LoadingStep(
          text: 'Connecting to platform database...',
          substep: 'Initializing IGDB connection',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Fetching platform profile...',
          substep: 'Loading platform metadata',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        LoadingStep(
          text: 'Processing platform games...',
          substep: 'Retrieving games published on this platform',
          color: Theme.of(context).colorScheme.primary,
        ),
        LoadingStep(
          text: 'Enriching platform data...',
          substep: 'Loading additional platform information',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Finalizing platform details...',
          substep: 'Preparing platform profile display',
          color: Theme.of(context).colorScheme.primary,
        ),
      ];
}

class GameEngineLoadingSteps {
  static List<LoadingStep> gameEngineDetails(BuildContext context) => [
        LoadingStep(
          text: 'Connecting to game engine database...',
          substep: 'Initializing IGDB connection',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Fetching game engine profile...',
          substep: 'Loading game engine metadata',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        LoadingStep(
          text: 'Processing game engine games...',
          substep: 'Retrieving games published on this game engine',
          color: Theme.of(context).colorScheme.primary,
        ),
        LoadingStep(
          text: 'Enriching game engine data...',
          substep: 'Loading additional game engine information',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Finalizing game engine details...',
          substep: 'Preparing game engine profile display',
          color: Theme.of(context).colorScheme.primary,
        ),
      ];
}

class CompanyLoadingSteps {
  static List<LoadingStep> companyDetails(BuildContext context) => [
        LoadingStep(
          text: 'Connecting to company database...',
          substep: 'Initializing IGDB connection',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Fetching company profile...',
          substep: 'Loading company metadata and logo',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        LoadingStep(
          text: 'Processing developed games...',
          substep: 'Retrieving games developed by this company',
          color: Theme.of(context).colorScheme.primary,
        ),
        LoadingStep(
          text: 'Processing published games...',
          substep: 'Retrieving games published by this company',
          color: Theme.of(context).colorScheme.primary,
        ),
        LoadingStep(
          text: 'Enriching company data...',
          substep: 'Loading parent company and websites',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Finalizing company details...',
          substep: 'Preparing company profile display',
          color: Theme.of(context).colorScheme.primary,
        ),
      ];
}
