import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_chamber_light.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';

/// A section of the Grove, lit by how close it is to the middle of the screen.
///
/// This replaces the card frame every section used to sit in. Five identical
/// boxes gave the app's signature statement the same weight as the wishlist;
/// here hierarchy comes from brightness instead of from borders — which is the
/// brand taken literally: in a cave, not everything is equally lit.
///
/// The dimming is bounded on purpose. Text in a section that has moved away
/// still has to clear WCAG AA, so the veil stops well before the point where
/// the palette's contrast headroom runs out, and it is skipped entirely when
/// the system asks for less motion.
class LitSection extends StatefulWidget {
  const LitSection({
    required this.title,
    required this.child,
    this.onViewAll,
    this.eyebrow,
    this.lightMode = ChamberLightMode.steady,
    this.tint,
    super.key,
  });

  final String title;
  final Widget child;

  /// Shown as a trailing action when given.
  final VoidCallback? onViewAll;

  /// Small label above the title.
  final String? eyebrow;

  /// How this chamber is lit — the thing that tells one section from the next
  /// without giving each its own colour scheme.
  final ChamberLightMode lightMode;

  /// Colour of the light. Defaults to the brand accent; later derived from the
  /// covers standing in the section.
  final Color? tint;

  /// Identifies the dimming layer, so tests can assert on how far a section
  /// has faded instead of guessing at widget order.
  static const veilKey = ValueKey<String>('lit-section-veil');

  /// The light a chamber keeps even when it is far from the middle of the
  /// screen. Without it the sections read as unlit boxes that only come alive
  /// under the cursor, which is not what the metaphor says.
  static const restingLight = 0.62;

  /// How far a section may fade when it is out of the light.
  ///
  /// Computed against the palette, not chosen by eye. The binding case is
  /// secondary text: `onSurfaceVariant` on `surface` starts at 7.82:1 and drops
  /// below 4.5:1 once the veil passes 0.25, so the veil is capped there. The
  /// first draft used 0.55 and put the gold "Alle" action at 4.27:1.
  ///
  /// The consequence is honest: the effect is subtler than a mock-up can make
  /// it look, because a mock-up is not bound by contrast.
  static const minLight = 0.75;

  @override
  State<LitSection> createState() => _LitSectionState();
}

class _LitSectionState extends State<LitSection> {
  /// 0 = fully out of the light, 1 = centred and fully lit.
  final _light = ValueNotifier<double>(1);
  ScrollPosition? _position;
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _position?.removeListener(_schedule);
    _position = Scrollable.maybeOf(context)?.position?..addListener(_schedule);
    _schedule();
  }

  @override
  void dispose() {
    _position?.removeListener(_schedule);
    _light.dispose();
    super.dispose();
  }

  /// Reading the section's position straight from the scroll listener returns
  /// the pre-scroll layout, so the light would lag or stick. Recomputing after
  /// the frame is settled costs one callback per frame at most.
  void _schedule() {
    if (_scheduled || !mounted) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      _relight();
    });
  }

  void _relight() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final viewport = MediaQuery.sizeOf(context).height;
    final top = box.localToGlobal(Offset.zero).dy;
    final centre = top + box.size.height / 2;

    // Fully lit within the middle band, falling off towards the edges.
    final distance = (centre - viewport * 0.45).abs() / (viewport * 0.62);
    _light.value = (1 - distance).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.ggTokens;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final header = Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spaceMd,
        0,
        tokens.spaceMd,
        tokens.spaceSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.eyebrow != null)
                  Text(
                    widget.eyebrow!.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.6,
                    ),
                  ),
                Text(widget.title, style: theme.textTheme.headlineSmall),
              ],
            ),
          ),
          if (widget.onViewAll != null)
            TextButton(
              onPressed: widget.onViewAll,
              child: const Text('View All'),
            ),
        ],
      ),
    );

    final tint = widget.tint ?? theme.colorScheme.primary;

    final content = Padding(
      padding: EdgeInsets.only(top: tokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          widget.child,
          // Chambers meet in grain rather than at an edge, so one light fades
          // into the next.
          ChamberSeam(tint: tint),
        ],
      ),
    );

    if (reduceMotion) return content;

    return ValueListenableBuilder<double>(
      valueListenable: _light,
      // The content is built once and handed through; only the lighting layer
      // rebuilds as the page scrolls.
      child: content,
      builder: (context, light, child) {
        // A veil in the surface colour rather than `Opacity`: opacity forces an
        // offscreen layer for every section on every frame, and "recedes into
        // the dark" is the truer description anyway.
        final veil = (1 - light) * (1 - LitSection.minLight);
        return Stack(
          children: [
            Positioned.fill(
              child: ChamberLight(
                tint: tint,
                // A chamber is lit by the games standing in it, so it keeps a
                // floor of its own light wherever the page is scrolled to;
                // scrolling only decides how much is added on top.
                intensity: LitSection.restingLight +
                    (1 - LitSection.restingLight) * light,
                mode: widget.lightMode,
              ),
            ),
            // The veil dims the content, not the chamber's light — the light
            // already answers to scroll through its own intensity, and dimming
            // it twice left the wash invisible.
            Stack(
              children: [
                child!,
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      key: LitSection.veilKey,
                      color: theme.colorScheme.surface.withValues(alpha: veil),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
