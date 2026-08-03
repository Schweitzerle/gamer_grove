# Play-Eintrag — Entwurf

Der laufende Eintrag stammt von versionCode 5 und beschreibt eine App ohne
Sammlungen, ohne Pro und ohne das Lichtsystem. Hier steht, was er sagen soll;
eingetragen wird er erst nach Freigabe.

Sprache: **en-US**, wie der bestehende Eintrag und wie die App. Ein deutscher
Eintrag wäre eine eigene Entscheidung — er lohnt sich für den Heimatmarkt, aber
er verdoppelt jede spätere Änderung.

---

## Titel (30 Zeichen)

```
GamerGrove
```

Unverändert. Der Name trägt.

## Kurzbeschreibung (80 Zeichen)

Die eine Zeile, die in der Suchliste unter dem Icon steht — die meisten Leute
lesen nur sie.

```
Rate games, keep your shelves, and see what your people are playing.
```

*68 Zeichen.* Drei Verben, drei Dinge, die die App wirklich tut. Der laufende
Text („Discover games, track your collection, and connect with friends") sagt
dasselbe in der Sprache jedes anderen Katalogs.

## Vollständige Beschreibung (4000 Zeichen)

Zuerst die Antwort, dann die Belege — dieselbe Regel wie für jede Seite, die
gelesen und nicht studiert wird.

```
Your games, in a place that feels like yours.

GamerGrove is a catalogue for people who play a lot and remember little.
Rate what you finish, keep what you mean to start, and put the three you
would defend at a party right at the top.

YOUR TOP 3
Three games stand at the head of your Grove, in depth rather than in a row.
Not a list of favourites — a statement.

YOUR OWN SHELVES
Collections you name yourself. "Cozy games". "Backlog 2026". "Games I owe my
friend an opinion on." Three are free; Pro removes the limit.

EVERY GAME, IN FULL
Ratings and reviews from the community, screenshots and trailers, the studio
behind it, the platforms it runs on, what it is a sequel to, and what it is
related to. Data from IGDB, one of the largest game databases there is.

FILTERS THAT MEAN SOMETHING
Genre, platform, game mode, player perspective, release window, rating range.
Find the co-op game your friend can also run, not just the popular one.

PEOPLE, NOT FEEDS
Follow the people whose taste you trust. See what they rated and what stands
in their Top 3. No algorithm decides what you notice.

GAMERGROVE PRO
Deep statistics about what you actually play, advanced filters, unlimited
collections, and colour themes. Monthly or yearly through Google Play, and
cancellable there at any time.

Made in Germany. No ads, no tracking of what you play for anyone else's
benefit, and an account you can delete from inside the app in two taps.

GamerGrove uses the IGDB API but is not endorsed or certified by IGDB.
```

> **Warum so:** Der erste Satz ist die Antwort auf „was ist das", der zweite
> nennt die Person, die es braucht. Die Blöcke sind Großbuchstaben statt
> Emoji-Überschriften, weil Play die Beschreibung auch als Fließtext in
> Suchergebnisse zieht. Der letzte Absatz beantwortet die drei Fragen, die
> Leute bei einer unbekannten App stellen — Werbung, Daten, Rauskommen.
> Die IGDB-Zeile ist Pflicht.

## Was noch fehlt

- **Screenshots** — fünf, aus Build 41 mit dem Marken-Theme. Rahmen steht:
  1080×1920, das Dither-Raster der App als Grund, Bricolage-Überschrift,
  kein Geräterahmen.
- **Icon (512×512)** — das alte neon-lila „G" muss durch das Pixel Portal
  ersetzt werden. Quelle: `tool/icon/render.js`.
- **Feature-Graphic (1024×500)** — ebenfalls vom alten Stand.
- **Data-Safety-Erklärung** — RevenueCat, Sentry und Umami sind seit
  versionCode 5 dazugekommen und stehen noch nicht drin. Nur in der Console
  zu pflegen, nicht über die API.
