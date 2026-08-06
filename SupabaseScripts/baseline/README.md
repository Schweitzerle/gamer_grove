# Baseline

Was hier liegt, ist der Schema-Stand der Produktionsdatenbank — nicht eine
Migration, die man ausführt, sondern der Ausgangspunkt, auf dem die
nummerierten Skripte aufsetzen.

Warum es das braucht: `profiles`, `user_games`, `user_top_three`,
`user_activity` und der `avatars`-Bucket wurden nie in einem Skript angelegt,
das im Repository liegt. Ihr Aufbau existierte nur in der Cloud. Ein Verlust
des Projekts wäre nicht wiederherstellbar gewesen, und niemand konnte nachlesen,
was eigentlich gilt.

## Korrektur zum Audit

`docs/AUDIT_2026.md` behauptet, die Skripte 001–006 seien „nie committet"
worden. Das stimmt nicht: `SupabaseScripts/001.txt` bis `005.txt` liegen im
Repository und sind versioniert. Was fehlte, war 006 — und vor allem eine
verlässliche Aussage darüber, ob die `.txt`-Dateien den aktuellen Stand
beschreiben. Sie tun es nicht; sie sind der Verlauf, nicht der Zustand.

## Dateien

| Datei | Inhalt |
|---|---|
| `public_schema.sql` | `supabase db dump --linked` — Tabellen, Indizes, Constraints, Funktionen, Trigger, RLS-Politiken und GRANTs des `public`-Schemas |
| `storage_and_grants.sql` | Der `avatars`-Bucket samt seiner Politiken und die Rollen-GRANTs, die der Dump nicht mitnimmt |

## Erneuern

```bash
export SUPABASE_ACCESS_TOKEN="$(cat ~/.gg-supabase-token)"
supabase link --project-ref jmvhqefqjuljrbxlhanf
supabase db dump --linked -f SupabaseScripts/baseline/public_schema.sql
```

Der Rest wird über die Management-API abgefragt; die Abfragen stehen als
Kommentar in `storage_and_grants.sql`.

## Stand

Erzeugt am **2026-08-06**, nach Migration 024.
