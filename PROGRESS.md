# PROGRESS — GamerGrove Polish → Startup

> Resume protocol: read this file, then `MASTERPLAN.md`, then continue the first
> unchecked item. Standing Authorization gilt (autonom committen/pushen/PR/merge
> nach grünem CI). Fragen an den User werden gebündelt gesammelt (Abschnitt unten).

**Last updated:** 2026-07-20 (Session 4)
**Current branch:** `master`
**Current phase:** ✅ Phase 0 · ✅ Phase 1 · 🚧 **Phase 2 IN PROGRESS (Monetarisierung)**

### Session 4 (2026-07-20) — Phase 2 gestartet (Monetarisierung)
- **Entscheidung (User): Game-Data-Source = IGDB behalten** (Recherche in
  `docs/PHASE2_IGDB_LICENSE.md`, PR #99). Kernbefund: Supabase speichert **nur `game_id`-Refs**,
  keine IGDB-Metadaten → **TDSA-24h-Caching-Regel schon eingehalten**, IGDB bleiben = low-risk.
  RAWG bleibt als Fallback-Adapter-Seam (aber Attribution-Pflicht pro Screen + 100k-MAU-Deckel).
  **User-Action offen:** 1 Mail an `partner@igdb.com` (kommerzielle Bestätigung) vor Paid-Launch.
- **PR #100 feat(entitlements): EntitlementService-Scaffold + Free/Pro-Modell.** `ProFeature`-Enum
  (extendedStats/unlimitedCollections/advancedFilters/profileCustomization/adFree), `Entitlements`
  (Equatable, isPro/has()), Interface + `FreeEntitlementService` (Default, alles frei) — Muster wie
  `AnalyticsService`. In DI registriert (RevenueCat-Impl wird später key-gated eingehängt). 6 Tests.
- **feat(paywall): designed Paywall-Screen** (commit `d060346`) — Gradient-Pro-Hero, Feature-Value-Prop,
  2 wählbare Plan-Cards (yearly „Best value/Save 44%", monthly), Sticky-CTA + Kleingedrucktes; alle
  Tokens aus `Theme.of(context)` (beide Themes). Funnel verdrahtet: `paywall_view`(source)/`purchase_start`
  (plan)/`purchase_done`. `onPurchase` nullable → ohne RevenueCat trackt CTA Intent + „coming soon".
  `ProPlan`-Modell + statische Preise (2,99 €/M · 19,99 €/J, ersetzt später RevenueCat-Offerings).
  8 Widget-Tests inkl. a11y-Guidelines. analyze 0/0, Suite **67 grün**.
> **⚠️ Prozess-Slip (ehrlich dokumentiert):** Paywall-Commit `d060346` ging **direkt auf master**
> (Branch vergessen) statt via PR — kein Code-Review-Gate. Code ist aber lokal + **master-CI grün**
> (analyze+test+APK) verifiziert. KEIN Force-Push zur Korrektur (History-Rewrite auf shared main =
> bestätigungspflichtig). Lehre: vor jedem Feature-Block explizit `git checkout -b` prüfen.
> **CI-Wartungsnotiz:** GitHub warnt, `actions/checkout@v4`/`upload-artifact@v4`/`setup-java@v4` laufen
> auf Node20 (deprecated, forced Node24) — bei Gelegenheit Action-Versionen bumpen (nicht dringend).

### Phase-2-Fortschritt (MASTERPLAN §80–99)
- [x] IGDB-Lizenz-Recherche + Entscheidung (IGDB behalten) — `docs/PHASE2_IGDB_LICENSE.md`, PR #99.
- [x] `EntitlementService`-Interface + Free-Default + DI — PR #100.
- [x] Paywall-Screen (designed, funnel-verdrahtet, key-gated) — commit d060346.
- [x] **Paywall in Navigation** (`Navigations.navigateToPaywall`) + Settings-„Upgrade to Pro"-Kachel — PR #102.
- [x] **RevenueCat-Backend key-gated** (`purchases_flutter ^10.4.2`) — PR #103. `RevenueCatEntitlementService`
      (configure/listener→Entitlements[`pro`]/refresh/restore/`purchase(ProPlan)` via Offering `default`),
      `Env.revenueCatApiKey` (leerer Default → Free), DI `initBilling()` (swap in main), Paywall-`onPurchase`
      verdrahtet. analyze 0/0, 67 Tests, **APK baut mit nativem Plugin** (lokal + CI). Static-SDK-API → wird
      per echtem Sandbox-Kauf verifiziert (nicht Unit-Test).
      **⏳ Wartet nur noch auf User:** `REVENUECAT_API_KEY` (`goog_…`) als `.env`+GitHub-Secret; Play-Produkte
      `gg_pro_monthly`/`gg_pro_yearly`; RC-Entitlement `pro`, Offering `default`. Setup-Steps siehe Chat/Session.
      **Sobald Key da:** in `.env`+Secret eintragen → `dart run build_runner build` → App nutzt echtes Billing;
      dann internes Test-AAB + License-Tester für Sandbox-Kauf-Verifikation (Screenshots/Logs).
- [ ] **ProGate + Trigger-Punkte:** Free/Pro-Gates an echten Upgrade-Momenten (extended stats, unlimited
      collections, advanced filters, profile customization) → Paywall öffnen mit `source`. (Pro-Features
      existieren noch nicht als solche → erst bauen/markieren, dann gaten.)
- [ ] golden + `/design-review`-Pass für Paywall.
- [ ] Supabase-Entitlements-Spiegel (RevenueCat-Webhook → Edge Function → `subscriptions`-Tabelle, RLS).
- [ ] IGDB-Edge-Function-Proxy (Client-Secret raus; Security + saubere kommerzielle Posture).
- [ ] Security-Review über den gesamten Payment-/Entitlement-Pfad.

### Session 3 (2026-07-20) — merged to master (PRs #95–#97) → **Phase 1 DONE**
- **PR #95 refactor: game_repository_impl → Mixin-Chain (Refactoring 3/3).** 2540 Z. →
  root 133 Z. + 6 concern-Mixins in `game_repository_impl/` (je <800). `GameRepositoryBase`
  mit Getter-Seams (igdbDataSource/supabaseUserDataSource/enrichmentService); Mixins
  `on GameRepositoryBase implements GameRepository`. 96 @override byte-identisch verschoben.
  analyze 0/0, 37 Tests grün, CI grün (analyze+test+APK). **Alle 3 Monster-Dateien fertig.**
- **PR #96 test: GameCard-Widget-Tests (10) + GameRepositoryImpl-Fakes (7) + Card-a11y.**
  GameCard in `MergeSemantics`+`Semantics(button)` gewrappt (nur Semantik, kein Visual-Change) →
  labeledTapTarget-Guideline grün. Fakes über IgdbDataSource/NetworkInfo prüfen die Mixin-Seams
  (searchGames delegate/empty/offline, Exception→Failure-Mapping, getPopularGames, id-Validation).
  54 Tests grün gesamt.
- **PR #97 feat(analytics): Umami-Send-Status im Debug-Build loggen.** `[analytics:umami] sent
  "<event>" -> <status>` nur in kDebugMode → Funnel im logcat beobachtbar.
- **✅ FUNNEL END-TO-END LIVE VERIFIZIERT (Emulator, echte Keys):** Debug-APK auf Emulator
  `Medium_Phone_API_36` (headless, -memory 2048) installiert, echter Signup durchgeführt
  (User `ggverify07201649@example.com` in prod-Supabase angelegt), Spiel „Grand Theft Auto VI"
  mit 5.0 bewertet (Rating in Supabase persistiert, UI zeigt es). logcat-Evidenz gegen die
  **live** Umami-Instanz:
  ```
  [analytics:umami] sent "app_open"   -> 200
  [analytics:umami] sent "signup"     -> 200
  [analytics:umami] sent "rate_game"  -> 200
  [analytics:umami] sent "activation" -> 200   # ActivationTracker feuert beim 1. Rating
  ```
  Sentry-native-Backend startet beim Launch (Crash-Reporting live). Screenshots in scratchpad.
> **Gotchas Session 3:**
> - **Emulator-RAM:** Vor Builds `./android/gradlew --stop` + `pkill -f GradleDaemon` → gab hier
>   1,8→5,5 GB frei. Emulator **headless** starten (`emulator @… -no-window -gpu swiftshader_indirect
>   -memory 2048`); **1536 MB Guest OOMt** (lowmemorykiller cascade killt den Emulator). `screencap`
>   liefert unter RAM-Druck sporadisch 0 Bytes → 2–3× retry.
> - **Physisches Gerät (Motorola, wireless) NICHT nutzbar:** hat die release-signierte App bereits
>   installiert → `INSTALL_FAILED_UPDATE_INCOMPATIBLE`; Debug drüber = destruktiver Uninstall der
>   User-App → NICHT gemacht. Emulator ist der saubere Zielort.
> - **UI via adb:** `input tap x y` (Emu-Koord = physische Pixel, hier 1080×2400). Beim Ausfüllen von
>   Passwortfeldern verdeckt die Tastatur das Confirm-Feld → zwischen Feldern `keyevent 4` (IME zu),
>   sonst landet Text im falschen Feld.
> - **🐛 Gefundener Bug (Phase-3-Polish):** Rating-Tile zeigt „50.0/10" statt „5.0/10" (Skalierung ×10
>   im Label). Kosmetisch, nicht funktional — Rating-Wert korrekt gespeichert.
> - **Cleanup-Notiz:** Test-Signup `ggverify07201649@example.com` liegt in prod-Supabase (bei Bedarf löschen).

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
- **`game_bloc.dart`** ✅ fertig & GEMERGT — **PR #94** (2014→5 Dateien, root 505 + 4 part-Extensions,
  alle <800; analyze 0/0, 37 Tests grün, APK-Build grün; KEIN ignore_for_file nötig, da Bloc-Handler
  keine @override-Interface-Methoden sind).
- **`game_repository_impl.dart`** (2540 Z., 96 `@override` `implements GameRepository`): part/extension
  **funktioniert NICHT** (Extension-Methoden erfüllen kein Interface → "Missing concrete implementation";
  auch keine privaten Helfer zum Auslagern). **Lösung: Mixin-Chain mit Getter-Seams.** Konkret geprüft
  (Session 2): die genutzten Felder `igdbDataSource` / `supabaseUserDataSource?` / `enrichmentService?`
  liegen auf `GameRepositoryImpl` selbst; die Basis `IgdbBaseRepository` hat nur `networkInfo` +
  Helfer (`executeIgdbOperation` etc.). Daher `mixin … on IgdbBaseRepository` NICHT ausreichend.
  **Erprobter Bauplan für Session 3:**
  ```dart
  abstract class GameRepositoryBase extends IgdbBaseRepository {
    GameRepositoryBase({required super.networkInfo});
    IgdbDataSource get igdbDataSource;               // Seams
    SupabaseUserDataSource? get supabaseUserDataSource;
    GameEnrichmentService? get enrichmentService;
  }
  mixin _RepoSearch on GameRepositoryBase { /* Methoden ohne @override, nutzen die Getter */ }
  // … weitere mixins je Concern in part-Dateien: part of '../game_repository_impl.dart';
  class GameRepositoryImpl extends GameRepositoryBase
      with _RepoSearch, _RepoDetails, _RepoLists, _RepoByFacet, _RepoBatchUserData, _RepoTaxonomy
      implements GameRepository {
    GameRepositoryImpl({required this.igdbDataSource, required super.networkInfo,
        this.supabaseUserDataSource, this.enrichmentService});
    @override final IgdbDataSource igdbDataSource;   // erfüllt die Getter-Seams
    @override final SupabaseUserDataSource? supabaseUserDataSource;
    @override final GameEnrichmentService? enrichmentService;
  }
  ```
  Mixin-Member erfüllen das `implements GameRepository`. Beim Verschieben in Mixins die `@override`
  an den Methoden BEHALTEN (Mixin implementiert das Interface — `@override` korrekt). Verify: analyze 0/0
  + `flutter test`. Subagent-Versuch brach durch Account-Session-Limit ab (kein Code-Ergebnis, aber
  Interface-Wall bestätigt).

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
- [x] **Umami/Sentry-Keys konfiguriert & LIVE verifiziert** (2026-07-20): `SENTRY_DSN`, `UMAMI_URL`
      (`https://umami.playrackd.com`), `UMAMI_WEBSITE_ID` in lokaler `.env` + als GitHub-Secrets gesetzt.
      Test-Events per curl an beide Endpunkte gesendet → je HTTP 200 akzeptiert (Umami Session/Visit
      vergeben; Sentry Event-ID retour). Werte NICHT hier ablegen (nur GitHub Secrets + gitignored .env).
- [x] **ALLE Keys real gesetzt (2026-07-20):** `SUPABASE_URL` (jmvhqefqjuljrbxlhanf), `SUPABASE_ANON_KEY`,
      `IGDB_CLIENT_ID`, `IGDB_CLIENT_SECRET` in lokaler `.env` + als GitHub-Secrets. `env.g.dart` per
      `dart run build_runner build` neu generiert → App nutzt lokal jetzt echte Backends. Live verifiziert:
      IGDB/Twitch OAuth-Token OK (200), Supabase GoTrue `/auth/v1/health` mit anon-Key OK (200).
      → **Emulator-Lauf & Funnel-End-to-End-Verifikation jetzt möglich.**
- **Security-Fund (2026-07-20, entschärft AUDIT §2.1):** `GET /rest/v1/profiles` als **anon** →
  `42501 permission denied for table profiles`. Unauthentifizierter PII-Zugriff ist blockiert
  (Table-GRANT-Ebene) — das Worst-Case aus dem Audit trifft NICHT zu. Offen: volle RLS-Prüfung für
  Rolle `authenticated` (nächste Session, mit Login-JWT).
- [x] **Refactoring 2/3: game_bloc.dart** (2014→5 Dateien) — PR #94 GEMERGT. part/extension.
- [x] **Refactoring 3/3: game_repository_impl.dart** (2540→root 133 + 6 Mixins) — **PR #95 GEMERGT.**
      Mixin-Chain mit Getter-Seams (part/extension scheitert am Interface). Alle 3 Monster-Dateien fertig.
- [x] **Weitere Tests: Repository-Fakes (7) + GameCard-Widget (10)** — PR #96 GEMERGT. 54 Tests grün.
- [x] **Funnel end-to-end live verifiziert** (Signup→rate_game→activation, je HTTP 200 an live Umami) — s.o.

## ✅ Phase 1 = DONE. Nächste 3 Schritte (Session 4 → Phase 2 Monetarisierung)
1. **⚠️ IGDB-Lizenz-Recherche (BLOCKER für kommerziellen Launch):** IGDB/Twitch gratis nur nicht-
   kommerziell. Optionen recherchieren (kommerzielle IGDB-Vereinbarung vs. RAWG/MobyGames-Hybrid),
   dem User mit Empfehlung vorlegen. Datasource ist bereits abstrahiert (Adapter-Seam sauber halten).
2. **IAP-Infrastruktur:** RevenueCat (`purchases_flutter`) — Abo „GamerGrove Pro" (2,99 €/M · 19,99 €/J,
   User-Entscheid steht). Key-gated bauen (no-op ohne Keys). RevenueCat-Account + Play-Console-Produkte =
   User-Aktion (bündeln).
3. **`EntitlementService`-Interface + Free/Pro-Schnitt** (Vorschlag in MASTERPLAN Phase 2) + Paywall-Screen.
   Danach Security-Review über den Payment-/Entitlement-Pfad.

> **Session-3-Ende-Notiz:** **3 PRs gemergt (#95–#97) → Phase 1 KOMPLETT.** Alle 3 Monster-Dateien
> refaktoriert (je <800 Z.), erste Widget-/Repo-Tests da (54 grün), Funnel end-to-end auf dem Emulator
> gegen live Umami/Sentry verifiziert (app_open/signup/rate_game/activation je 200; Screenshots in
> scratchpad). Master grün. **Offene User-Items für Phase 2:** IGDB-Lizenz-Entscheid (nach Recherche),
> RevenueCat-Account + Store-Produkte. **Session 4 Start:** `git reset --hard origin/master`, dann
> Phase-2-IGDB-Lizenz-Recherche.

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
