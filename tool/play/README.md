# Play Developer API — die drei Skripte

Sie lagen zweimal im Scratchpad und waren zweimal weg, wenn die Session endete.
Deshalb hier.

## Einrichten

Der Dienstkonto-Schlüssel liegt **außerhalb des Repos** unter
`~/gg-play-sa.json`; ein anderer Pfad geht über `GG_PLAY_SA`.

```bash
python3 -m venv /tmp/playenv
/tmp/playenv/bin/pip install google-auth google-api-python-client
```

## Die Skripte

**`tracks.py`** — liest, was gerade auf welcher Spur liegt, und welche
Versionscodes schon vergeben sind. Nur lesend, ändert nichts.

```bash
/tmp/playenv/bin/python tool/play/tracks.py
```

**`play.py`** — lädt ein AAB hoch und legt es auf die genannten Spuren.
**Verweigert `production`.**

```bash
/tmp/playenv/bin/python tool/play/play.py build/app/outputs/bundle/release/app-release.aab \
    internal alpha beta -- "Release notes"
```

**`promote.py`** — schiebt einen **bereits hochgeladenen** Versionscode auf die
Produktionsspur, zu 100 %. Kein neuer Build: was in die Produktion geht, ist
byteweise das getestete Artefakt.

```bash
/tmp/playenv/bin/python tool/play/promote.py 42
```

## Zwei Fallen, die schon zugeschnappt sind

**`changesNotSentForReview` wird in beide Richtungen abgelehnt.** Liegen in der
Console Änderungen in der Warteschlange, ist das Flag Pflicht („Changes cannot
be sent for review automatically"). Ist die Warteschlange leer, ist es verboten
(„Changes are sent for review automatically. The query parameter must not be
set."). **Beide Skripte** probieren deshalb das eine und fallen auf das andere
zurück, statt zu raten.

`play.py` tat das zunächst nicht — es setzte das Flag fest, weil zur Zeit seiner
Entstehung dauerhaft ein Stapel in der Warteschlange lag. Als der Stapel
eingereicht war, schlug es fehl (2026-08-04, beim Upload von Build 43). Der
Upload selbst war da schon durch; der Versionscode blieb trotzdem frei, weil
Play den Edit beim fehlgeschlagenen Commit mitverwirft. Eine feste Annahme über
den Zustand der Console hält nicht.

**Ein Rollout unter 100 % löst keinen Richtlinien-Befund.** Bei einem
stufenweisen Rollout liegen zwei Veröffentlichungen auf der Spur; die alte
bedient weiterhin den Rest und bleibt damit live. Play prüft jeden ausgelieferten
Versionscode, nicht den neuesten.

## Was bewusst nicht hier steht

Der Produktions-Rollout gehört dem Menschen. `play.py` verweigert die Spur, und
`promote.py` ist absichtlich ein eigenes Skript, das man tippen muss.
