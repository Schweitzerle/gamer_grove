import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_dither.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';
import 'package:gamer_grove/core/utils/image_utils.dart';
import 'package:gamer_grove/core/widgets/cached_image_widget.dart';

/// The cover of the thing being fetched, small, with the light passing over it.
///
/// The card says a game is loading; this says *which* game. The pass of light
/// is the same one the Top 3 uses when a cover comes to the front
/// ([LightSweepPainter]) — there it means "this one has arrived", here it means
/// "this one is on its way", and reusing it keeps the app down to one idea
/// about what light does.
///
/// The live dot sits on the cover rather than beside it, so the two together
/// read as one thing that is working.
class LoadingThumbnail extends StatefulWidget {
  const LoadingThumbnail({
    required this.coverUrl,
    required this.label,
    super.key,
    this.height = 52,
  });

  /// IGDB cover url, or null when the caller has none.
  final String? coverUrl;

  /// What the cover is of — read out instead of the image itself.
  final String label;

  final double height;

  /// One pass, and a rest before the next. Slower than the coin so the two do
  /// not beat against each other.
  static const sweep = Duration(milliseconds: 2200);

  @override
  State<LoadingThumbnail> createState() => _LoadingThumbnailState();
}

class _LoadingThumbnailState extends State<LoadingThumbnail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pass = AnimationController(
    vsync: this,
    duration: LoadingThumbnail.sweep,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pass.stop();
    } else if (!_pass.isAnimating) {
      unawaited(_pass.repeat());
    }
  }

  @override
  void dispose() {
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.ggTokens;
    final width = widget.height * _aspect;
    final url = widget.coverUrl;

    return Semantics(
      label: widget.label,
      image: true,
      child: SizedBox(
        width: width + tokens.spaceSm,
        height: widget.height + tokens.spaceSm,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: tokens.spaceSm,
              width: width,
              height: widget.height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (url != null && url.isNotEmpty)
                      CachedImageWidget(
                        imageUrl: ImageUtils.getCardCoverUrl(url),
                      )
                    else
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.primary.withValues(alpha: _emptyTop),
                              scheme.primary.withValues(alpha: _emptyFoot),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.videogame_asset,
                            size: widget.height * _emptyIcon,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    // The pass rests for the back half of the cycle, so it
                    // reads as a repeated event and not as a moving stripe.
                    AnimatedBuilder(
                      animation: _pass,
                      builder: (context, _) => CustomPaint(
                        painter: LightSweepPainter(
                          colour: scheme.primary,
                          progress: _pass.isAnimating
                              ? (_pass.value * 2).clamp(0.0, 1.0)
                              : 0,
                          band: _band,
                          strength: _strength,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: _LiveDot(pulse: _pass, size: tokens.spaceMd),
            ),
          ],
        ),
      ),
    );
  }

  /// Covers are 3:4, and a thumbnail that keeps that is recognisable as the
  /// same picture the card had.
  static const double _aspect = 3 / 4;

  /// A game with no cover art still gets a picture, in the same shape and with
  /// the same treatment the game cards use — an empty box would read as a
  /// texture swatch rather than as a missing cover.
  static const _emptyTop = 0.30;
  static const _emptyFoot = 0.60;
  static const _emptyIcon = 0.45;
  static const _band = 0.5;
  static const _strength = 0.6;
}

/// Still working. Rides the same controller as the pass so the card has one
/// clock rather than three.
class _LiveDot extends StatelessWidget {
  const _LiveDot({required this.pulse, required this.size});

  final Animation<double> pulse;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          final beat = _dim + (1 - _dim) * (1 - (pulse.value * 2 - 1).abs());
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withValues(alpha: beat),
              // A ring in the card's own colour, so the dot stays visible when
              // it sits over a bright corner of the cover.
              border: Border.all(color: scheme.surfaceContainer, width: 1.5),
            ),
          );
        },
      ),
    );
  }

  /// Never fully out: a dot that blinks off reads as "nothing is happening".
  static const _dim = 0.45;
}
