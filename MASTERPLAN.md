# GamerGrove — Masterplan: Polish → Monetarisierbares Startup-Produkt

> Dieses Dokument ist der Arbeitsauftrag für Claude-Code-Sessions. Es wird zusammen mit
> `PROGRESS.md` gepflegt. Jede Session: erst `PROGRESS.md` lesen, dann hier die nächste
> offene Phase abarbeiten. Standing Authorization aus der globalen CLAUDE.md gilt:
> autonom committen, pushen, PRs, mergen nach grünem CI — nicht auf "go" warten.

## Produktkontext

- **App:** GamerGrove — Discover, rate & recommend videogames. Gaming-Social-Plattform
  (Profile, Follows, Activity Feed, Wishlist, Ratings, Top-3, Leaderboard).
- **Stack:** Flutter (Android/iOS primär), Clean Architecture, BLoC, get_it, Supabase
  (Auth + DB + RLS), IGDB API (Spieledaten), envied für Secrets.
- **Stand bei Planerstellung (2026-07-15):** v2.0.2+5, 521 Dart-Dateien / ~95k LOC,
  funktional weitgehend fertig, aber: keine Tests, kein CI, keine Analytics/Crash-
  Reporting, keine Monetarisierung, mehrere Dateien >2000 Zeilen, 69 TODOs,
  deprecated Code im Tree (`lib/data/datasources/remote/supabase/deprecated/`).

## Ziel

Aus der funktionierenden App ein **poliertes, monetarisierbares, launchfähiges Produkt**
machen: Freemium-Modell, sauberes Fundament (Tests/CI/Observability), App-Store-ready,
Startup Mode (§13 der globalen Regeln) vollständig umgesetzt.

## Arbeitsweise (agentic — verbindlich)

1. **Explore → Plan → Execute → Verify** pro Phase. Vor jeder Phase mit parallelen
   **Explore-Subagenten** den relevanten Code kartieren (Kontext sauber halten, keine
   Riesen-Dateien in den Hauptkontext ziehen).
2. **Parallelisieren:** Unabhängige Workstreams (z. B. Refactoring einzelner Riesen-
   Dateien, Test-Suites für verschiedene Blocs) an parallele Subagenten geben, ggf. mit
   Worktree-Isolation. Ergebnisse selbst reviewen und mergen.
3. **Review-Gates:** Nach jedem Feature-Block Code-Review-Pass (`/code-review`); vor
   Commits mit Auth-/Payment-/User-Daten-Bezug zusätzlich Security-Review-Pass.
4. **Checkpoints:** Kleine konventionelle Commits auf Feature-Branches; `PROGRESS.md`
   nach jedem Meilenstein aktualisieren (Stand, nächste 3 Schritte, Gotchas). Jede
   Session muss von einem frischen Agenten mit "lies PROGRESS.md und mach weiter"
   fortsetzbar sein.
5. **Evidenz statt Behauptung:** `flutter analyze`, `flutter test`, Build-Logs, App
   real starten (Emulator) und Flows durchklicken/screenshotten. Nie "fertig" ohne
   beobachteten Beweis.
6. **Fragen bündeln:** Nutzerentscheidungen (unten, "Offene Entscheidungen") gesammelt
   mit empfohlenem Default stellen und parallel an allem Nicht-Blockierten weiterarbeiten.

---

## Phase 0 — Baseline & Audit (zuerst, ~1 Session)

- [ ] `flutter pub get`, `flutter analyze`, `dart format --set-exit-if-changed .`,
      `flutter build apk --debug` — Ist-Zustand dokumentieren (Fehler-/Warnungszahl).
- [ ] `PROGRESS.md` anlegen (Stand, Phasenstatus, Gotchas).
- [ ] Parallele Explore-Agenten: (a) Architektur-Karte Blocs/Repos/Datasources,
      (b) Supabase-Schema + RLS-Policies aus `SupabaseScripts/` rekonstruieren,
      (c) TODO/FIXME-Inventar mit Priorisierung, (d) Dead Code / deprecated Inventar.
