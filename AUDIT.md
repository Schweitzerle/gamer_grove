# GamerGrove — Phase 0 Audit (2026-07-15)

Reconstructed by parallel exploration of the codebase. Reference for refactoring
(Phase 1) and monetization/security (Phase 2). Complements `PROGRESS.md`.

---

## 1. Architecture map

Clean Architecture: `domain/` (entities, 6 repo interfaces, 104 usecases) →
`data/` (datasources, models, 6 repo impls) → `presentation/` (17 bloc folders,
40+ page folders, shared widgets). `core/` = constants, env, errors, network,
services, utils. DI in single `lib/injection_container.dart` (~94 registrations,
global `sl`). Entry `main.dart` → `SplashPage` (no named routes).

### BLoCs (all `Bloc`, no Cubits)
| Bloc | Notes |
|---|---|
| GameBloc (2014) | **God-file** — search + details + taxonomy + user-data hub. event 566 / state 811. Split target. |
| UserGameDataBloc (630) | Per-game user data (rating/wishlist/top-three), global lazy-singleton. |
| EventBloc, StatisticsBloc, CollectionBloc, GameEngineBloc, PlatformBloc | Medium, per-feature. |
| AuthBloc (232) | Sign in/up/out, session. **Tested ✓** |
| UserProfileBloc, CharacterBloc, SocialInteractionsBloc, ActivityFeedBloc, CompanyBloc, UserSearchBloc, ThemeBloc, LeaderboardBloc | Smaller. |

### Repositories → impl → datasource
- Auth → `auth_repository_impl` → `SupabaseAuthDataSource`
- User → `user_repository_impl` (1153) → `SupabaseUserDataSource`
- Game → `game_repository_impl` (**2516, god-file**) → `IgdbDataSource` + optional `SupabaseUserDataSource`
- Character/Event → `*_impl` → `IgdbDataSource`
- UserActivity → `user_activity_repository_impl` → `SupabaseUserActivityDataSource`
- Base classes: `data/repositories/base/{igdb,supabase}_base_repository.dart` (error-handling wrappers).

### Datasources
- **IGDB**: `igdb_datasource_impl`, `igdb_isolated_client` (isolate HTTP — ⚠️ conflicting
  signals on whether still used; verify before touching), token manager
  `shared_preft_topken_manager.dart` (**filename typo** "preft/topken").
- **Supabase**: split `auth` / `user` (887) / `user_activity` datasources. Query builders in
  `models/supabase_presets.dart` (622, raw query strings), `supabase_query.dart`, `supabase_filters.dart`.

### Navigation
No route table. `core/utils/navigations.dart` (892) — 80+ static methods, 29 direct
`MaterialPageRoute`. Single choke point every page depends on.

### Refactor god-files (Phase 1 targets, >800 lines)
filter_bottom_sheet 3251 · game_repository_impl 2516 · game_bloc 2014 ·
content_dlc_section 1439 · company_details_screen 1427 · user_repository_impl 1153 ·
event_details_screen 1056 · search_page 962 · navigations 892 · plus several detail screens.

---

## 2. Security findings (priority order)

> **⚠️ CRITICAL — needs live-DB verification (user action: Supabase access).**

1. **`profiles` table RLS unknown.** SupabaseScripts only enable RLS on the OLD `users`
   table (`003`). The app was migrated `users` → `profiles` (commits 3fe288c/42bad72), but
   **no `profiles` CREATE/RLS/policy script exists in the repo**. If `profiles` shipped
   without RLS, the anon key grants full read (all PII: username, bio, country, avatar) and
   possibly write to every profile. **Verify RLS is enabled + policies exist on `profiles`
   in the live DB immediately.** All client authz relies on RLS.
