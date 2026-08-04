# Start-Prompt: Audit & Produktreife

Für eine frische Session nach dem Store-Launch. Alles zwischen den Linien
kopieren und als erste Nachricht einfügen.

---

Du übernimmst GamerGrove nach dem Store-Launch. Ich will kein Weiterbauen,
sondern erst einen **ehrlichen Kassensturz**: Was ist wirklich da, was ist
brüchig, und was fehlt dem Ding, um mehr als eine gut gebaute App zu sein.

## Stand

Flutter-App (Material 3, Clean Architecture, BLoC, Supabase, IGDB über eigenen
Proxy, RevenueCat). Android only. `master` ist grün.

- Build 42 liegt in internal, alpha und beta. **Produktion steht noch auf
  versionCode 5** — die Freigabe kommt von mir, nicht von dir.
- 462 Dart-Dateien, ~88k Zeilen, 59 Testdateien.
- Live-Telemetrie existiert und läuft: Umami (selbst gehostet, elf Ereignisse
  aus `analytics_events.dart`) und Sentry. **Beide haben echte Daten.**
- `PROGRESS.md` endet bei Session 3/4 und ist damit grob veraltet. Nimm es als
  Historie, nicht als Zustandsbeschreibung.
- Offene Punkte, die ich schon kenne — du musst sie nicht erst finden:
  sieben Dateien über 800 Zeilen, hartkodierte Farben statt Tokens, rund 40
  nackte `CircularProgressIndicator`, Issue #157 (Profilbild entfernen),
  IGDB-Secret-Rotation steht nach dem Produktions-Rollout aus.

## Was ich am Ende haben will

**Ein Dokument** (`docs/AUDIT_2026.md`) und **daraus abgeleitete GitHub-Issues**
mit Labels und Priorität. Kein Code in dieser Runde, außer ich sage es.

Das Dokument hat zwei Hälften:

**1. Zustand.** Was in diesem Projekt tatsächlich der Fall ist — Architektur,
Testabdeckung dort wo sie zählt, Sicherheit (Auth, RLS, Entitlement-Pfad,
Edge Functions), Performance auf echten Geräten, Barrierefreiheit, tote Ecken.
Jeder Fund mit **Severity und Confidence**, und mit der Stelle im Code. Nenne
auch die unsicheren — filtern und priorisieren machen wir danach gemeinsam,
nicht du still für dich. Was gut ist, darf ebenfalls dastehen; ein Audit, das
nur Mängel kennt, ist keine Beschreibung des Projekts.

**2. Produkt.** Hier will ich, dass du weiterdenkst als ich:

- Wofür steht die App in einem Satz, und hält der Rest des Produkts diesen Satz?
- **Schau in die echten Umami-Daten**, nicht in Annahmen: Wo brechen Leute ab,
  was ist das Aktivierungsereignis, wird es erreicht, wie schnell? Wenn die
  Ereignisse die Frage nicht beantworten können, ist *das* der Fund.
- Warum sollte jemand am siebten Tag wiederkommen? Retention ist bei einer
  Katalog-App die eigentliche Frage, nicht die Installation.
- Pro kostet 2,99 €/Monat. Ist das, was drinsteckt, diesen Preis wert, und ist
  der Auslöser zum Upgrade an der richtigen Stelle?
- Feature-Vorschläge: wenige, begründet, jeder mit dem Satz „das löst folgendes
  Problem". Ordne sie nach Aufwand gegen erwartete Wirkung. Sag auch, was du
  **nicht** bauen würdest und warum — das ist meist die nützlichere Liste.

## Wie du arbeitest

- **Erst verstehen, dann urteilen.** Für die breiten Durchgänge durch viele
  Dateien nutz Subagenten (Explore), damit dein eigener Kontext sauber bleibt;
  für alles, was du in ein paar Werkzeugaufrufen selbst siehst, mach es selbst.
- **Recherchiere, statt zu raten.** Wenn eine Aussage von einer Google-Play-
  Regel, einer Paketversion oder einem API-Verhalten abhängt: nachschlagen. Ich
  habe in diesem Projekt schon zwei Ablehnungen dafür kassiert, dass etwas aus
  dem Gedächtnis geschrieben wurde.
- **Belege statt Behauptungen.** „Läuft" heißt: ausgeführt und gesehen.
  Testausgabe, Analyse-Ausgabe, Query-Ergebnis. Wo du etwas vermutest, schreib
  hin, dass du es vermutest.
- Widersprich mir. Wenn eine meiner Prioritäten oder eine bestehende
  Entscheidung im Projekt falsch ist, sag es mit Begründung.

## Grenzen

- `flutter analyze` bleibt bei 0 Fehlern / 0 Warnungen, `flutter test` grün.
- Goldens und Semantics-Tests sind Pflicht für alles Sichtbare.
- **Gestaltung stimmst du vorher mit mir ab** — Richtung, Referenzen, meine
  Entscheidung, dann Code. Nicht das Ergebnis vorsetzen.
- Ein PR pro logischem Block, Conventional Commits, nach grünem CI autonom
  mergen. Force-Push ist geblockt: gestapelte Branches nicht rebasen, sondern
  frisch von master + cherry-pick.
- Produktions-Rollout und alles, was Geld kostet oder Konten anlegt: fragen.
- Sprache in der App ist Englisch, Rechtstexte bleiben Deutsch.

Fang mit dem Zustandsteil an. Wenn du dabei etwas findest, das den laufenden
Store-Review gefährdet, unterbrich und sag es sofort.

---

## Warum der Prompt so gebaut ist

- **Der Stand steht oben, samt der Mängel, die ich schon kenne.** Sonst
  verbringt die Session ihre erste Stunde damit, mir Dinge zu berichten, die in
  dieser Datei stehen — und hält das für Ertrag.
- **„Nenne auch die unsicheren Funde."** Ein Review-Auftrag, der um
  Zurückhaltung bittet („nur Wichtiges", „keine Kleinigkeiten"), wird wörtlich
  genommen: das Modell findet den Fehler und behält ihn für sich. Erst alles
  einsammeln, dann in einem zweiten Durchgang aussortieren.
- **Severity *und* Confidence.** Ohne Confidence steht eine Vermutung neben
  einem Beweis und sieht gleich aus.
- **„Was gut ist, darf dastehen."** Ein Prüfer, der Probleme finden soll,
  findet immer welche. Ohne Gegengewicht führt das dazu, dass funktionierende
  Dinge umgebaut werden.
- **Der Verweis auf die echten Umami-Daten** ist der Kern des zweiten Teils.
  Produktfragen aus dem Code zu beantworten ergibt Plausibles; die Ereignisse
  sagen, was Leute tatsächlich tun.
- **Kein Code in dieser Runde.** Ein Audit, das nebenbei repariert, hört nach
  dem dritten Fund auf, ein Audit zu sein.
- **Die Grenzen am Ende, nicht am Anfang.** Sie sind Randbedingungen, keine
  Aufgabe — vorne würden sie den Auftrag überdecken.