- [ ] Security-Quickcheck: RLS auf allen Tabellen? Anon-Key-Scope ok? Keine Secrets im
      Repo? IGDB-Token-Handling (Client-Secret im Client ist ein Problem — prüfen, ob
      ein Supabase-Edge-Function-Proxy nötig ist → Ticket für Phase 2).

## Phase 1 — Fundament: CI, Observability, Kern-Tests, Entrümpelung

- [ ] **CI (GitHub Actions):** lint → format-check → analyze → test → build (apk).
      Muss grün sein, bevor irgendein weiterer Merge passiert.
- [ ] **Crash-Reporting:** Sentry (`sentry_flutter`) einbauen, DSN via env.
- [ ] **Analytics:** PostHog EU (`posthog_flutter`), datensparsam; Event-Schema
      definieren: `app_open`, `signup`, `activation` (s. Phase 4), `rate_game`,
      `wishlist_add`, `follow_user`, `paywall_view`, `purchase_start`, `purchase_done`.
- [ ] **Entrümpeln:** `deprecated/`-Datasource löschen, tote Imports/Code entfernen,
      TODO-Inventar abarbeiten oder als Issues externalisieren.
- [ ] **Refactoring der Monster-Dateien** (parallele Subagenten, je eine Datei,
      Verhalten identisch halten, danach Review):
      - `lib/presentation/widgets/filter_bottom_sheet.dart` (3251 Z.)
      - `lib/data/repositories/game_repository_impl.dart` (2516 Z.)
      - `lib/presentation/blocs/game/game_bloc.dart` (2014 Z.)
      - weitere >800-Zeilen-Dateien nach Inventar aus Phase 0.
- [ ] **Kern-Tests (pragmatisch, nicht dogmatisch 80 % auf Altcode):** bloc_test für
      Auth-, UserGameData-, Game-Bloc; Repository-Tests mit Fakes; Widget-Tests für
      GameCard + kritische Screens. Neue Features ab jetzt strikt mit Tests (TDD).
      Coverage-Report in CI.

## Phase 2 — Monetarisierung (Kern der Mission)

- [ ] **⚠️ IGDB-Lizenz klären (BLOCKER für kommerziellen Launch):** IGDB/Twitch-API ist
      gratis nur für nicht-kommerzielle Nutzung. Optionen recherchieren und dem User
      vorlegen: (a) kommerzielle IGDB-Vereinbarung anfragen, (b) Wechsel/Hybrid mit
      alternativer Quelle. Technisch vorbereiten: Datasource ist bereits
      abstrahiert — Adapter-Seam sauber halten.
- [ ] **IAP-Infrastruktur:** RevenueCat (`purchases_flutter`) — Abo "GamerGrove Pro"
      (monatlich/jährlich) + Sandbox-Testing auf beiden Plattformen. RevenueCat-Account
      & Store-Produkte = Nutzeraktion (unten gebündelt anfragen).
- [ ] **Free/Pro-Schnitt implementieren** (Vorschlag, User entscheidet final):
      Free: alles Soziale + Rating + Wishlist (Netzwerkeffekt nie paywallen).
      Pro: erweiterte Statistiken/Insights, unbegrenzte Custom Collections, erweiterte
      Filter/Sortierung, Profil-Customization (Themes/Badges), werbefrei falls später
      Ads. Feature-Gating über ein zentrales `EntitlementService`-Interface.
- [ ] **Paywall:** ein gut designter Paywall-Screen (kein Template-Look), Trigger an
      natürlichen Upgrade-Momenten; Events instrumentiert.
- [ ] **Server-seitig:** Entitlements in Supabase spiegeln (RevenueCat-Webhook →
      Edge Function → `profiles`/`subscriptions`-Tabelle, RLS-geschützt).
- [ ] Security-Review-Pass über den gesamten Payment-/Entitlement-Pfad.

## Phase 3 — Produkt-Polish

