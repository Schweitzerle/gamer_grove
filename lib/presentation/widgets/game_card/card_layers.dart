import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/image_utils.dart';
import 'package:gamer_grove/core/widgets/cached_image_widget.dart';
import 'package:gamer_grove/presentation/widgets/game_card/card_scrim.dart';
import 'package:gamer_grove/presentation/widgets/game_card/card_user_states.dart';

/// The cover, or something to stand in for it.
class CardArtwork extends StatelessWidget {
  const CardArtwork({required this.coverUrl, super.key});

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final url = coverUrl;
    if (url == null || url.isEmpty) return const _MissingArtwork();
    return CachedImageWidget(imageUrl: ImageUtils.getLargeImageUrl(url));
  }
}

class _MissingArtwork extends StatelessWidget {
  const _MissingArtwork();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary.withAlpha(77), primary.withAlpha(153)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.videogame_asset,
          size: 48,
          color: CardScrim.paper.withAlpha(204),
        ),
      ),
    );
  }
}

/// Frosts a cover the reader has already rated, so a wall of played games does
/// not shout as loudly as the ones they have not seen.
class CardBlur extends StatelessWidget {
  const CardBlur({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: CardScrim.paper.withAlpha(51)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: ColoredBox(color: CardScrim.ink.withValues(alpha: 0.1)),
      ),
    );
  }
}

/// Darkens the foot of the cover so the title has something to sit on.
class CardCaptionScrim extends StatelessWidget {
  const CardCaptionScrim({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            CardScrim.ink.withAlpha(179),
            CardScrim.ink.withAlpha(230),
          ],
          stops: const [0.0, 0.6, 0.8, 1.0],
        ),
      ),
    );
  }
}

/// The soft corner behind a column of badges.
///
/// Sized to the badges it stands behind, so a card with one badge does not
/// carry a scrim built for four.
class CardBadgeScrim extends StatelessWidget {
  const CardBadgeScrim({
    required this.states,
    required this.alignment,
    super.key,
  });

  final CardUserStates states;

  /// Which edge the badges run down.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;

    return Positioned(
      top: 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      width: 44,
      height: states.backdropHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: RadialGradient(
            center: isLeft ? Alignment.topLeft : Alignment.topRight,
            radius: 2.8,
            colors: [
              CardScrim.ink.withAlpha(179),
              CardScrim.ink.withAlpha(102),
              CardScrim.ink.withAlpha(26),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
        ),
      ),
    );
  }
}
