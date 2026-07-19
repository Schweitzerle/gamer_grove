# PROGRESS — GamerGrove Polish → Startup

> Resume protocol: read this file, then `MASTERPLAN.md`, then continue the first
> unchecked item. Standing Authorization gilt (autonom committen/pushen/PR/merge
> nach grünem CI). Fragen an den User werden gebündelt gesammelt (Abschnitt unten).

**Last updated:** 2026-07-19 (Session 2)
**Current branch:** `master`
**Current phase:** ✅ Phase 0 COMPLETE · Phase 1 IN PROGRESS (nahezu fertig)

### Session 2 (2026-07-19) — merged to master
- PR #88 Sentry crash reporting (DSN-gated) — gemergt.
- PR #89 chore: desktop plugin registrants regeneriert (sentry_flutter/jni).
- PR #90 **fix(security): PostgREST-Injection in searchUsers** — `escapePostgrestFilterValue`
  (double-quote/escape), 8 Unit-Tests. AUDIT.md §2.2 erledigt.
- PR #91 **refactor: 147 Orphan-Dateien entfernt (−13.6k LOC)** — Reachability-Analyse
  (BFS von main.dart/injection_container.dart), 0 Import-Refs verifiziert, analyze 0/0,
  Tests grün. AUDIT.md §4 erledigt. (Detektor-Script: scratchpad/find_orphans.dart.)
- PR #92 **feat(analytics): Funnel-Events + ActivationTracker** — signup/rate_game/
  wishlist_add/follow_user verdrahtet; `ActivationTracker` (SharedPreferences, once-per-user:
  erstes Rating ODER ≥3 Wishlist + ≥1 Follow). 10 Tests (Tracker 6 + UserGameDataBloc 4). GEMERGT.
- PR #93 **refactor: filter_bottom_sheet.dart 3282→8 Dateien (<800 je)** — behavior-preserving
  via **part-file/extension-Strategie**; `DateFilterDialog` in eigene Datei. Lokal + CI verifiziert
  (analyze 0/0, 27 Tests, APK-Build grün). GEMERGT. **Refactoring 1 von 3 fertig.**
> Gotcha: alle Analytics-Deps sind **optional** an den Blocs (default Noop/null) → bestehende
> Tests unberührt. `SocialInteractionsBloc` wird NICHT in DI registriert, sondern in 4 Pages
> direkt konstruiert (user_search/user_detail/leaderboard/followers_following) — dort Analytics
> durchgereicht. `UserBloc` (mit `FollowUserEvent`) ist ungenutzt (keine DI/UI-Refs).

