import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/website/website.dart';
import 'package:gamer_grove/domain/entities/website/website_type.dart';

Website _website(int id, String type) => Website(
      id: id,
      url: 'https://example.com/$type',
      type: WebsiteType(id: id, checksum: 'c$id', type: type),
    );

void main() {
  group('Game.socialMediaLinks', () {
    // Regression test: previously compared a WebsiteType object against
    // WebsiteCategory enum values, so this getter always returned []. It must
    // now return only the social websites via WebsiteType.isSocialMedia.
    test('returns only social websites and excludes official/store links', () {
      final game = Game(
        id: 1,
        name: 'Test Game',
        websites: [
          _website(1, 'official'),
          _website(2, 'twitter'),
          _website(3, 'youtube'),
          _website(4, 'steam'),
          _website(5, 'discord'),
        ],
      );

      final social = game.socialMediaLinks.map((w) => w.type.type).toList();

      expect(social, ['twitter', 'youtube', 'discord']);
    });

    test('returns empty list when there are no websites', () {
      const game = Game(id: 2, name: 'No Sites');
      expect(game.socialMediaLinks, isEmpty);
    });
  });

  group('Game enrichment immutability', () {
    test('copyWith replaces characters/events without mutating the original',
        () {
      const original = Game(id: 3, name: 'Immutable');
      final enriched = original.copyWith(events: const []);

      // Fields are now final; enrichment goes through copyWith.
      expect(original.events, isEmpty);
      expect(enriched.events, isEmpty);
      expect(identical(original, enriched), isFalse);
    });
  });
}
