// lib/presentation/pages/characters/widgets/character_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import '../../../../domain/entities/character/character.dart';

/// A card widget that displays character information with an image,
/// name, and optional metadata like gender, species, and games count.
class CharacterCard extends StatefulWidget {
  final Character character;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool showDescription;
  final bool isSelected;
  final bool showGamesCount;

  const CharacterCard({
    super.key,
    required this.character,
    this.width,
    this.height,
    this.onTap,
    this.showDescription = true,
    this.isSelected = false,
    this.showGamesCount = true,
  });

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        HapticFeedback.lightImpact();
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          _navigateToCharacterDetail(context);
        }
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width ?? 140,
          height: widget.height ?? 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? colorScheme.primary.withOpacity(0.2)
                    : colorScheme.shadow.withOpacity(0.15),
                blurRadius: _isPressed ? 12 : 8,
                offset: const Offset(0, 4),
                spreadRadius: _isPressed ? 1 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                _buildBackgroundImage(context),

                // Gradient Overlay
                _buildGradientOverlay(colorScheme),

                // Games Count Badge (top right)
                if (widget.showGamesCount &&
                    widget.character.loadedGameCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildGamesCountBadge(context),
                  ),

                // Selected Border
                if (widget.isSelected) _buildSelectedBorder(colorScheme),

                // Content Overlay (bottom)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildContentOverlay(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(BuildContext context) {
    if (widget.character.hasImage) {
      return CachedNetworkImage(
        imageUrl: widget.character.largeUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildImagePlaceholder(context),
        errorWidget: (context, url, error) => _buildFallbackBackground(context),
      );
    } else {
      return _buildFallbackBackground(context);
    }
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerHighest,
            colorScheme.surfaceContainerHigh,
          ],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackBackground(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 48,
          color: colorScheme.onPrimaryContainer.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.85),
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildGamesCountBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.videogame_asset_rounded,
            size: 12,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.character.loadedGameCount}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedBorder(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Character Name
          Text(
            widget.character.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 13,
                  letterSpacing: 0.2,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ],
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Character Info (Gender/Species)
          if (widget.character.genderEnum != null ||
              widget.character.speciesEnum != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (widget.character.genderEnum != null) ...[
                  Icon(
                    _getGenderIcon(),
                    size: 10,
                    color: Colors.white.withOpacity(0.85),
                  ),
                  const SizedBox(width: 3),
                ],
                Expanded(
                  child: Text(
                    _getCharacterSubtitle(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getGenderIcon() {
    switch (widget.character.genderEnum) {
      case null:
        return Icons.help_outline;
      default:
        final genderValue = widget.character.genderEnum!.value;
        if (genderValue == 0) return Icons.male_rounded;
        if (genderValue == 1) return Icons.female_rounded;
        return Icons.transgender_rounded;
    }
  }

  String _getCharacterSubtitle() {
    final parts = <String>[];
    if (widget.character.genderEnum != null) {
      parts.add(widget.character.displayGender);
    }
    if (widget.character.speciesEnum != null) {
      parts.add(widget.character.displaySpecies);
    }
    return parts.isNotEmpty ? parts.join(' • ') : 'Character';
  }

  void _navigateToCharacterDetail(BuildContext context) {
    Navigations.navigateToCharacterDetail(context, widget.character.id);
  }
}
