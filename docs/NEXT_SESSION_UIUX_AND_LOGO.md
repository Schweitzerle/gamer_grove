# Prompt für die nächste Session — UI/UX-Overhaul + eigenes App-Logo

> Diesen Text als erste Nachricht in eine neue Session geben.

---

Du bist in `~/Documents/Stuff/StudioProjects/gamer_grove`. Lies zuerst
`PROGRESS.md` und `MASTERPLAN.md`. Die App ist funktional fertig und liegt als
versionCode 15 im Play-Internal-Track; Phase 2 (Monetarisierung) ist live und
verifiziert. Diese Session dreht sich **ausschließlich um Gestaltung**: ein
eigenes App-Logo und ein UI/UX-Overhaul. Keine neuen Features.

## Was GamerGrove ist

Eine Flutter-App (Material 3, FlexColorScheme, Clean Architecture, BLoC), mit
der Nutzer ihr Gaming-Leben festhalten: Spiele bewerten, Wunschliste,
Empfehlungen, eine **Top 3**, eigene **Sammlungen** ("Cozy games",
"Backlog 2026"), anderen Nutzern folgen, Aktivitäten-Feed. Der Home-Screen heißt
**Grove**. Free-Tier mit 3 Sammlungen, GamerGrove Pro hebt das Limit auf und
schaltet Statistiken, Filter und Themes frei.

Spieldaten kommen von IGDB. Der Name ist die Erzählung: ein *Grove* ist ein
Hain — eine kleine, gepflegte Ansammlung von Bäumen. Der Nutzer zieht seine
Spielesammlung heran und pflegt sie. Das ist der inhaltliche Anker, an dem
Logo und Gestaltung hängen sollten.

## Teil 1 — App-Logo

### Das Vorbild: LifeLoop

In `~/Documents/Stuff/StudioProjects/life_loop` liegt ein Icon, das genau so
entstanden ist, wie es hier auch laufen soll. Schau dir an:

- `assets/icon/app_icon.png` — das Ergebnis: ein Stapel Polaroid-Karten mit
  aufgehender Sonne dahinter, warmes Amber auf dunklem Braun.
- `tool/icon/README.md` — der Prozess, inklusive Palette und Regenerierungs-Befehlen.
- `tool/icon/render.js` — **die eigentliche Quelle**: handgeschriebenes SVG in
  JavaScript, rasterisiert mit `@resvg/resvg-js` in alle Launcher-Layer.

Das Prinzip dahinter, und darauf kommt es an:

1. **Ein benanntes Konzept, das die Geschichte der App erzählt.** Bei LifeLoop
   heißt es "Golden Hour": das Daumenkino der Tage plus die Sonne — das Leben mit
   der Sonne. Nicht Dekoration, sondern Aussage.
2. **Handgeschriebener Vektor als Single Source of Truth**, versioniert im Repo.
   Kein generiertes Bild-Blob, das niemand mehr ändern kann.
3. **Alle Layer aus derselben Quelle**: Voll-Icon, Adaptive Background, Adaptive
   Foreground, **Monochrome** (für Android-13-Themed-Icons), Splash-Logo.
4. **Festgeschriebene Palette**, im README dokumentiert.

### Was am aktuellen GamerGrove-Icon nicht stimmt

`assets/icon/app_icon.png` ist mit Gemini-Bildgenerierung entstanden: ein
neonfarbenes "G" aus geometrischen Fragmenten mit Platinen-Linien, Violett/
Magenta/Cyan auf fast schwarzem Sternenhimmel. Die Probleme sind konkret:

- **Haarlinien.** Die Konturen sind 2–3 px bei 1024 px. Auf einem
  48-dp-Launcher-Icon wird daraus Grau-Matsch.
- **Adaptive Icon falsch verdrahtet.** In `pubspec.yaml` zeigen
  `image_path` *und* `adaptive_icon_foreground` auf dasselbe PNG, dazu
  `adaptive_icon_background: "#1A1A1A"`. Das Motiv füllt aber die ganze Fläche —
  Android beschneidet Adaptive Icons auf eine Safe Zone von ~66 %, das "G" wird
  also angeschnitten. Und der eigene dunkle Hintergrund des PNGs liegt doppelt
  über der Hintergrundfarbe.
- **Kein Monochrome-Layer**, also fällt Android 13+ bei Themed Icons auf einen
  schlechten Automatismus zurück.
