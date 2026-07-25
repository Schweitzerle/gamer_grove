import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_contrast.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';

/// A single swatch in the theme picker.
///
/// Takes a resolved [ColorScheme] rather than a `FlexScheme` so the GamerGrove
/// brand theme — which is not one of FlexColorScheme's schemes — can sit in the
/// same grid as the rest.
class ThemeCard extends StatelessWidget {
  const ThemeCard({
    required this.colorScheme,
    required this.label,
    required this.isSelected,
    required this.onSelect,
    super.key,
  });

  final ColorScheme colorScheme;
  final String label;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.ggTokens;
    final radius = BorderRadius.circular(tokens.radiusMd);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      // Deliberately not `Ink`: Ink paints its decoration onto the nearest
      // ancestor Material rather than itself, so inside a scrolling grid the
      // tiles are drawn outside the viewport and escape its clip — they ended
      // up painted over the dialog's Close button. A DecoratedBox paints
      // normally and clips with the viewport; the transparent Material below
      // gives the InkWell its own ink layer.
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: radius,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onSelect,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.vertical(top: radius.topLeft),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(tokens.spaceSm),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: FittedBox(
                          // The name is already the button's semantic label.
                          child: ExcludeSemantics(
                            child: Text(
                              label,
                              style: theme.textTheme.labelLarge?.copyWith(
                                // Several FlexColorScheme palettes pair their own
                                // onPrimary with primary at ~3:1, which is not
                                // enough for a caption this size.
                                color: colorScheme.primary
                                    .readableForeground(colorScheme.onPrimary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spaceSm),
                    child: Row(
                      spacing: tokens.spaceSm,
                      children: [
                        Expanded(child: _Swatch(colorScheme.secondary)),
                        Expanded(child: _Swatch(colorScheme.tertiary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(context.ggTokens.radiusSm),
      ),
    );
  }
}
