import 'package:flutter/foundation.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';

/// What one person has done with a game, as a card shows it.
///
/// The card draws this twice — your own states down the right edge, another
/// user's down the left — so it is worth one type rather than four loose
/// parameters passed to five methods.
///
/// Membership in a top three is carried as the position alone. Keeping both a
/// flag and a nullable position let the two disagree, and the card resolved
/// that disagreement with a `!` that would have thrown.
@immutable
class CardUserStates {
  const CardUserStates({
    this.rating,
    this.isWishlisted = false,
    this.isRecommended = false,
    this.topThreePosition,
  });

  /// The states a game entity is already carrying, for whichever user it was
  /// loaded for. Every call site built this by hand out of the same five
  /// fields.
  factory CardUserStates.fromGame(Game game) => CardUserStates(
        rating: game.userRating,
        isWishlisted: game.isWishlisted,
        isRecommended: game.isRecommended,
        topThreePosition: game.isInTopThree ? game.topThreePosition : null,
      );

  static const none = CardUserStates();

  /// 0–10, as the app stores it. The badge shows it out of 100.
  final double? rating;
  final bool isWishlisted;
  final bool isRecommended;
  final int? topThreePosition;

  bool get isEmpty =>
      rating == null &&
      !isWishlisted &&
      !isRecommended &&
      topThreePosition == null;

  bool get isNotEmpty => !isEmpty;

  /// The badges that will actually be drawn, including the rating.
  int get badgeCount =>
      (rating != null ? 1 : 0) +
      (topThreePosition != null ? 1 : 0) +
      (isWishlisted ? 1 : 0) +
      (isRecommended ? 1 : 0);

  /// Height of the scrim that sits behind the badges.
  ///
  /// The rating badge is larger than the rest, so it is measured separately and
  /// then taken out of the count. The original did the taking-out but still
  /// multiplied by the full count, which made the scrim one badge too tall
  /// whenever a rating was present.
  double get backdropHeight {
    if (badgeCount == 0) return 0;

    const padding = 16.0;
    const ratingSize = 32.0;
    const badgeSize = 24.0;
    const gap = 4.0;

    final small = badgeCount - (rating != null ? 1 : 0);
    var height = padding + (rating != null ? ratingSize : 0);
    height += small * badgeSize;
    // One gap between every pair of badges.
    height += (badgeCount - 1) * gap;
    return height;
  }

  // Value equality is not decoration here: the card's `buildWhen` asks whether
  // this game's states changed, and with identity equality that question is
  // always answered yes — every bloc update would repaint every card.
  @override
  bool operator ==(Object other) =>
      other is CardUserStates &&
      other.rating == rating &&
      other.isWishlisted == isWishlisted &&
      other.isRecommended == isRecommended &&
      other.topThreePosition == topThreePosition;

  @override
  int get hashCode =>
      Object.hash(rating, isWishlisted, isRecommended, topThreePosition);
}