### 🔧 Monster-Refactoring — Strategie & Stand (WICHTIG für Folgesession)
Erprobtes Muster (PR #93): Riesen-Datei als **Library-Root** behalten, Methoden in
`extension _X on <StateOrClass>` in **`part`-Dateien** auslagern (gleiche Library = voller
Zugriff auf private Felder/`setState`, byte-identischer Move). Bei `State`-Klassen: `setState`
in Extensions triggert `invalid_use_of_protected_member` (Analyzer-False-Positive, läuft zur
Laufzeit) → `// ignore_for_file: invalid_use_of_protected_member` je part-Datei.
- **`filter_bottom_sheet.dart`** ✅ fertig (PR #93).
- **`game_bloc.dart`** (2014 Z., nutzt schon `part game_event/game_state/game_extensions`):
  Handler sind private, via `on<>()` registriert — **KEINE** `@override`-Interface-Methoden →
  part/extension-Muster funktioniert **direkt** (wie filter_bottom_sheet). Nächster einfacher Kandidat.
- **`game_repository_impl.dart`** (2540 Z., 96 `@override` `implements GameRepository`): part/extension
  **funktioniert NICHT** (Extension-Methoden erfüllen kein Interface → "Missing concrete implementation";
  auch keine privaten Helfer zum Auslagern). **Lösung: Mixin-Chain** — `class GameRepositoryImpl
  extends IgdbBaseRepository with _RepoSearch, _RepoDetails, … implements GameRepository`, Mixins in
  part-Dateien (`mixin _RepoSearch on IgdbBaseRepository { … }`). Mixin-Member erfüllen das Interface.
  ⚠️ Prüfen: greifen Methoden auf Felder von `GameRepositoryImpl` (Datasources) zu, die NICHT auf
  `IgdbBaseRepository` liegen? Dann Mixin-`on`-Constraint anpassen oder Felder hochziehen. Subagent-Versuch
  brach durch Account-Session-Limit ab (kein Code-Ergebnis).

### ✅ Merged to master (PR #85, squash f3e683f, CI green: analyze+test AND build APK)
Alle Session-1-Commits sind auf master. Feature-Branch gelöscht. Nächste Arbeit
wieder auf frischem Feature-Branch.
> Gotcha für Folgesessions: `flutter analyze` ist default `--fatal-infos`; CI nutzt
> `--no-fatal-infos` (Gate nur auf 0 errors + 0 warnings). `gh pr merge --squash`
> hat lokal master nicht ge-fast-forwarded → ggf. `git fetch && git reset --hard origin/master`.

---

## TL;DR State

- **Phase 0 abgeschlossen & verifiziert.** Baseline grün: `flutter analyze` 0 errors,
  Debug-APK baut (exit 0), Codegen läuft, 439 Dateien formatiert.
- **Phase 1 begonnen:** CI-Pipeline steht, erste echte Tests (AuthBloc, 11 grün),
  4173 LOC Dead Code entfernt.
- Vollständige Audit-Ergebnisse (Architektur, Security, TODOs, Dead Code) in **`AUDIT.md`**.
- Commits auf `chore/phase0-baseline` (noch nicht gepusht — CI-Verifikation via GitHub steht aus):
  1. `chore: fix build baseline (codegen, gradle JDK, analyzer config)`
  2. `style: apply dart format to entire codebase` (439 Dateien)
  3. `test: add AuthBloc bloc_test suite + CI pipeline`
  4. `refactor: remove dead code (deprecated datasource, social bloc, scratch)` (−4173 LOC)

## ⚠️ Wichtigste Security-Findings (Details in AUDIT.md §2)
1. **`profiles`-RLS unbekannt** — kein CREATE/RLS-Script im Repo für die migrierte
   `profiles`-Tabelle. **Muss gegen Live-DB verifiziert werden (User-Aktion: Supabase-Zugang).**
2. **PostgREST-Injection** in `supabase_user_datasource_impl.dart:659` (`searchUsers`) — Fix in Phase 1/2.
3. **Follow-Graph komplett öffentlich** (`user_follows` SELECT `USING(true)`).
4. **IGDB Client Secret im Client** — Edge-Function-Proxy in Phase 2 (auch Lizenz-Seam).

## Baseline-Zahlen (Ist-Zustand, 2026-07-15)

| Metrik | Wert |
|---|---|
| Dart-Dateien / LOC | 521 / ~95.5k |
| `flutter analyze` | **0 errors**, 6 warnings, 1440 info (nach Config-Fix; vorher 7382) |
| `dart format` | sauber (war vorher: 439/524 ungeformatet) |
| `flutter build apk --debug` | ✓ baut (APK ~162 MB) |
| Tests | **1** (nur `test/widget_test.dart`, Default-Counter) |
| CI | **keine** (`.github/workflows` fehlt) |
| TODO/FIXME | 69 |
| Größte Dateien | filter_bottom_sheet 3251, game_repository_impl 2516, game_bloc 2014 |

### Verbleibende 6 analyze-Warnings (echte Code-Issues, Phase 1 fixen)
- `game_model.dart:52` / `game.dart:30` — `must_be_immutable` (Game.characters, Game.events nicht final)
- `game.dart:310` — `collection_methods_unrelated_type` (WebsiteType vs WebsiteCategory)
- `game_details_accordion.dart:322` — `unrelated_type_equality_checks` (**echter Bug**: WebsiteType == WebsiteCategory)
- `game_bloc.dart:1460,1474` — `inference_failure_on_collection_literal`

### Top info-Kategorien (Tech-Debt für Phase 1)
610 deprecated_member_use · 164 avoid_catches_without_on_clauses · 152 discarded_futures ·
126 avoid_returning_this · 107 avoid_dynamic_calls · 105 require_trailing_commas ·
31 flutter_style_todos · 15 empty_catches · 12 avoid_print

## Was in Session 1 gefixt wurde (Details)
- **Codegen-Blocker**: `envied/envied_generator` `^1.3.1`→`^1.3.8` (alte Version pinnte
  `source_gen 3.1.0`, inkompatibel mit `analyzer 8.x`). `env.g.dart` wird jetzt generiert.
  → **Gotcha:** `env.g.dart` ist gitignored; lokal existiert eine gitignorierte `.env`
  (aus `.env.example`, Platzhalter). Für CI/Real-Build müssen echte Secrets als `.env`
  injiziert werden (GitHub Secrets → `.env` schreiben). Ohne `.env` schlägt Codegen fehl.
- **Gradle/JDK**: `android/gradle.properties` hatte hartkodiertes, kaputtes
  `org.gradle.java.home=/usr/lib/jvm/java-21-openjdk` (Pfad existiert nicht; korrekt wäre
  `-amd64`). Entfernt → JDK wird auto-detektiert (portabel/CI). Doppelte `jvmargs`
  entfernt, Heap auf 2g gesenkt, **`android.enableJetifier=false`** (AndroidX-only) —
  behob OOM/Java-heap-space im Debug-Build. Build 137/143/heap → jetzt exit 0.
- **analysis_options**: `public_member_api_docs` + `lines_longer_than_80_chars` auf
  `ignore` (App, kein Package) → analyze-Rauschen 7382→1446.

## Umgebungs-Gotchas
- Maschine hat nur ~14 GB RAM, oft <1,5 GB frei → große Gradle-Heaps killen den Build
  (OOM, exit 137/143). Vor Builds ggf. `./android/gradlew --stop` und Daemons killen.
- Flutter 3.41.5 / Dart 3.11.3. `flutter pub get` will Deps hochziehen (analyzer 8.x);
  die committete `pubspec.lock` war mit dem SDK nicht mehr `--enforce-lockfile`-fähig.
- IGDB `IGDB_CLIENT_SECRET` wird via envied (obfuscated) **im Client** ausgeliefert —
  bleibt ein Sicherheits-/Lizenz-Thema für Phase 2 (Edge-Function-Proxy).

---

## Phase-1-Fortschritt
- [x] CI-Pipeline (`.github/workflows/ci.yml`): format → analyze(--no-fatal-infos) → test+coverage → build apk. **Grün, gemergt (PR #85).**
- [x] AuthBloc-Tests (11), Game-Entity-Tests (3). mocktail + fixtures.
- [x] Entrümpeln Teil 1: 4173 LOC Dead Code gelöscht.
- [x] Alle 6 echten analyze-Warnings gefixt (WebsiteType==WebsiteCategory-Bug etc.) + Regression-Tests.
- [x] **Analytics-Abstraktion + Umami-Backend (key-gated, 5 Tests)** — `AnalyticsService`/Noop/Umami, Event-Schema, `app_open` in main verdrahtet.
- [x] **Sentry native init** (DSN-gated in main) — PR #88 gemergt.
- [x] **Analytics-Events an Funnel-Punkten verdrahtet** (signup, rate_game, wishlist_add, follow_user, activation) — PR #92 gemergt.
- [x] **Entrümpelung Teil 2: 147 Orphan-Dateien (−13.6k LOC)** — PR #91 gemergt.
- [x] **Security-Fix: PostgREST-Injection in `searchUsers`** — PR #90 gemergt.
- [x] **UserGameDataBloc-bloc_test** (4) — rate/wishlist Verhalten + Analytics-Wiring. In PR #92.
- [x] **Refactoring 1/3: filter_bottom_sheet** (3282→8 Dateien) — PR #93 gemergt.
- [ ] Umami/Sentry-Keys vom User → GitHub Secrets + lokale .env → Live-Events verifizieren (USER-AKTION).
- [ ] **Refactoring 2/3: game_bloc.dart** (2014) — part/extension-Muster (funktioniert direkt, s.o.).
- [ ] **Refactoring 3/3: game_repository_impl.dart** (2540) — **Mixin-Chain** nötig (s.o.), NICHT part/extension.
- [ ] Weitere Tests: GameBloc, Repository-Fakes, GameCard-Widget.

## Nächste 3 Schritte (Session 3)
1. **Refactoring 2/3: `game_bloc.dart`** — part/extension-Muster (wie PR #93, funktioniert direkt,
   da Handler keine `@override`-Interface-Methoden sind). Worktree-Subagent, verify analyze 0/0 +
   `flutter test`, Review+Merge. RAM-Limit: **nur 1 Flutter-Prozess gleichzeitig** (Subagenten sequenziell).
2. **Refactoring 3/3: `game_repository_impl.dart`** — **Mixin-Chain** (part/extension scheitert am
   Interface, s. Abschnitt oben). Danach part/extension NICHT nutzen.
3. Rest-Tests: GameCard-Widget-Test, Repository-Fakes. Dann Phase 1 = DONE → Phase 2 (Monetarisierung)
   starten mit IGDB-Lizenz-Recherche (Blocker) + RevenueCat.

> **Session-2-Ende-Notiz:** 6 PRs gemergt (#88–#93). Phase 1 ~85% fertig. Es fehlen nur noch
> 2 Refactorings + ein paar Tests. Ein Subagent-Versuch für game_repository_impl brach durch ein
> Account-Session-Limit ab (kein Code verloren, Erkenntnis dokumentiert: Mixin-Chain nötig).

## User-Entscheidungen (2026-07-15 beantwortet)
1. **Pricing Pro:** **2,99 €/Monat · 19,99 €/Jahr**.
2. **Analytics:** **Umami** (statt PostHog — User konsolidiert mit eigenen Web-Projekten).
   Kein Mobile-SDK → via HTTP-Event-API (`/api/send`). Hinter `AnalyticsService`-Interface
   bauen (Swap = Refactor). **Crashes:** **Sentry** (User hat Account).
3. **IGDB:** **Erst Recherche** (kommerziell vs. RAWG/MobyGames), dann Entscheidung. Noch nichts umbauen.
4. **Launch:** **Nur Android** vorerst (kein iOS/Apple-Account). Store-Publishing bleibt bestätigungspflichtig.
5. **Noch offen/benötigt vom User:** Sentry-DSN + Umami-Instanz-URL + Website-ID (für Live-Events);
   RevenueCat-Account + Play-Console-Produkte (Phase 2). Code wird key-gated gebaut (no-op ohne Keys).

## Branch-/Merge-Status
- `chore/phase0-baseline` — 2 Commits, noch nicht gepusht/gemerged (CI existiert noch
  nicht; wird mit Phase-1-CI zusammen grün gemacht, dann Merge nach master).
