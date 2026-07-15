# PROGRESS — GamerGrove Polish → Startup

> Resume protocol: read this file, then `MASTERPLAN.md`, then continue the first
> unchecked item. Standing Authorization gilt (autonom committen/pushen/PR/merge
> nach grünem CI). Fragen an den User werden gebündelt gesammelt (Abschnitt unten).

**Last updated:** 2026-07-15 (Session 1)
**Current branch:** `chore/phase0-baseline`
**Current phase:** Phase 0 (Baseline & Audit) — near complete

---

## TL;DR State

- Baseline ist **grün gemacht**: `flutter analyze` 0 errors, Debug-APK baut, Codegen läuft.
- Zwei Baseline-Commits auf `chore/phase0-baseline`:
  1. `chore: fix build baseline (codegen, gradle JDK, analyzer config)`
  2. `style: apply dart format to entire codebase` (439 Dateien, mechanisch)
- 4 Explore-Agenten liefen zur Kartierung (Architektur, Supabase/RLS, TODO-Inventar,
  Dead Code). Ergebnisse werden unten eingetragen.

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

## Nächste 3 Schritte
1. Explore-Agenten-Ergebnisse hier einpflegen (Architektur/RLS/TODO/DeadCode) + Security-Quickcheck abschließen → **Phase 0 abhaken**.
2. Phase 1 starten: **GitHub Actions CI** (format-check → analyze → test → build apk) als erstes Gate.
3. Sentry + PostHog EU einbauen (DSN/Key via env), Event-Schema definieren.

## Offene Entscheidungen für den User (gebündelt — siehe MASTERPLAN §"Offene Entscheidungen")
1. **Pricing** Pro: Default-Vorschlag 3,99 €/Monat · 24,99 €/Jahr.
2. **IGDB kommerziell vs. Alternative** (Recherche folgt in Phase 2).
3. **Accounts/Geld**: RevenueCat, Sentry, PostHog (Free Tiers), Play Console / App Store.
4. **Launch-Reihenfolge**: Default Android zuerst, iOS 2–4 Wochen später.
5. Store-Publishing bleibt bestätigungspflichtig.

## Branch-/Merge-Status
- `chore/phase0-baseline` — 2 Commits, noch nicht gepusht/gemerged (CI existiert noch
  nicht; wird mit Phase-1-CI zusammen grün gemacht, dann Merge nach master).
