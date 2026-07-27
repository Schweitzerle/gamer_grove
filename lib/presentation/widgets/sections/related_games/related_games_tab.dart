import 'package:flutter/material.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';

/// One tab inside a related-games accordion.
///
/// This replaces three parallel types — `ContentTab`, `VersionTab`,
/// `RelatedTab` — that carried the same five fields and answered the same two
/// questions through three enums and six `switch` statements. The strings the
/// enums selected are now simply on the tab.
@immutable
class RelatedGamesTab {
  const RelatedGamesTab({
    required this.label,
    required this.heading,
    required this.blurb,
    required this.emoji,
    required this.icon,
    required this.accent,
    required this.games,
    this.onViewAll,
  });

  /// Short, for the tab bar itself.
  final String label;

  /// The full name, above the row of covers.
  final String heading;

  /// One line under the heading — what this tab holds, and how much of it.
  final String blurb;

  /// Stands in for the icon in the collapsed preview, which is plain text.
  final String emoji;

  final IconData icon;

  /// The tab's own colour.
  ///
  /// Never used raw as a foreground: every Material accent fails contrast on
  /// one theme or the other, so the accordion lifts it per surface.
  final Color accent;

  final List<Game> games;

  /// Where "View All" leads, when there is somewhere more specific than the
  /// generic list of games. Null falls back to that list.
  final void Function(BuildContext context)? onViewAll;
}