- **Kein Splash-Logo**, `flutter_native_splash` ist gar nicht eingerichtet.
- **Inhaltlich beliebig.** "Neon + Gamepad + Platine" ist das Klischee schlechthin
  und sagt nichts über einen *Hain*, über Sammeln, Pflegen, Wachsen.

### Auftrag

Entwickle ein eigenes Konzept, das den Namen ernst nimmt — Wachstum, Sammlung,
Pflege, vielleicht Jahresringe, Blätterschichten, ein Hain aus Karten. Gib ihm
einen Namen wie "Golden Hour". Zeig mir **2–3 klar unterschiedliche Richtungen**
als gerenderte PNGs, bevor du eine ausbaust — nicht Varianten derselben Idee,
sondern echte Alternativen. Ich entscheide dann.

Danach die gewählte Richtung wie bei LifeLoop aufbauen:
`tool/icon/render.js` + `tool/icon/README.md` mit Palette, alle Layer inklusive
Monochrome, `flutter_launcher_icons` korrekt konfiguriert (getrennte
Background-/Foreground-Layer, Motiv innerhalb der Safe Zone),
`flutter_native_splash` einrichten.

**Prüfe das Ergebnis in echten Größen**, nicht nur bei 1024 px: rendere
48/72/96/192 dp und schau, ob es dort noch lesbar ist. Das ist der Test, an dem
das aktuelle Icon scheitert.

## Teil 2 — UI/UX-Overhaul

Die Screens sind funktional, aber gestalterisch zusammengewachsen. Lies vorher
`~/.claude/rules/design/*` und `~/.claude/rules/flutter/*`; die Anti-Template-
Regeln und die WCAG-2.2-AA-Latte gelten.

Auffälligkeiten, von denen du ausgehen kannst — verifiziere sie selbst:

- Der Home-Screen (`lib/presentation/pages/grove/grove_page.dart`) ist eine
  Abfolge gleich aussehender Card-Sections (`SectionFrame`) ohne Hierarchie. Die
  Top 3 sollten die Bühne sein, nicht eine Zeile unter vielen.
- Kein Theme-Anker: `FlexScheme.material` ist der Default, es gibt keine eigene
  Markenfarbe und keine Design-Tokens. Nach dem Logo sollte das Farbschema daraus
  abgeleitet werden.
- Typografie ist durchgehend Default-Roboto ohne Skala und ohne Kontrast.
- `lib/presentation/widgets/sections/` enthält Dateien mit über 800 Zeilen und
  viel Wiederholung — beim Anfassen gern aufteilen.
- Empty States und Ladezustände sind uneinheitlich (teils Spinner, teils
  Shimmer, teils nichts).

Geh in Etappen und lass mich zwischendurch schauen: erst Tokens und Theme, dann
der Home-Screen, dann die Detailseiten. Ein PR pro Etappe.

## Regeln für diese Session

- **Vor Code:** Richtung festlegen, Referenzen zeigen, meine Entscheidung
  abwarten. Bei Gestaltung will ich mitreden, nicht das Ergebnis vorgesetzt
  bekommen.
- **Goldens und Semantics-Tests sind Pflicht** für alles Sichtbare
  (`~/.claude/rules/flutter/testing.md`). Bei Theme-Änderungen erst die Golden-
  Diffs anschauen, dann committen.
- `flutter analyze` muss auf **0 errors / 0 warnings** bleiben (Infos existieren
  im Bestand, die Zahl darf nicht steigen), `flutter test` grün. Aktuell:
  139 Tests.
- Ein PR pro logischem Block, Conventional Commits, nach grünem CI autonom
  mergen (Standing Authorization).
- **Kein AAB bauen und nichts in den Store hochladen**, bis ich es sage.
- Force-Push ist vom Harness geblockt — Stacked PRs nicht rebasen, sondern
  frische Branches von master + cherry-pick.

## Stand der Technik

- `flutter analyze` 0/0, `flutter test` 139 grün, master ist aktuell.
- versionCode 15 im Internal Track, funktional vom Nutzer abgenommen.
- Legal-Dokumente liegen fertig in `assets/legal/` (Datenschutz DE/EN,
  Impressum) und werden in den Settings verlinkt. Offen ist nur noch AGB.
- Release-Builds sind **nicht obfuskiert** — offener Punkt, siehe `PROGRESS.md`,
  gehört aber nicht in diese Session.
