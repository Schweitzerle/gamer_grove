import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/widgets/game_card/card_user_states.dart';

void main() {
  group('backdropHeight covers exactly the badges it stands behind', () {
    // 16 padding, a 32px rating badge, 24px for every other badge, 4px between
    // each pair.
    test('nothing to show needs no scrim', () {
      expect(CardUserStates.none.backdropHeight, 0);
    });

    test('a rating alone', () {
      expect(const CardUserStates(rating: 8.4).backdropHeight, 48);
    });

    test('a single small badge', () {
      expect(const CardUserStates(isWishlisted: true).backdropHeight, 40);
    });

    test('a rating and one badge below it', () {
      expect(
        const CardUserStates(rating: 8.4, isWishlisted: true).backdropHeight,
        76,
      );
    });

    test('everything at once', () {
      const all = CardUserStates(
        rating: 8.4,
        isWishlisted: true,
        isRecommended: true,
        topThreePosition: 1,
      );
      expect(all.backdropHeight, 132);
    });

    test('the rating is not counted twice', () {
      // The regression this guards: the old arithmetic subtracted the rating
      // from its running count and then multiplied by the count it had before
      // subtracting, so a rating-only card carried a scrim 24px too tall — one
      // badge's worth of gradient hanging under the last badge.
      const rating = CardUserStates(rating: 8.4);
      const small = CardUserStates(isWishlisted: true);
      expect(
        rating.backdropHeight - small.backdropHeight,
        32 - 24,
        reason: 'the difference between the two is only their badge sizes',
      );
    });
  });

  group('a top three position carries its own membership', () {
    test('a game outside the top three lends no position', () {
      const game = Game(
        id: 1,
        name: 'Return of the Grove',
        topThreePosition: 2,
      );
      // The flag is what decides, so a stale position must not surface.
      expect(CardUserStates.fromGame(game).topThreePosition, isNull);
    });

    test('a game inside it does', () {
      const game = Game(
        id: 1,
        name: 'Return of the Grove',
        isInTopThree: true,
        topThreePosition: 2,
      );
      expect(CardUserStates.fromGame(game).topThreePosition, 2);
    });
  });

  group('value equality', () {
    // The card asks `buildWhen` whether this game's states changed. With
    // identity equality that answer is always yes and every bloc update
    // repaints every card on screen.
    test('the same states are equal', () {
      expect(
        const CardUserStates(rating: 8.4, isWishlisted: true),
        const CardUserStates(rating: 8.4, isWishlisted: true),
      );
    });

    test('a changed rating is not', () {
      expect(
        const CardUserStates(rating: 8.4),
        isNot(const CardUserStates(rating: 9.1)),
      );
    });

    test('a dropped wishlist is not', () {
      expect(
        const CardUserStates(isWishlisted: true),
        isNot(CardUserStates.none),
      );
    });
  });
}
