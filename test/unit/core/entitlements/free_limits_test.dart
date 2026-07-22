import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/entitlements/free_limits.dart';

void main() {
  group('isAtFreeCollectionLimit', () {
    test('free user under the limit may create', () {
      expect(
        isAtFreeCollectionLimit(isPro: false, currentCount: 0),
        isFalse,
      );
      expect(
        isAtFreeCollectionLimit(
          isPro: false,
          currentCount: kFreeCollectionLimit - 1,
        ),
        isFalse,
      );
    });

    test('free user at or over the limit is blocked', () {
      expect(
        isAtFreeCollectionLimit(
          isPro: false,
          currentCount: kFreeCollectionLimit,
        ),
        isTrue,
      );
      expect(
        isAtFreeCollectionLimit(
          isPro: false,
          currentCount: kFreeCollectionLimit + 5,
        ),
        isTrue,
      );
    });

    test('Pro user is never blocked, even past the free limit', () {
      expect(
        isAtFreeCollectionLimit(
          isPro: true,
          currentCount: kFreeCollectionLimit + 100,
        ),
        isFalse,
      );
    });
  });
}
