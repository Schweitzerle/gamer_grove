# SupabaseScripts

Der Zustand der Datenbank liegt in `baseline/`. Die nummerierten Skripte sind
die Änderungen, die seither daraufkamen.

## Reihenfolge und Lücken

| Nummer | Was |
|---|---|
| `000_analyze_current_db.sql` | Abfrage, keine Änderung |
| `001.txt` – `005.txt` | Der frühe Verlauf. `.txt`, weil sie nie als ausführbare Migrationen gedacht waren, und **nicht** verlässlich der aktuelle Stand |
| `006` | fehlt |
| `007` – `024` | Die Migrationen seit dem Launch |

Die `.txt`-Dateien liegen versioniert im Repository — die Behauptung im Audit,
001–006 seien nie committet worden, war falsch. Was fehlte, war ein Abzug des
tatsächlichen Zustands; der steht jetzt in `baseline/`.

## Wie eine Änderung hier abläuft

1. `NNN_beschreibung.sql` schreiben. Der Kopf sagt, **warum** — was die
   Migration tut, steht im SQL darunter.
2. `NNN_dryrun.sql` daneben: dieselbe Migration in einer Transaktion, danach
   Zusicherungen als echte Rollen (`set local role authenticated` plus
   `request.jwt.claims`), am Ende ein `raise exception`.

   Das `raise` **ist** der Rollback. `FEHLGESCHLAGEN: 0 von N` ist ein
   bestandener Lauf; die Ausnahme danach ist die Migration, die zurückgenommen
   wird. Nach dem Probelauf nachsehen, dass der Zustand wirklich unverändert
   ist — ein Probelauf, der aus Versehen etwas stehen lässt, ist schlimmer als
   keiner.
3. Anwenden, danach denselben Nachweis noch einmal gegen die laufende
   Datenbank führen.

Was über die Storage-API läuft (Avatare), lässt sich in SQL nicht prüfen. Dort
gehört ein echter HTTP-Aufruf in den PR — angemeldet, nicht angemeldet, eigener
Ordner, fremder Ordner.

## Ausführen

Über die Management-API, Token in `~/.gg-supabase-token`:

```bash
curl -X POST "https://api.supabase.com/v1/projects/$REF/database/query" \
  -H "Authorization: Bearer $(cat ~/.gg-supabase-token)" \
  -H "Content-Type: application/json" \
  -d "{\"query\": $(python3 -c 'import json,sys; print(json.dumps(open(sys.argv[1]).read()))' NNN_x.sql)}"
```