- [ ] **Onboarding & Activation:** Activation-Event definieren (Vorschlag: "erstes
      Spiel bewertet ODER 3 Spiele auf Wishlist + 1 Follow"). Onboarding-Flow darauf
      trimmen (max. 3–5 Schritte: Lieblings-Genres → 3 Spiele bewerten → Leuten folgen).
      Time-to-value messen.
- [ ] **UI-Polish-Pass:** Konsistenz-Audit (Spacing, Typo, Empty States, Error States,
      Loading/Shimmer überall wo nötig), beide Themes, kleine Screens (320dp) ohne
      Overflow, Touch-Targets ≥44px.
- [ ] **Performance:** Startzeit, Bildcaching, Listen-Performance (DevTools-Profile
      als Evidenz), Offline-Verhalten der wichtigsten Screens.
- [ ] **Retention-Hooks:** Push-Notifications (neue Follower, Freundes-Aktivität,
      Release-Reminder für Wishlist-Spiele — letzteres ist ein Killer-Feature),
      wöchentlicher Digest. D1/D7/D30-Retention in PostHog.

## Phase 4 — Startup Mode: Launch & Business

- [ ] **Landing Page** (separates Mini-Projekt, SSG, SEO+GEO nach §13b): Value Prop
      "Track, rate & share your gaming life", Screenshots, Store-Badges, E-Mail-Waitlist
      für iOS falls Android zuerst; Impressum + Datenschutz.
- [ ] **Legal (DE/EU):** Datenschutzerklärung (Supabase, IGDB, PostHog, Sentry,
      RevenueCat als Empfänger), Impressum, AGB/ToS (Accounts + UGC + Abo), Account-
      Löschung in-App (Store-Pflicht + Art. 17), Altersfreigabe prüfen.
- [ ] **ASO:** Store-Listing (Titel/Keywords/Beschreibung DE+EN), Screenshot-Set,
      Feature-Grafik; Release mit `--obfuscate --split-debug-info`.
- [ ] **Launch-Playbook:** 3–5 Kanäle wo Gamer sind (r/gamecollecting, r/patientgamers,
      Backloggd/GG-Communities, Product Hunt, deutsche Gaming-Discords); ein klarer
      Launch-Post; Feedback-Loop in-App.
- [ ] **Unit Economics dokumentieren:** Preisannahme, Conversion-Annahme (~2–4 %
      Free→Pro), Break-even-Nutzerzahl, laufende Kosten (Supabase, RevenueCat, Stores).

## Offene Entscheidungen für den User (gebündelt stellen, mit Default)

1. **Pricing:** Vorschlag 3,99 €/Monat, 24,99 €/Jahr für Pro. (Betrag = Userentscheid)
2. **IGDB kommerziell vs. Alternative** — sobald Recherche aus Phase 2 vorliegt.
3. **Accounts/Geld:** RevenueCat-Account, App Store/Play Console Zugänge,
   Store-Produkte anlegen, Sentry/PostHog-Accounts (Free Tiers reichen initial).
4. **Launch-Reihenfolge:** Android zuerst (vorhandene Pipeline) vs. beide gleichzeitig.
   Default: Android zuerst, iOS 2–4 Wochen später.
5. Store-Publishing selbst ist laut Standing Authorization **immer** bestätigungspflichtig.

## Definition of Done (Gesamtmission)

- CI grün (analyze, format, tests, build); Kern-Flows getestet; keine Datei >800 Zeilen
  in den refaktorierten Bereichen; kein deprecated Code.
- Sentry + PostHog live mit definiertem Funnel (visit→signup→activation→paid).
- Kauf-Flow end-to-end im Sandbox-Modus verifiziert (Evidenz: Screenshots/Logs).
- Onboarding führt messbar zum Activation-Event.
- Landing Page live, Legal-Seiten vorhanden, Store-Listing vorbereitet.
- `PROGRESS.md` aktuell; ehrlicher Abschlussreport mit offenen Punkten.
