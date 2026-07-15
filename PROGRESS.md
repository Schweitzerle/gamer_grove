# PROGRESS — GamerGrove Polish → Startup

> Resume protocol: read this file, then `MASTERPLAN.md`, then continue the first
> unchecked item. Standing Authorization gilt (autonom committen/pushen/PR/merge
> nach grünem CI). Fragen an den User werden gebündelt gesammelt (Abschnitt unten).

**Last updated:** 2026-07-15 (Session 1)
**Current branch:** `chore/phase0-baseline`
**Current phase:** ✅ Phase 0 COMPLETE · Phase 1 IN PROGRESS

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
- [x] CI-Pipeline (`.github/workflows/ci.yml`): format → analyze → test+coverage → build apk.
- [x] Erste Kern-Tests: AuthBloc (11 bloc_test-Cases, grün). mocktail + fixtures angelegt.
- [x] Entrümpeln Teil 1: 4173 LOC Dead Code gelöscht (deprecated/, social/, examples, scratch).
- [ ] Branch pushen + CI auf GitHub grün sehen, dann nach master mergen.
- [ ] Sentry (crash) + PostHog EU (analytics) einbauen, Event-Schema.
- [ ] Weitere Entrümpelung: ~95 Orphan-Kandidaten via unused-files-Pass verifizieren (AUDIT.md §4).
- [ ] Weitere Tests: UserGameDataBloc, GameBloc, Repository-Fakes, GameCard-Widget.
- [ ] Refactoring Monster-Dateien (filter_bottom_sheet, game_repository_impl, game_bloc).
- [ ] 6 echte analyze-Warnings fixen (WebsiteType==WebsiteCategory-Bug etc.).

## Nächste 3 Schritte
1. Remote prüfen/`chore/phase0-baseline` pushen → CI-Run auf GitHub verifizieren → nach master mergen.
2. Sentry + PostHog EU integrieren (DSN/Key via env + GitHub Secrets), Funnel-Events definieren.
3. Unused-files-Pass + nächste Bloc-Tests (UserGameDataBloc, GameBloc).

## Offene Entscheidungen für den User (gebündelt — siehe MASTERPLAN §"Offene Entscheidungen")
1. **Pricing** Pro: Default-Vorschlag 3,99 €/Monat · 24,99 €/Jahr.
2. **IGDB kommerziell vs. Alternative** (Recherche folgt in Phase 2).
3. **Accounts/Geld**: RevenueCat, Sentry, PostHog (Free Tiers), Play Console / App Store.
4. **Launch-Reihenfolge**: Default Android zuerst, iOS 2–4 Wochen später.
5. Store-Publishing bleibt bestätigungspflichtig.

## Branch-/Merge-Status
- `chore/phase0-baseline` — 2 Commits, noch nicht gepusht/gemerged (CI existiert noch
  nicht; wird mit Phase-1-CI zusammen grün gemacht, dann Merge nach master).
