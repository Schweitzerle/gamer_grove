import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';

/// What shape a page is revealed through.
enum _RevealShape {
  /// The tapped cover's own rectangle, opening out into the page.
  card,

  /// The doorway from the app icon — straight sides, a semicircular head.
  arch,
}

/// A page revealed through a shape that grows from where you tapped.
///
/// Two meanings, one mechanism. A game opens by its cover's rectangle growing
/// into the page, because the only question the transition can answer is
/// *which* game. Someone else's grove opens through the doorway, because there
/// is no cover there — a person, not a game — and the shape says what kind of
/// place you are entering before the page has loaded.
///
/// **Why not `Hero`.** The detail page has carried `Hero(tag: 'game_cover_…')`
/// since long before this, with no partner anywhere, so it never flew. Reviving
/// it was the obvious move and it is the wrong one: Flutter requires hero tags
/// to be unique inside a route subtree — `heroes.dart` throws "There are
/// multiple heroes that share the same tag within a subtree" while setting up
/// the flight. The Grove shows twelve rows at once, and a wishlisted game that
/// is also popular stands in two of them. The flight would throw on exactly the
/// games people care most about. A route carrying the source rectangle needs
/// nothing to be unique.
class GGRevealRoute<T> extends PageRouteBuilder<T> {
  /// Opening a game.
  ///
  /// [focus] is the point of the arriving page that should be standing behind
  /// the aperture when it opens — for a game, the middle of its cover.
  GGRevealRoute.game({
    required WidgetBuilder builder,
    Rect? origin,
    double focus = _Reveal.heroFocus,
  }) : this._(
          builder: builder,
          origin: origin,
          shape: _RevealShape.card,
          focus: focus,
        );

  /// Entering someone else's grove.
  ///
  /// Takes no origin: the doorway stands on the ground rather than growing out
  /// of the row you tapped, so there is nothing for a source rectangle to say.
  GGRevealRoute.grove({required WidgetBuilder builder})
      : this._(builder: builder, origin: null, shape: _RevealShape.arch);

  GGRevealRoute._({
    required WidgetBuilder builder,
    required this.origin,
    required _RevealShape shape,
    double focus = _Reveal.heroFocus,
  })  : _shape = shape,
        _focus = focus,
        super(
          pageBuilder: (context, _, __) => builder(context),
          transitionDuration: forward,
          reverseTransitionDuration: back,
        );

  /// How long the reveal takes on the way in.
  ///
  /// Not `durationNormal`. That token is 250ms and it is right for the small
  /// moves it was made for, but a shape crossing the whole screen needs longer
  /// to be seen at all — measured against the curve below, 250ms put 91% of the
  /// motion into the first 100ms, and it was reported as "no animation".
  static const forward = Duration(milliseconds: 350);

  /// And on the way back, because returning is not news.
  static const back = Duration(milliseconds: 200);

  /// Where on screen the tap came from, in global coordinates.
  ///
  /// Null when the caller could not say — the reveal then grows from the middle
  /// rather than refusing to run.
  final Rect? origin;

  final _RevealShape _shape;
  final double _focus;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Asked for less motion, the page is simply there. Same answer the portal
    // loader and the chamber tint give.
    if (MediaQuery.disableAnimationsOf(context)) return child;

    return _Reveal(
      animation: animation,
      origin: origin,
      shape: _shape,
      focus: _focus,
      child: child,
    );
  }
}