2. **PostgREST filter injection** in `supabase_user_datasource_impl.dart:659-667`
   (`searchUsers`): raw `'%$query%'` interpolated into `.or('username.ilike.$p,display_name.ilike.$p')`.
   Input with `,`, `)`, `.`, `*` can alter the filter tree. **Fix: route through the
   parameterized `search_users` RPC, or sanitize.** (RLS still bounds data, but it's a real hole.)
3. **Full follow-graph disclosure**: `user_follows` SELECT policy is `USING (true)` — any
   anon-key holder can read who-follows-whom for all users, including private profiles.
4. **IGDB Client Secret shipped in the app** (`Env.igdbClientSecret`, envied `obfuscate:true`).
   Obfuscation ≠ encryption; extractable from APK/IPA; posted to Twitch from device. A leaked
   secret enables quota theft. **Phase 2: move token minting to a Supabase Edge Function proxy;
   never ship the client secret.** (This is also the IGDB commercial-license seam.)
5. **Stale RPCs reference dropped `users` table** (`004`: search_users, get_popular_users,
   get_following_activity_feed, get_mutual_followers JOIN `public.users`) — may throw at runtime
   if `users` was dropped. Availability risk + migration drift signal.
6. **Activity `is_public` computed once at insert** from privacy flags; flipping a profile to
   private later does NOT re-hide old `user_activity` rows (historical leak).
7. Supabase anon key embedded (expected) — blast radius = whatever RLS allows (see #1).

**Good news:** no secrets committed (`.env`, `env.g.dart` gitignored), envied obfuscation in place.

### Migration/DB hygiene
`SupabaseScripts/` is a messy patch history (000 introspection, 001–005 build on `users`,
007–011 reactive fixes after the profiles rename; no 006; `.txt` vs `.sql` mix; stray
`.005.txt.kate-swp`). **Action: author a single canonical `profiles` schema+RLS migration**
and reconcile the `004` RPCs to `profiles`.

---

## 3. TODO / stub inventory (69 markers)

### Fake data in production (P1)
- `search_page.dart:174` — `_recentSearches = ['The Witcher','Cyberpunk','Mario','Zelda']`
  shown to EVERY user as their recent searches. Load real history from SharedPreferences.
- `game_repository_impl.dart:2254` — `moveGamesBetweenCollections` is a silent no-op (`Right(null)`).

### Silent-success stubs (P2) — return empty/null, callers think it worked
`game_repository_impl.dart`: 1750/1761/1770 (recent searches, recently-added, suggestions →
`Right([])`), 1847/1856/2022 (genre/platform/top-genre stats → `Right({})`/`Right([])`),
2284 (`saveSearchQuery` no-op), 1919/2012/2214 (accept `UserCollectionFilters` then IGNORE it).
`user_repository_impl.dart:541` — `getUserActivity` throws `UnimplementedError` (dormant; crashes if called).

### Missing navigation/features (P2/P3)
`navigations.dart`: 344 (search results screen), 674 (games-with-events), 355/363 (franchise/
collection detail = "coming soon"). `all_events_screen.dart:461`, `media_gallery.dart:203`
(video player/YouTube), event calendar/share/notifications (P3).

### `tool/check_unimplemented.dart`
Scans lib/ for `UnimplementedError`, fails if any found, does NOT skip `/deprecated/`. After
deprecated/ deletion it reports only `user_repository_impl.dart:541`. **Fix that stub or the
tool stays red if wired into CI.**

---

## 4. Dead code — status

**Deleted in Phase 0** (commit e096bbc, 4173 LOC): `supabase/deprecated/`, `blocs/social/`
(empty stub), `igdb/examples/usage_examples.dart`, root scratch (EXAMPLE/QUICK_START/GUIDE).

**Deferred — ~95 orphan `.dart` candidates** (0 import refs; sampled ones 0 class refs, but some
reference each other → verify before mass delete): ~33 data/models, ~30 domain/usecases,
~11 pages, ~9 entities, ~7 widgets, misc core utils (game_utils, url_utils, performance_monitor,
api_client, error_handler, loading_widget). **Action Phase 1: run an unused-files pass** (e.g.
`dart run dart_code_metrics:metrics check-unused-files lib`) to confirm, then bulk-remove.
Also: 5 files with >20-line commented-out blocks (navigations 589, game_bloc 1340,
game_card_shimmer 2, platform_section 747, company_section 466).

⚠️ Conflicting signal on `igdb/isolated_client.dart` (`IsolatedIGDBClient`) — one pass said
used, one said 0-ref. **Verify before deleting.**
