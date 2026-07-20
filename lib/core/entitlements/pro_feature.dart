/// Features that are part of the paid **GamerGrove Pro** tier.
///
/// The social graph, rating, and wishlist stay free forever (never paywall the
/// network effect — see MASTERPLAN Phase 2). A single Pro subscription unlocks
/// every feature below; the enum keeps call sites explicit and leaves room for
/// finer-grained gating later without touching consumers.
enum ProFeature {
  /// Extended personal statistics & insights (genre/platform breakdowns,
  /// rating analytics over time).
  extendedStats,

  /// Unlimited custom collections (free tier is capped).
  unlimitedCollections,

  /// Advanced filtering & sorting across the catalog and collections.
  advancedFilters,

  /// Profile customization (themes, badges).
  profileCustomization,

  /// Ad-free experience (if ads are ever introduced on the free tier).
  adFree,
}