class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.animation,
    required this.origin,
    required this.shape,
    required this.focus,
    required this.child,
  });

  final Animation<double> animation;
  final Rect? origin;
  final _RevealShape shape;

  /// How far down the arriving page the thing worth seeing sits.
  final double focus;

  final Widget child;

  /// The middle of a game page's cover, measured from the top of the page.
  ///
  /// Half of the detail hero's expanded height.
  static const heroFocus = 175.0;

  /// Where a reveal starts when the tap had no measurable box.
  static const _fallbackSize = Size(160, 240);

  /// How far back the arriving page starts, before it comes forward.
  ///
  /// Walking into a room is not only a change of colour, it is a change of
  /// distance: what is beyond the doorway grows as you approach it. So the page
  /// arrives slightly away from you and closes that gap as the shape opens.
  ///
  /// Scaled about the point that was tapped, not about the middle of the
  /// screen. Around the middle, a shape opening near an edge would show a gap
  /// where the page has not reached yet — the clip would be wider there than
  /// the content behind it. Anchored at the tap, both grow from the same place
  /// and there is nothing to expose.
  static const _startsAt = 0.88;

  /// How deep in the shadow the arriving page starts.
  ///
  /// Of the three ways offered to give the reveal colour, this is the one that
  /// does not add a second idea. Depth and light are not two effects in a cave,
  /// they are one: what is further away is darker, and it brightens as you
  /// reach it. So the page arrives in shadow and comes into the light at the
  /// same rate it comes forward.
  ///
  /// A veil in the scrim colour rather than an `Opacity`, for the same reason
  /// `LitSection` uses one: opacity forces an offscreen layer every frame, and
  /// "still in the dark" is the truer description anyway.
  static const _shadow = 0.45;

  /// How much of the screen an origin may already cover and still be worth
  /// growing from.
  ///
  /// A measurement that returns most of the screen — a whole section rather
  /// than the card inside it — leaves nothing to grow: the reveal starts at
  /// almost full size and ends at full size, which reads as no transition at
  /// all. Where the tap was is still worth keeping; how big it claimed to be
  /// is not.
  static const _maxOriginArea = 0.5;

  /// [candidate] if it is small enough to open out of, otherwise a card-sized
  /// rectangle in the same place.
  static Rect _usable(Rect candidate, Rect full) {
    final area = candidate.width * candidate.height;
    if (area <= full.width * full.height * _maxOriginArea) return candidate;
    return Rect.fromCenter(
      center: candidate.center,
      width: _fallbackSize.width,
      height: _fallbackSize.height,
    );
  }

  /// [point] as an [Alignment] within a box of [size], so a transform can be
  /// anchored where the finger was.
  static Alignment _anchor(Offset point, Size size) {
    if (size.isEmpty) return Alignment.center;
    return Alignment(
      (point.dx / size.width * 2 - 1).clamp(-1.0, 1.0),
      (point.dy / size.height * 2 - 1).clamp(-1.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final full = Offset.zero & size;
    final measured = origin;
    final from = measured == null
        ? Rect.fromCenter(
            center: full.center,
            width: _fallbackSize.width,
            height: _fallbackSize.height,
          )
        : _usable(measured, full);

    // Two curves, because the aperture and what is behind it are not doing the
    // same job. Run together they open at the same rate, and the opening is
    // already 38% of the way across the screen after 50ms — never small enough
    // to be an aperture at all, which is why it read as "the whole screen gets
    // bigger". The shape now holds nearly shut while the cover moves and
    // grows behind it, then opens out at the end.
    final aperture = CurvedAnimation(
      parent: animation,
      // 9% open at 100ms, 60% at 200ms, 97% at 300ms.
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final curved = CurvedAnimation(
      parent: animation,
      // Decelerating, not emphasised. Material's emphasised curve reaches 63%
      // of its motion in the first 50ms and 91% in 100ms — the reveal was
      // effectively over before it could be perceived, whatever the duration
      // said. This one answers the tap immediately and then spends the rest of
      // the time somewhere you can watch it: 38% at 50ms, 66% at 100ms, 82% at
      // 150ms.
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return AnimatedBuilder(
      animation: animation,
      // The page is built once and handed through; only the clip changes.
      child: child,
      builder: (context, child) {
        final t = curved.value;
        final clipper = _RevealClipper(
          shape: shape,
          from: from,
          to: full,
          t: aperture.value,
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(
              clipper: clipper,
              // The aperture opens where the finger was; the cover sits at the top
              // of the page. Without this the small opening shows whatever happens
              // to be in the middle of the arriving page — placeholders — and the
              // reveal has nothing to reveal. So the page arrives shifted, with its
              // cover standing behind the aperture, and slides into place as the
              // shape opens.
              child: Transform.translate(
                // Tracks the aperture, not the content curve. The cover has to be
                // *behind the opening* the whole way, and the two curves differ by
                // design — driving this from the faster one moved the cover up and
                // out of the shape while the shape was still small, leaving an
                // aperture with nothing but dark page in it.
                offset: Offset(
                      from.center.dx - size.width / 2,
                      from.center.dy - focus,
                    ) *
                    (1 - aperture.value),
                child: Transform.scale(
                  scale: lerpDouble(_startsAt, 1, t),
                  alignment: _anchor(from.center, size),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(
                        // Fades in over the first stretch, so the page does not
                        // appear fully formed inside a shape that is still growing.
                        opacity:
                            Curves.easeOut.transform((t * 1.7).clamp(0.0, 1.0)),
                        child: child,
                      ),
                      IgnorePointer(
                        child: ColoredBox(
                          color: Theme.of(context)
                              .colorScheme
                              .scrim
                              .withValues(alpha: _shadow * (1 - t)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // The opening needs an edge, or it is not an opening.
            //
            // Measured rather than assumed: the page is shifted so the cover
            // stands behind the aperture, which means the window and its
            // content are the same rectangle — outside it the Grove is
            // near-black, and inside it, beyond the cover, so is the arriving
            // page. The only visible boundary was the cover's own, so what a
            // tester saw was a cover growing, never a window opening. A rim of
            // the app's own light gives the shape a border it can be seen by:
            // 5.5:1 against the cave, 3.5:1 on paper.
            IgnorePointer(
              child: CustomPaint(
                painter: _ApertureRim(
                  clipper: clipper,
                  colour: Theme.of(context).colorScheme.primary,
                  // Brightest while the opening is small, gone once it has
                  // reached the edges — a rim around the whole screen would
                  // just be a frame.
                  strength: 1 - Curves.easeIn.transform(aperture.value),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The lit edge of the opening.
class _ApertureRim extends CustomPainter {
  const _ApertureRim({
    required this.clipper,
    required this.colour,
    required this.strength,
  });

  final CustomClipper<Path> clipper;
  final Color colour;
  final double strength;

  /// Thickness at full strength, in logical pixels.
  static const _width = 2.5;

  /// Peak opacity, from the contrast measurement.
  static const _peak = 0.8;

  @override
  void paint(Canvas canvas, Size size) {
    if (strength <= 0.02 || size.isEmpty) return;
    canvas.drawPath(
      clipper.getClip(size),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _width
        ..color = colour.withValues(alpha: _peak * strength),
    );
  }

  @override
  bool shouldRepaint(_ApertureRim oldDelegate) =>
      oldDelegate.strength != strength || oldDelegate.colour != colour;
}

class _RevealClipper extends CustomClipper<Path> {
  const _RevealClipper({
    required this.shape,
    required this.from,
    required this.to,
    required this.t,
  });

  final _RevealShape shape;
  final Rect from;
  final Rect to;
  final double t;

  @override
  Path getClip(Size size) {
    if (t >= 1) return Path()..addRect(Offset.zero & size);

    return switch (shape) {
      _RevealShape.card => _card(),
      _RevealShape.arch => _arch(size),
    };
  }

  /// The tapped cover's rectangle, opening out and losing its corners.
  Path _card() {
    final rect = Rect.lerp(from, to, t)!;
    final radius = lerpDouble(GGTokens.standard.radiusLg, 0, t)!;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
  }

  /// The doorway from the icon: straight sides, a semicircular head.
  ///
  /// Same construction as `PortalLoader`'s painter, so the two read as the same
  /// shape rather than as two arches that happen to look alike.
  Path _arch(Size size) {
    // The doorway stands on the ground, as it does in the icon and in the
    // loader — not where the finger happened to land. A row in a list of people
    // is not a thing you walk into; the threshold is.
    final centre = Offset(size.width / 2, size.height);
    // The half-width that just covers the screen from where the tap was.
    //
    // Computed rather than guessed at: an over-generous reach makes the arch
    // fill the screen a third of the way through, and then the shape nobody
    // sees is the whole point of the variant. Four constraints have to hold at
    // the end — both sides, the foot, and the head, the latter two through the
    // arch's own 1.15 height ratio.
    final needed = [
      centre.dx,
      size.width - centre.dx,
      (size.height - centre.dy) / 1.15,
      centre.dy / 1.15,
    ].reduce((a, b) => a > b ? a : b);

    // Starts shut rather than at some rectangle's width: a door opens from
    // nothing.
    final width = lerpDouble(0, needed * 2, t)!;
    final height = width * 1.15;

    final r = width / 2;
    final left = centre.dx - r;
    final right = centre.dx + r;
    final bottom = centre.dy + height / 2;
    final shoulder = (centre.dy - height / 2 + r).clamp(-height, bottom);

    return Path()
      ..moveTo(left, bottom)
      ..lineTo(left, shoulder)
      ..arcToPoint(Offset(right, shoulder), radius: Radius.circular(r))
      ..lineTo(right, bottom)
      ..close();
  }

  @override
  bool shouldReclip(_RevealClipper oldClipper) =>
      oldClipper.t != t ||
      oldClipper.from != from ||
      oldClipper.to != to ||
      oldClipper.shape != shape;
}

/// The global rectangle [context] occupies, for a reveal to grow from.
///
/// Returns null rather than guessing when the context has no box — the route
/// then falls back to the middle of the screen.
Rect? revealOriginOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

/// Where the tap that is about to navigate came from.
///
/// Navigation helpers take whatever `BuildContext` the caller has, and inside a
/// `ListView.builder` that is the **sliver's** context, not the item's: its
/// render object is a `RenderSliver`, so measuring it yields nothing and every
/// reveal fell back to growing out of the middle of the screen. Only the tapped
/// widget knows its own box, so it puts it here on the way into the callback.
abstract final class RevealOrigin {
  static Rect? _pending;

  /// Records the box [context] occupies, for the navigation this tap triggers.
  static void record(BuildContext context) {
    _pending = revealOriginOf(context);
  }

  /// The recorded rectangle, cleared as it is read.
  ///
  /// Clearing matters: without it a later navigation from somewhere that cannot
  /// be measured would inherit a stale rectangle and open out of whatever was
  /// tapped last, which looks worse than growing from the middle.
  static Rect? take() {
    final rect = _pending;
    _pending = null;
    return rect;
  }

  @visibleForTesting
  static void clear() => _pending = null;
}
