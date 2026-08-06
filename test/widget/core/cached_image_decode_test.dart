import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/utils/igdb_image_size.dart';
import 'package:gamer_grove/core/utils/image_utils.dart';
import 'package:gamer_grove/core/widgets/cached_image_widget.dart';

/// The decode size is the whole point of #169, and it is invisible: an image
/// decoded at 1080p looks identical to one decoded at 480px on a card. Nothing
/// in a screenshot or a golden would ever catch a regression here, so these
/// tests read the value off the widget.
void main() {
  const url = 'https://images.igdb.com/igdb/image/upload/t_720p/abc.jpg';

  /// Pumps the widget inside a box of the given size at the given pixel ratio
  /// and returns the CachedNetworkImage it built.
  ///
  /// No network call happens: CachedNetworkImage builds its placeholder first,
  /// and the test never pumps far enough for the (failing) request to matter.
  Future<CachedNetworkImage> pump(
    WidgetTester tester, {
    required Size box,
    double ratio = 3,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(devicePixelRatio: ratio),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: box.width,
              height: box.height,
              child: CachedImageWidget(
                imageUrl: url,
                width: width,
                height: height,
                fit: fit,
              ),
            ),
          ),
        ),
      ),
    );
    return tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
  }

  group('decode size', () {
    testWidgets('comes from the box when the caller sizes nothing',
        (tester) async {
      // The cover in every game card: 160×240 logical, no width/height passed.
      // The box is taller than wide, so the height is what has to be covered.
      final image = await pump(tester, box: const Size(160, 240));

      expect(image.memCacheHeight, 720, reason: '240 logical × 3 dpr');
      expect(
        image.memCacheWidth,
        isNull,
        reason: 'setting both axes makes ResizeImage distort the bitmap',
      );
    });

    testWidgets('follows the device pixel ratio', (tester) async {
      final image = await pump(tester, box: const Size(160, 240), ratio: 2);
      expect(image.memCacheHeight, 480);
    });

    testWidgets('takes the width when the box is the wider way round',
        (tester) async {
      // A hero banner. Constraining the short side would leave a wide image
      // upscaled across the screen.
      final image = await pump(tester, box: const Size(400, 250));
      expect(image.memCacheWidth, 1200);
      expect(image.memCacheHeight, isNull);
    });

    testWidgets('uses the height when that is the axis the caller named',
        (tester) async {
      // An age-rating logo: height 120, BoxFit.contain, in a wide row. Taking
      // the row's width would decode several times more than it draws.
      final image = await pump(
        tester,
        box: const Size(400, 200),
        height: 120,
        fit: BoxFit.contain,
      );

      expect(image.memCacheHeight, 360);
      expect(image.memCacheWidth, isNull);
    });

    testWidgets('ignores an infinite width and falls back to the box',
        (tester) async {
      // `width: double.infinity` is a layout instruction, not a size — passing
      // it to the codec throws.
      final image = await pump(
        tester,
        box: const Size(300, 200),
        width: double.infinity,
      );

      expect(image.memCacheWidth, 900, reason: 'the box, 300 × 3');
      expect(image.memCacheHeight, isNull);
    });

    testWidgets('never asks for more than IGDB serves', (tester) async {
      // A full-bleed hero on a tablet at 3× would compute past 1920.
      final image = await pump(tester, box: const Size(1024, 768));
      expect(image.memCacheWidth, 1920);
      expect(image.memCacheHeight, isNull);
    });

    testWidgets('leaves an unmeasurable box alone', (tester) async {
      // Unbounded on both axes: no target is better than a wrong one.
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: UnconstrainedBox(
              child: CachedImageWidget(imageUrl: url),
            ),
          ),
        ),
      );

      final image =
          tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
      expect(image.memCacheWidth, isNull);
      expect(image.memCacheHeight, isNull);
    });
  });

  group('the IGDB size ladder', () {
    const raw = '//images.igdb.com/igdb/image/upload/t_thumb/co1wyy.jpg';

    test('replaces whatever size the API happened to hand over', () {
      expect(
        ImageUtils.buildIgdbImageUrl(raw, size: IgdbImageSize.hd),
        'https://images.igdb.com/igdb/image/upload/t_720p/co1wyy.jpg',
      );
    });

    test('a card cover asks for 720p, not 1080p', () {
      // A card draws 160×240; t_720p fits a portrait cover to 540×720, which is
      // already above what a 3× phone can show, at less than half the bytes.
      expect(ImageUtils.getCardCoverUrl(raw), contains('/t_720p/'));
    });

    test('full-screen viewing is the only place 1080p belongs', () {
      expect(ImageUtils.getLargeImageUrl(raw), contains('/t_1080p/'));
    });

    test('the small step is a portrait cover, not the square thumb', () {
      // t_thumb crops to 90×90. Used on a cover it cuts the artwork.
      expect(ImageUtils.getSmallImageUrl(raw), contains('/t_cover_small/'));
      expect(IgdbImageSize.thumb.boxWidth, IgdbImageSize.thumb.boxHeight);
    });

    test('protocol-relative and bare URLs both come back absolute', () {
      expect(ImageUtils.getCardCoverUrl(raw), startsWith('https://'));
      expect(
        ImageUtils.getCardCoverUrl('images.igdb.com/a/t_thumb/b.jpg'),
        startsWith('https://'),
      );
    });

    test('an empty URL stays empty rather than becoming "https://"', () {
      expect(ImageUtils.getCardCoverUrl(null), '');
      expect(ImageUtils.getCardCoverUrl(''), '');
    });
  });
}
