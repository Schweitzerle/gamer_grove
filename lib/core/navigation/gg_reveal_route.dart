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
  GGRevealRoute.game({required WidgetBuilder builder, Rect? origin})
      : this._(builder: builder, origin: origin, shape: _RevealShape.card);

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
  })  : _shape = shape,
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
      child: child,
    );
  }
}

class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.animation,
    required this.origin,
    required this.shape,
    required this.child,
  });

  final Animation<double> animation;
  final Rect? origin;
  final _RevealShape shape;
  final Widget child;

  /// Where a reveal starts when the tap had no measurable box.
  static const _fallbackSize = Size(160, 240);

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
      animation: curved,
      // The page is built once and handed through; only the clip changes.
      child: child,
      builder: (context, child) {
        final t = curved.value;
        return ClipPath(
          clipper: _RevealClipper(
            shape: shape,
            from: from,
            to: full,
            t: t,
          ),
          child: Opacity(
            // Fades in over the first stretch, so the page does not appear
            // fully formed inside a shape that is still growing.
            opacity: Curves.easeOut.transform((t * 1.7).clamp(0.0, 1.0)),
            child: child,
          ),
        );
      },
    );
  }
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
