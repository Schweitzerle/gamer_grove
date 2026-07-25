import 'package:flutter/material.dart';

/// Spacing, radius and motion tokens — the values Material 3's `ColorScheme`
/// and `TextTheme` do not cover.
///
/// Feature code reads these through `Theme.of(context).extension<GGTokens>()`
/// (or the `context.ggTokens` shorthand) so there are no magic paddings left in
/// widgets. Everything sits on a 4dp grid.
@immutable
class GGTokens extends ThemeExtension<GGTokens> {
  const GGTokens({
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusPill,
    required this.durationFast,
    required this.durationNormal,
    required this.minTapTarget,
  });

  /// The one set of values the app is built on.
  static const standard = GGTokens(
    spaceXs: 4,
    spaceSm: 8,
    spaceMd: 16,
    spaceLg: 24,
    spaceXl: 40,
    radiusSm: 8,
    radiusMd: 12,
    radiusLg: 20,
    radiusPill: 999,
    durationFast: Duration(milliseconds: 150),
    durationNormal: Duration(milliseconds: 250),
    // Android's floor for anything tappable; iOS asks 44pt, so this covers both.
    minTapTarget: 48,
  );

  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusPill;
  final Duration durationFast;
  final Duration durationNormal;
  final double minTapTarget;

  @override
  GGTokens copyWith({
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusPill,
    Duration? durationFast,
    Duration? durationNormal,
    double? minTapTarget,
  }) {
    return GGTokens(
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusPill: radiusPill ?? this.radiusPill,
      durationFast: durationFast ?? this.durationFast,
      durationNormal: durationNormal ?? this.durationNormal,
      minTapTarget: minTapTarget ?? this.minTapTarget,
    );
  }

  @override
  GGTokens lerp(covariant GGTokens? other, double t) {
    if (other == null) return this;
    return GGTokens(
      spaceXs: lerpDouble(spaceXs, other.spaceXs, t),
      spaceSm: lerpDouble(spaceSm, other.spaceSm, t),
      spaceMd: lerpDouble(spaceMd, other.spaceMd, t),
      spaceLg: lerpDouble(spaceLg, other.spaceLg, t),
      spaceXl: lerpDouble(spaceXl, other.spaceXl, t),
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t),
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t),
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t),
      radiusPill: lerpDouble(radiusPill, other.radiusPill, t),
      durationFast: t < 0.5 ? durationFast : other.durationFast,
      durationNormal: t < 0.5 ? durationNormal : other.durationNormal,
      minTapTarget: lerpDouble(minTapTarget, other.minTapTarget, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

extension GGTokensX on BuildContext {
  /// Never null in the app: both themes register [GGTokens.standard].
  GGTokens get ggTokens =>
      Theme.of(this).extension<GGTokens>() ?? GGTokens.standard;
}
