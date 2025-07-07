// lib/presentation/pages/characters/widgets/character_card.dart - UPDATED

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../domain/entities/character/character.dart';
import '../character_detail_screen.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool showDescription;
  final bool isSelected;

  const CharacterCard({
    super.key,
    required this.character,
    this.width,
    this.height,
    this.onTap,
    this.showDescription = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 🆕 UPDATED: Navigate to CharacterDetailScreen or use custom onTap
      onTap: onTap ?? () => _navigateToCharacterDetail(context),
      child: Container(
        width: width ?? 140,
        height: height,
        child: Card(
          elevation: isSelected ? 6 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide(color: Colors.purple, width: 2)
                : BorderSide.none,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCharacterImage(context),
              if (showDescription)
                Expanded(
                  child: _buildCharacterInfo(context),
                )
              else
                _buildCharacterInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterImage(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Container(
        height: showDescription ? 100 : 120,
        width: double.infinity,
        child: character.hasImage
            ? CachedNetworkImage(
          imageUrl: character.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade300,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.purple,
              ),
            ),
          ),
          errorWidget: (context, url, error) => _buildFallbackImage(context),
        )
            : _buildFallbackImage(context),
      ),
    );
  }

  Widget _buildFallbackImage(BuildContext context) {
    return Container(
      color: Colors.purple.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.person,
          size: showDescription ? 32 : 40,
          color: Colors.purple.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildCharacterInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            character.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (showDescription && character.description != null) ...[
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                character.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          // 🆕 NEW: Show character identity info if no description
          if (!showDescription || character.description == null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (character.genderEnum != null) ...[
                  Icon(
                    Icons.person_outline,
                    size: 12,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      character.displayGender,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 🆕 NEW: Navigation method - goes directly to CharacterDetailScreen
  void _navigateToCharacterDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CharacterDetailScreen(
          character: character,
          // Pass the games if character already has them loaded
          characterGames: character.hasLoadedGames ? character.games : null,
        ),
      ),
    );
  }
}