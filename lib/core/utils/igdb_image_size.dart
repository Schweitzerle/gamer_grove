/// The IGDB image size ladder.
///
/// The numbers below were **measured against the CDN**, not copied from the
/// docs or from a client library — both are out of date. A cover fetched at
/// `t_1080p` comes back at 811×1080, not 1920×1080, because the alias means
/// "fit inside this box" and a cover is portrait. Getting that wrong is how
/// the memory estimate in the audit ended up more than twice too high.
///
/// Measured 2026-08-06 with `co1wyy` (a portrait cover):
///
/// | alias              | box       | cover comes back as | bytes |
/// |--------------------|-----------|---------------------|-------|
/// | t_thumb            | 90×90     | 90×90 (cropped)     |   3 kB|
/// | t_cover_small      | 90×128    | 90×120              |   4 kB|
/// | t_cover_big        | 264×374   | 264×352             |  21 kB|
/// | t_cover_big_2x     | 528×748   | 528×704             |  70 kB|
/// | t_720p             | 1280×720  | 540×720             |  73 kB|
/// | t_1080p            | 1920×1080 | 811×1080            | 153 kB|
/// | t_screenshot_med   | 569×320   | 555×312             |  43 kB|
/// | t_screenshot_big   | 889×500   | 940×529             | 116 kB|
/// | t_logo_med         | 284×160   | 120×160             |   6 kB|
///
/// Note `t_thumb` **crops to a square** — it is wrong for covers, which is
/// part of why the small end of the ladder was never used.
enum IgdbImageSize {
  /// 90×90, square-cropped. Only for genuinely square art.
  thumb('t_thumb', 90, 90),

  /// Portrait, 90×128 box. Small list rows.
  coverSmall('t_cover_small', 90, 128),

  /// Portrait, 264×374 box. The default for cards on a 1× screen.
  coverBig('t_cover_big', 264, 374),

  /// Portrait, 528×748 box. Cards on a 2× screen.
  coverRetina('t_cover_big_2x', 528, 748),

  /// 1280×720 box. A cover lands at 540×720 — the right size for a card on a
  /// 3× screen, and still modest for a landscape screenshot.
  hd('t_720p', 1280, 720),

  /// 1920×1080 box. Full-screen viewing only.
  fullHd('t_1080p', 1920, 1080),

  /// 569×320 box. Gallery tiles for landscape media.
  screenshotMed('t_screenshot_med', 569, 320),

  /// 889×500 box. Larger gallery tiles.
  screenshotBig('t_screenshot_big', 889, 500),

  /// 284×160 box. Company and engine logos.
  logoMed('t_logo_med', 284, 160);

  const IgdbImageSize(this.alias, this.boxWidth, this.boxHeight);

  /// The `t_…` path segment IGDB expects.
  final String alias;

  /// The bounding box the image is fitted into. The delivered image is at most
  /// this large; it is usually smaller in one axis, because the aspect ratio of
  /// the source is preserved (`thumb` excepted, which crops).
  final int boxWidth;
  final int boxHeight;
}
