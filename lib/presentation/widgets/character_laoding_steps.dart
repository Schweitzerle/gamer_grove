// lib/presentation/widgets/character_loading_steps.dart (add to live_loading_progress.dart)
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'live_loading_progress.dart';

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
