import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';
import 'package:gamer_grove/presentation/widgets/game_card/card_scrim.dart';

/// The dark disc every badge on a cover sits in.
///
/// Without it a coloured icon lands straight on artwork and becomes whatever
/// the cover behind it happens to be.
class _BadgeDisc extends StatelessWidget {
  const _BadgeDisc({
    required this.size,
    required this.borderColour,
    required this.child,
  });

  final double size;
  final Color borderColour;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CardScrim.ink.withValues(alpha: 0.75),
        border: Border.all(color: borderColour),
      ),
      child: child,
    );
  }
}

/// A rating as a ring around the number, coloured by how good it is.
class RatingBadge extends StatelessWidget {
  /// The reader's own rating, stored 0–10 and shown out of 100.
  const RatingBadge.user(double rating, {super.key})
      : _score = rating * 10,
        _size = 32,
        _stroke = 2,
        _icon = Icons.person,
        _iconSize = 10,
        _fontSize = 8,
        _gap = 0;

  /// IGDB's aggregate, already 0–100.
  const RatingBadge.igdb(double score, {super.key})
      : _score = score,
        _size = 44,
        _stroke = 3,
        // A globe, because this number comes from outside the app.
        _icon = Icons.public,
        _iconSize = 12,
        _fontSize = 9,
        _gap = 1;

  final double _score;
  final double _size;
  final double _stroke;
  final IconData _icon;
  final double _iconSize;
  final double _fontSize;
  final double _gap;

  @override
  Widget build(BuildContext context) {
    final colour = ColorScales.getRatingColor(_score);

    return Semantics(
      label: '${_score.toStringAsFixed(0)} out of 100',
      child: ExcludeSemantics(
        child: _BadgeDisc(
          size: _size,
          borderColour: CardScrim.paper.withValues(alpha: 0.3),
          child: Stack(
            children: [
              Positioned.fill(
                child: CircularProgressIndicator(
                  value: _score / 100,
                  strokeWidth: _stroke,
                  backgroundColor: CardScrim.paper.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(colour),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_icon, size: _iconSize, color: CardScrim.paper),
                    if (_gap > 0) SizedBox(height: _gap),
                    Text(
                      _score.toStringAsFixed(0),
                      style: TextStyle(
                        color: CardScrim.paper,
                        fontSize: _fontSize,
                        fontWeight: FontWeight.bold,
                        shadows: CardScrim.textShadow,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A place on someone's top three, in that place's own metal.
class TopThreeBadge extends StatelessWidget {
  const TopThreeBadge(this.position, {super.key});

  final int position;

  @override
  Widget build(BuildContext context) {
    final colour = ColorScales.getTopThreeColor(position);

    return Semantics(
      label: 'Number $position in top three',
      child: ExcludeSemantics(
        child: _BadgeDisc(
          size: 24,
          borderColour: colour.withValues(alpha: 0.8),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, size: 10, color: colour),
                Text(
                  '#$position',
                  style: TextStyle(
                    color: colour,
                    fontSize: 6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One of the plain state badges: on the wishlist, or recommended.
class StateBadge extends StatelessWidget {
  const StateBadge.wishlisted({super.key})
      : _icon = Icons.favorite,
        _colour = Colors.red,
        _label = 'On the wishlist';

  const StateBadge.recommended({super.key})
      : _icon = Icons.thumb_up,
        _colour = Colors.green,
        _label = 'Recommended';

  final IconData _icon;
  final Color _colour;
  final String _label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _label,
      child: ExcludeSemantics(
        child: _BadgeDisc(
          size: 24,
          borderColour: _colour.withValues(alpha: 0.8),
          child: Icon(_icon, size: 12, color: _colour),
        ),
      ),
    );
  }
}
