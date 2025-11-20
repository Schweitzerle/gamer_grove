// lib/presentation/widgets/sections/characters_section.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/domain/entities/character/character.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/pages/character/character_screen.dart';
import 'package:gamer_grove/presentation/pages/character/widgets/character_card.dart';

class CharactersSection extends StatelessWidget {

  const CharactersSection({
    required this.game, super.key,
  });
  final Game game;

  @override
  Widget build(BuildContext context) {
    final characters = game.characters;

    if (characters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingMedium,
      ),
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, characters),
            _buildCharactersPreview(context, characters),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, List<Character> characters) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.people_outline,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Characters',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${characters.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          if (characters.length > 4)
            TextButton.icon(
              onPressed: () => _navigateToCharactersScreen(context, characters),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('View All'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.purple,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCharactersPreview(
      BuildContext context, List<Character> characters,) {
    // Show first 4 characters in a horizontal scroll
    final previewCharacters = characters.take(4).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.only(
        bottom: AppConstants.paddingMedium,
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: previewCharacters.length,
              padding: const EdgeInsets.only(
                left: AppConstants.paddingMedium,
              ),
              itemBuilder: (context, index) {
                final character = previewCharacters[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    right: AppConstants.paddingMedium,
                  ),
                  child: CharacterCard(
                    character: character,
                    width: 120,
                    onTap: () => _navigateToCharacterDetail(context, character),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCharacterDetail(BuildContext context, Character character) {
    Navigations.navigateToCharacterDetail(context, character.id);
  }

  void _navigateToCharactersScreen(
    BuildContext context,
    List<Character> characters, {
    Character? initialCharacter,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CharactersScreen(
          characters: characters,
          gameTitle: game.name,
          initialCharacter: initialCharacter,
        ),
      ),
    );
  }
}
