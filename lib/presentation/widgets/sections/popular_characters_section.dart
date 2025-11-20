// ==================================================
// POPULAR CHARACTERS SECTION FOR HOME SCREEN
// ==================================================

// lib/presentation/widgets/sections/popular_characters_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/domain/entities/character/character.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/character/character_bloc.dart';
import 'package:gamer_grove/presentation/blocs/character/character_event.dart';
import 'package:gamer_grove/presentation/blocs/character/character_state.dart';
import 'package:gamer_grove/presentation/pages/character/widgets/all_characters_screen.dart';
import 'package:gamer_grove/presentation/pages/character/widgets/character_card.dart';
import 'package:gamer_grove/presentation/widgets/custom_shimmer.dart';

class PopularCharactersSection extends StatefulWidget {
  const PopularCharactersSection({super.key});

  @override
  State<PopularCharactersSection> createState() =>
      _PopularCharactersSectionState();
}

class _PopularCharactersSectionState extends State<PopularCharactersSection> {
  late CharacterBloc _characterBloc;

  @override
  void initState() {
    super.initState();
    _characterBloc = sl<CharacterBloc>();
    _loadCharacters();
  }

  @override
  void dispose() {
    _characterBloc.close();
    super.dispose();
  }

  void _loadCharacters() {
    _characterBloc.add(const GetPopularCharactersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _characterBloc,
      child: BlocBuilder<CharacterBloc, CharacterState>(
        builder: (context, state) {
          if (state is CharacterLoading) {
            return _buildLoadingSection();
          } else if (state is PopularCharactersLoaded) {
            if (state.characters.isEmpty) {
              return const SizedBox.shrink();
            }
            return _buildCharactersSection(state.characters);
          } else if (state is CharacterError) {
            return _buildErrorSection();
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCharactersSection(List<Character> characters) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingSmall,
        ),
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.paddingSmall,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSmall,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Popular Characters',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${characters.length} Characters',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // View All button
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => BlocProvider(
                              create: (_) => sl<CharacterBloc>(),
                              child: const AllCharactersScreen(),
                            ),
                          ),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),

              // Horizontal Character List
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingSmall,
                  ),
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final character = characters[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CharacterCard(
                        character: character,
                        width: 140,
                        height: 200,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingSmall,
        ),
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Loading
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSmall,
                ),
                child: Row(
                  children: [
                    CustomShimmer(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomShimmer(
                            child: Container(
                              height: 20,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          CustomShimmer(
                            child: Container(
                              height: 14,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),

              // Loading Cards
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingSmall,
                  ),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CustomShimmer(
                        child: Container(
                          width: 140,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorSection() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load characters',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadCharacters,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
