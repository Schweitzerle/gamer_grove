// lib/presentation/pages/characters/widgets/character_card.dart - UPDATED

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/presentation/pages/character/character_detail_page.dart';
import '../../../../domain/entities/character/character.dart';
import '../character_detail_screen.dart';

// 🎨 MODERNE CHARACTER CARD DESIGNS
// Verschiedene stilvolle Varianten zur Auswahl

// ==========================================
// OPTION 1: GRADIENT OVERLAY (Deine Idee)
// ==========================================

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
      onTap: onTap ?? () => _navigateToCharacterDetail(context),
      child: Container(
        width: width ?? 140,
        height: height ?? 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image (full card)
              _buildBackgroundImage(context),

              // Gradient Overlay
              _buildGradientOverlay(),

              // Selected Border
              if (isSelected) _buildSelectedBorder(),

              // Content Overlay (bottom third)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: (height ?? 200) * 0.35, // Bottom 35%
                child: _buildContentOverlay(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(BuildContext context) {
    if (character.hasImage) {
      return CachedNetworkImage(
        imageUrl: character.largeUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildImagePlaceholder(),
        errorWidget: (context, url, error) => _buildFallbackBackground(context),
      );
    } else {
      return _buildFallbackBackground(context);
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.purple,
        ),
      ),
    );
  }

  Widget _buildFallbackBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.purple.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 48,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.0, 0.5, 0.8, 1.0],
        ),
      ),
    );
  }

  Widget _buildSelectedBorder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple,
          width: 3,
        ),
      ),
    );
  }

  Widget _buildContentOverlay(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Character Name
          Text(
            character.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Character Info
          if (character.genderEnum != null || character.speciesEnum != null)
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _getCharacterSubtitle(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _getCharacterSubtitle() {
    final parts = <String>[];
    if (character.genderEnum != null) {
      parts.add(character.displayGender);
    }
    if (character.speciesEnum != null) {
      parts.add(character.displaySpecies);
    }
    return parts.isNotEmpty ? parts.join(' • ') : 'Character';
  }

  void _navigateToCharacterDetail(BuildContext context) {
    Navigations.navigateToCharacterDetail(context, character.id);
  }
}
