/// Free-tier limits enforced client-side.
///
/// Pro (`ProFeature.unlimitedCollections`) removes the cap. Server-side
/// enforcement (RLS/trigger on `user_collections`) is a tracked follow-up; this
/// constant is the single source of truth for the client gate and its copy.
library;

/// Maximum number of custom collections a free user may create.
const int kFreeCollectionLimit = 3;

/// Whether creating another collection requires Pro: true only for a free user
/// who already has [kFreeCollectionLimit] or more collections.
bool isAtFreeCollectionLimit({
  required bool isPro,
  required int currentCount,
}) =>
    !isPro && currentCount >= kFreeCollectionLimit;
