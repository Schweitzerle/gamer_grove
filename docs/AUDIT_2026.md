# GamerGrove — Kassensturz, August 2026

Stand: 2026-08-04, `master` bei `18c5bf5`. Build 42 (`2.0.2+42`) liegt auf allen
vier Spuren, Produktion zu 100 %.

**Was hier gemessen wurde, und wie.** Jeder Fund trägt eine Severity und eine
Confidence. `hoch` heißt: ausgeführt und gesehen — Testausgabe, Query-Ergebnis,
HTTP-Antwort. `mittel` heißt: aus dem Code hergeleitet, aber nicht zur Laufzeit
bestätigt. `niedrig` heißt: Vermutung, und sie steht als Vermutung da.

Belege, die dieser Bericht selbst erzeugt hat:

| Prüfung | Ergebnis |
|---|---|
| `flutter analyze` | 0 Fehler, 0 Warnungen, **1195 infos** (1150 davon in `lib/`) |
| `flutter test` | **325 Tests, alle grün**, 53 s |
| `flutter test --coverage` | **14,2 % Zeilenabdeckung** (3783 / 26692) |
| Play Developer API (`tool/play/tracks.py`) | production/beta/alpha/internal = `42`, alle `completed` |
| Supabase Management API, Live-DB | RLS-Politiken, GRANTs, Zeilenzahlen, Kohorten |
| `curl` gegen die `igdb`-Edge-Function | HTTP 200 mit echten IGDB-Daten, nur mit dem Anon-Key |
| Sentry Release-API | 40 Releases, letztes Event **2026-07-30** |
| `git show d9b4797:.env`, Hash-Vergleich | historisches IGDB-Secret ≠ aktuelles |

Vier breite Durchgänge durch `lib/` (Sicherheit, Architektur, Tests + Analytics,
Performance + Barrierefreiheit) liefen als Subagenten. Die zugespitzten Aussagen
daraus habe ich selbst nachgeprüft; wo ich das nicht konnte, steht es dabei.

---

# Teil 1 — Zustand

## 1.0 Die vier Dinge, die vor allem anderen kommen

### Z-01 · RLS ist auf den Kerntabellen praktisch aus — CRITICAL, Confidence hoch

Drei Tabellen tragen eine Blankett-Politik, **je zweimal**, unter zwei Namen:

```
user_games       ALL {authenticated} USING=true CHECK=true   authenticated_users_all_access
user_games       ALL {authenticated} USING=true CHECK=true   enable_all_for_authenticated_users
user_top_three   ALL {authenticated} USING=true CHECK=true   (beide)
user_follows     ALL {authenticated} USING=true CHECK=true   (beide)
```

Alle sind `PERMISSIVE`, und permissive Politiken werden **ODER-verknüpft**. Die
sorgfältig geschriebenen Nachbarn — `Users can view public rated games`,
`Users can view public wishlists`, `Users can view public top three`, die alle
auf `profiles.is_profile_public` prüfen — sind damit wirkungslos.

Gegen die Produktionsdatenbank verifiziert, als echter angemeldeter Nutzer
`0b8c24b8…` gegen die Zeilen eines **anderen**, auf privat gestellten Nutzers:

```
rows_visible_from_private_user:   17    ← privates Profil, vollständig lesbar
total_user_games_visible:       1413    ← alle Zeilen, alle 9 Nutzer mit Daten
rows_deletable:                   17    ← DELETE in BEGIN … ROLLBACK
still_there:                      17    ← zurückgerollt, nichts verändert
```

Jeder angemeldete Nutzer kann die Bewertungen, Wunschlisten und Empfehlungen
**jedes anderen** lesen, ändern und löschen, fremde Top 3 überschreiben und
Folgebeziehungen in beide Richtungen fälschen. Private Profile sind nur in der
Oberfläche privat. 25 Profile und 1413 Bewertungszeilen sind echte Nutzerdaten —
das ist ein DSGVO-Sachverhalt, nicht nur ein Codefehler.

**Der Fix ist nicht „die zwei Politiken löschen".** `user_games` hat außer den
drei SELECT-Politiken und den beiden Blanketts **gar keine** eigene
Schreibpolitik. Fallen die Blanketts, kann niemand mehr ein Spiel bewerten. Es
braucht Löschung **und** eigene `auth.uid() = user_id`-Politiken für
INSERT/UPDATE/DELETE in derselben Migration. `user_top_three` hat seine
Eigenzeilen-Politiken bereits (Löschen allein genügt dort), `user_follows` hat
INSERT/DELETE und braucht eine Prüfung auf UPDATE.

Das ist das offene Issue **#6, „Fix RLS policies in supabase", medium prio, vom
2025-11-08** — neun Monate vor dem Launch. Die Priorität ist falsch.

### Z-02 · Die IGDB-Edge-Function ist ein offenes Relay — HIGH, Confidence hoch

`supabase/functions/igdb/index.ts` verlangt einen Supabase-Key. Der Client
schickt den **Anon-Key**, nicht das Session-JWT des Nutzers
(`lib/data/datasources/remote/igdb/igdb_datasource_impl.dart:296-302`). Der
Anon-Key ist aus dem APK auslesbar und liegt zusätzlich in der öffentlichen
Git-Historie.

Live geprüft:

```
POST /functions/v1/igdb   Authorization: Bearer <anon>   → HTTP 200, echte IGDB-Daten
POST /functions/v1/igdb   ohne Header                    → HTTP 401
```

Also: jeder im Internet kann die Function als kostenlose IGDB-API auf deinen
Twitch-Zugangsdaten und deinem Supabase-Invocation-Kontingent benutzen. Im
Rumpf (`index.ts:96-166`) gibt es **keine** Prüfung auf eine Aufrufer-Identität
und **keine** Ratenbegrenzung — die einzige Schranke ist `MAX_QUERY = 4000`
(`index.ts:55`, geprüft in `:122`). Die Query wird wörtlich weitergereicht
(`:135`), also ist `limit 500` mit tiefen Expansions pro Request möglich. IGDB
erlaubt 4 Requests/Sekunde; das reicht, um die App für echte Nutzer lahmzulegen.

Der Fix ist klein: `Authorization` lesen, per `supabase.auth.getUser(jwt)` auf
ein *Nutzer*-JWT prüfen, Anon-Rolle ablehnen. Vorher klären, ob der
Vor-Login-Katalog (Splash) IGDB braucht — falls ja, braucht der einen eigenen,
engeren Pfad.

Verwandt, **MEDIUM, Confidence hoch**: es gibt **keine** `supabase/config.toml`.
Ob eine Function JWTs prüft, steht nur in einem Kommentar und in dem Flag, das
jemand beim Deploy tippt. Ein `--no-verify-jwt`, kopiert von der zwei Dateien
entfernten Webhook-Anleitung, macht aus „missbrauchbar" lautlos „völlig offen".
Das gehört festgenagelt:

```toml
[functions.igdb]
verify_jwt = true
[functions.revenuecat-webhook]
verify_jwt = false
```

### Z-03 · Sentry hat seit dem Launch kein einziges Ereignis gesehen — HIGH, Confidence mittel

Über die Sentry-Release-API: 40 Releases, das **letzte Ereignis überhaupt am
2026-07-30**. Die Builds 28 bis 42 haben zusammen **null** Events. Build 42 ging
am 2026-08-04 auf Produktion — seither Stille.

Zwei Lesarten, und ich kann sie mit dem vorhandenen Token nicht trennen:

- Es stürzt schlicht nichts ab. Bei dieser Nutzerzahl (siehe Teil 2) an einem
  Tag durchaus plausibel.
- Sentry meldet aus Release-Builds gar nicht.

`hasHealthData: False` auf jedem Release heißt: **Release Health / Sessions sind
aus**. Genau die würden den Unterschied zeigen — eine Session wird auch ohne
Absturz gemeldet. Solange das aus ist, ist „keine Abstürze" von „meldet nicht"
nicht unterscheidbar, und ein Fehlermelder, dessen Funktion man nicht belegen
kann, ist kein Fehlermelder.

Das Token ist eng geschnitten (nur Releases; `/projects/` und `/issues/` geben
403), deshalb Confidence mittel statt hoch. Zu prüfen wäre: `SENTRY_DSN` im
Release-Build wirklich gesetzt (der CI schreibt ihn aus einem GitHub-Secret,
lokal aus `.env`), und Session-Tracking anschalten.

Nebenbefund, **MEDIUM, Confidence hoch**: `tool/build_release.sh` lädt
Debug-Symbole zu Sentry hoch — aber nur, wenn `sentry-cli` installiert ist. Ist
es das nicht, warnt das Skript und baut trotzdem. Obfuskierte Builds ohne
Symbole liefern unlesbare Crashes. Ob Build 42 seine Symbole hat, konnte ich
nicht prüfen.

### Z-75 · Melden und Blockieren existieren nicht — HIGH (Store-Risiko), Confidence hoch

Google Play verlangt für Apps mit sozialen Funktionen und nutzergenerierten
Inhalten ausdrücklich „in-app functionality to report users and content, and to
block users" (UGC-Richtlinie, `support.google.com/googleplay/android-developer/answer/9876937`,
nachgeschlagen, nicht erinnert). GamerGrove hat öffentliche Profile mit
Nutzernamen, Bio und Avatar, Folgebeziehungen, einen Aktivitätsfeed, ein
Leaderboard und eine Nutzersuche. Das ist der Fall.

Vorhanden ist nur die Fassade:

- `blockUser`/`unblockUser` (`user_repository_impl.dart:886, 902`) schreiben auf
  die Tabelle **`blocked_users`** — die es in der Datenbank **nicht gibt**. Die
  Live-Tabelle heißt `user_blocks`. Der Aufruf würde scheitern.
- `reportUser` (`:1000-1017`) schreibt auf `user_reports` — die Tabelle existiert,
  hat aber **keine GRANTs** (Z-08), der Aufruf endete also in
  `permission denied for table user_reports`.
- In `lib/presentation/` gibt es **null** Treffer für Melden oder Blockieren. Die
  Methoden sind von der Oberfläche aus nicht erreichbar.

Drei Defekte übereinander: kein Einstiegspunkt, ein falscher Tabellenname, keine
Rechte. Beides ist also nie ausgeführt worden — sonst wäre es aufgefallen. Das
gehört vor dem nächsten Produktions-Rollout geschlossen, und es ist der Grund,
warum Z-08 nicht nur Hygiene ist.

---

## 1.1 Sicherheit

### Secrets und Git-Historie

**Z-04 · Das Repository ist öffentlich, und `.env` liegt in der Historie — HIGH, Confidence hoch**

`gh repo view`: `"isPrivate":false,"visibility":"PUBLIC"`. Die Datei wurde in
`d9b4797` hinzugefügt und in `da9bc09` gelöscht — Löschen entfernt nichts,
`git show d9b4797:.env` liefert sie jedem, der klont.

Ich habe jeden Schlüssel per SHA-256 verglichen, historisch gegen aktuell:

| Schlüssel | Historie vs. heute |
|---|---|
| `SUPABASE_URL` | **gleich** |
| `SUPABASE_ANON_KEY` | **gleich** |
| `IGDB_CLIENT_ID` | **gleich** |
| `IGDB_CLIENT_SECRET` | **unterschiedlich** |

Das ist die wichtige Zeile: **das öffentlich einsehbare IGDB-Secret ist nicht
das aktuelle.** Es wurde seit dem Leak schon einmal gewechselt. Was heute
öffentlich liegt, sind Projekt-URL und Anon-Key — beide sind bauartbedingt
öffentlich, das ist in Ordnung, *solange* RLS trägt. Tut sie hier nicht (Z-01):
Anon-Key plus kaputte RLS ist genau die Kombination, die aus „öffentlich by
design" „öffentlich als Problem" macht.

Empfehlung: Historie mit `git filter-repo` bereinigen oder die gesamte Historie
als offengelegt behandeln. Und `supabase/.temp/` in die `.gitignore`
(**LOW, Confidence mittel** — der Inhalt ist heute unkritisch, das Verzeichnis
ist ein CLI-Scratchpad, das später mehr halten kann).

**Z-05 · `android/app/google-services.json` mit Firebase-Key in der Historie (`ecca3a8`) — LOW, Confidence hoch.**
Nicht mehr im Baum, Firebase wird nicht mehr benutzt. Firebase-Web-Keys sind
nicht geheim; das Risiko ist allein, ob die dort genannte
Realtime-Database-Instanz noch existiert und offene Regeln hat. Fünf Minuten in
der Firebase-Konsole: tot → löschen, lebendig → Regeln prüfen.

**Z-06 · Der Arbeitsbaum ist sauber — GUT.**
`git grep` über alle getrackten Dateien nach JWT-, `AIza`-, `sk_`-Mustern:
nichts. `.gitignore` deckt `.env`, `env.g.dart`, Keystores und `key.properties`.

**Z-07 · CI kann keine Secrets an Forks geben — GUT.**
`.github/workflows/ci.yml` triggert auf `push` und `pull_request`, **nicht**
`pull_request_target`. Secrets landen per quotiertem Heredoc (`<<'EOF'`, keine
Shell-Expansion) in `.env`, mit Platzhalter-Fallbacks, damit Fork-PRs bauen.
Betriebsgeheimnisse (Play-Dienstkonto, Sentry-Token) liegen in `$HOME`.

Ein Rest: der CI schreibt weiterhin `IGDB_CLIENT_SECRET` in die `.env`
(`ci.yml:39`, `:120`). Der Client braucht es seit dem Proxy nicht mehr. Das
Secret wird also ohne Grund an jeden Runner verteilt — **LOW, Confidence hoch**,
Fix ist eine gelöschte Zeile (mal zwei).

### Datenbank

**Z-08 · Drei Tabellen ohne RLS und ohne jede Politik — MEDIUM, Confidence hoch**

`user_blocks`, `user_reports`, `user_search_history`: `relrowsecurity = false`,
null Politiken, je 0 Zeilen. **Heute harmlos** — ich habe die GRANTs geprüft,
weder `anon` noch `authenticated` noch `service_role` haben Rechte darauf, also
sind sie über PostgREST nicht erreichbar. Der Fund ist die Falle: das erste
`GRANT`, das jemand hinzufügt, macht sie schlagartig offen. RLS anschalten,
bevor das passiert.

Dass `user_reports` und `user_blocks` leer sind, wirft eine zweite Frage auf —
siehe Z-30.

**Z-09 · Die Migrationen 001–006 existieren nicht — MEDIUM, Confidence hoch**

`SupabaseScripts/` springt von `000` auf `007`, und `git log --all` zeigt: sie
wurden nie committet. Damit sind `profiles`, `user_games`, `user_top_three`,
`user_activity` und der Storage-Bucket `avatars` nirgends versioniert. Ich habe
den Live-Zustand deshalb direkt aus `pg_policies` gelesen — daher Z-01. Der
Befund bleibt: der Schema-Stand lebt nur in der Cloud.

Konkret: `supabase db dump --schema public` plus ein `pg_policies`-Auszug nach
`SupabaseScripts/001_baseline.sql`. Ohne das ist jede künftige Aussage über RLS
wieder eine Vermutung.

**Z-10 · `user_follows` SELECT ist `USING (true)` — LOW, Confidence hoch.**
`008_fix_user_follows_rls.sql:35-38`. Der ganze Sozialgraph ist lesbar, auch für
Konten mit `is_profile_public = false`. Neben Z-01 fällt das kaum auf; nach dem
Fix von Z-01 bleibt es stehen und widerspricht dann der Privatsphäre-Einstellung.

**Z-11 · `handle_new_user` schluckt jeden Fehler — MEDIUM, Confidence hoch.**
`007_simple_fix_trigger.sql:63-65`: `WHEN OTHERS THEN RAISE WARNING … RETURN NEW`.
Die Registrierung gelingt, das Profil fehlt. Folge: `delete_own_account` löscht
nichts aus `profiles` (DSGVO bleibt trotzdem erfüllt, `auth.users` geht weg),
und der RevenueCat-Webhook meldet für einen zahlenden Kunden `unknown-user` —
ein Kauf, der lautlos nie ankommt. Dass `007` selbst eine Backfill-Schleife
mitbringt (`:97-152`), ist der Beleg, dass genau das schon passiert ist.
Mindestens ein Alarm auf `auth.users LEFT JOIN profiles WHERE profiles.id IS NULL`.

**Z-12 · TOCTOU im Collection-Limit-Trigger — LOW, Confidence hoch.**
`014:96-113` zählt und vergleicht in einem `BEFORE INSERT` ohne Lock. Zwei
parallele Inserts sehen beide 3 und kommen beide durch. Schaden: eine Sammlung
zu viel. `pg_advisory_xact_lock(hashtext(NEW.user_id::text))`, falls es dicht
sein soll.

**Z-13 · Der Pro-Guard fällt offen aus, wenn `request.jwt.claims` fehlt — LOW, Confidence mittel.**
`014:62-70` / `016:36-44` blockiert nur, *wenn* ein JWT sichtbar ist, statt nur
zu erlauben, wenn der Schreiber erkannt wird. Praktisch impliziert jeder solche
Pfad bereits direkte DB-Zugangsdaten. Eine Allowlist-Form
(`auth.role() IN ('anon','authenticated')`) wäre strikt sicherer.

**Z-14 · `is_username_available` ist für `PUBLIC` ausführbar — LOW, Confidence hoch.**
`007:73-89`, SECURITY DEFINER ohne `REVOKE`, vom Client vor der Registrierung
ohne Session aufgerufen. Nutzernamen-Enumeration in beliebiger Geschwindigkeit.
Der Kontrast ist der eigentliche Punkt: bei `is_pro_user` *wurde* revoked
(Z-19). Auf `anon, authenticated` einschränken.

**Z-15 · Alle SECURITY-DEFINER-Funktionen pinnen `search_path` — GUT.**
Zehn Funktionen, keine Ausnahme: `handle_new_user` (`007:9`),
`is_username_available` (`007:75`), die fünf Trigger in `009`,
`delete_own_account` (`013:28`), `is_pro_user` (`014:34`), `guard_pro_columns`
(`014:58`, `016:32`), `enforce_collection_limit` (`014:88`). Der klassische
`search_path`-Angriff ist damit zu.

### Auth

**Z-16 · Session-Token liegen im Klartext in SharedPreferences, und `allowBackup` ist Standard — MEDIUM, Confidence mittel.**
`lib/injection_container.dart:164-167` ruft `Supabase.initialize` ohne eigenen
`localStorage`, also persistiert `supabase_flutter` die Session (samt
Refresh-Token) als Klartext-XML. Dazu setzt `AndroidManifest.xml` weder
`android:allowBackup="false"` noch `dataExtractionRules`, also gilt der
Plattform-Standard `true` und die Datei ist per ADB/Cloud-Backup extrahierbar.
Zwei billige Fixes: `allowBackup="false"`, und `flutter_secure_storage` — das
als Abhängigkeit **bereits deklariert und nirgends benutzt** ist (Z-27) — als
Supabase-Storage verdrahten. Confidence mittel, weil das genaue
Storage-Backend von der aufgelösten `supabase_flutter`-Version abhängt.

**Z-17 · Mindestpasswortlänge 6 — LOW, Confidence hoch.**
`supabase_auth_datasource_impl.dart:32`, angewandt in `:41`, `:80`, `:181`.
Unter dem NIST-Boden von 8. Die Prüfung ist ohnehin nur clientseitig — die
maßgebliche Einstellung steht im Supabase-Dashboard, das ich nicht lesen kann.

**Z-18 · Rohe Backend-Fehlertexte erreichen die Oberfläche — LOW, Confidence hoch.**
`supabase_auth_exceptions.dart:190` setzt `message: error.toString()`; dazu
`'Failed to sign in: $e'` (`supabase_auth_datasource_impl.dart:63`) und
`'Unexpected error querying $endpoint: $e'` (`igdb_datasource_impl.dart:333`).
Nutzer sehen interne Fehlertexte.

**Z-19 · Kontolöschung ist vorbildlich — GUT.**
`013_delete_own_account.sql`: `uid := auth.uid()`, explizites
`IF uid IS NULL THEN RAISE EXCEPTION … '28000'`, **nimmt keine Parameter**, also
kann keine fremde ID hineingereicht werden, `search_path` gepinnt, `EXECUTE` von
`PUBLIC`/`anon` entzogen und nur `authenticated` gewährt. Der Client passt dazu
(`supabase_auth_datasource_impl.dart:144-149`). Die von Play geforderte
öffentliche Löschseite existiert unter `web/delete-account/index.html`.
`is_pro_user` ist genauso diszipliniert behandelt (`014:46-49`) — sonst könnte
jeder abfragen, ob eine beliebige ID zahlender Kunde ist.

**Z-20 · Passwort-Reset verrät keine Konten — GUT.**
`resetPassword` (`:161-176`) gibt unabhängig von der Existenz der Adresse void
zurück. `updatePassword`/`updateEmail` arbeiten auf der Session, nie auf einer
übergebenen ID.

**Z-21 · Client-gelieferte `userId` auf Schreibpfaden — MEDIUM, Confidence hoch.**
`updateUserProfile(String userId, …)`, `followUser(currentUserId, targetUserId)`,
alle `user_games`-Writes (`supabase_user_datasource_impl.dart:231, 279, 332`).
Ein `getCurrentUserId()` aus der Session existiert
(`supabase_base_repository.dart:380-386`), wird hier aber nicht benutzt. Das ist
das *richtige* Muster, **wenn** RLS trägt. Wegen Z-01 tut sie das für `user_games`
und `user_top_three` gerade nicht. Unabhängig vom RLS-Fix: die ID am
Datasource-Rand aus `auth.currentUser!.id` ableiten, damit Parameter und Session
gar nicht erst auseinanderlaufen können.

**Z-22 · Der Avatar-Upload umgeht die eigene Validierung — MEDIUM, Confidence mittel.**
`lib/presentation/pages/profile/edit_profile_page.dart:76-113` spricht direkt mit
Supabase und überspringt damit die 5-MB-Prüfung
(`supabase_user_datasource_impl.dart:128-133`) und `_validateProfileUpdates`
(`:88-120`, Bio ≤ 500, Anzeigename 1–50, Username-Regex). Die Endung kommt ohne
Allowlist aus dem lokalen Pfad (`:80-81`), und der Objektpfad lautet
`'/${widget.user.id}/avatar.$extension'` — mit **führendem Schrägstrich**, anders
als im Datasource (`'$userId/$fileName'`, `:137`). Wenn die Bucket-Policy mit
`(storage.foldername(name))[1] = auth.uid()::text` arbeitet, ist das erste
Segment hier leer. Ich konnte die Bucket-Policy nicht lesen (sie fällt unter
Z-09), daher Confidence mittel. Der Bucket ist öffentlich (`getPublicUrl`),
also lohnt die Prüfung: eine zu weite Policy heißt fremde Dateien auf deiner
Domain und womöglich überschriebene Avatare.

**Z-23 · LIKE-Metazeichen in der Nutzersuche nicht escaped — LOW, Confidence hoch.**
`supabase_presets.dart:110` baut `ILikeFilter('username', '%$searchTerm%')`.
**Keine Injection** — der typisierte Builder kodiert korrekt. Aber `%` liefert
alle öffentlichen Profile und `_` matcht jedes Zeichen. `%`, `_` und `\` escapen.

### Der Zahlpfad

**Z-24 · Pro ist server-autoritativ — GUT, Confidence hoch.**
Zweifach geprüft. Erstens: `grep -rn "is_pro\|pro_expires_at\|pro_event_at" lib test`
liefert **null** Treffer — die App liest und schreibt diese Spalten nie, ihr
Pro-Begriff kommt allein aus `CustomerInfo` des RevenueCat-SDK. Zweitens: selbst
ein handgebauter PostgREST-Request scheitert am Trigger
`profiles_guard_pro_columns` (`014:56-79`, erweitert in `016:29-45`), der für
jeden Nicht-`service_role`-Schreiber `42501` wirft. Der Kommentar `014:40-42`
benennt den Angriff, den er verhindert. Genau richtig gedacht und geschlossen.

**Z-25 · Der RevenueCat-Webhook ist der beste Code im Repo — GUT.**
Idempotenz und Reihenfolge sind auf Datenebene gelöst: `applyPro`
(`revenuecat-webhook/index.ts:35-62`) schreibt mit `.lt('pro_event_at', eventAt)`,
also sind Retries No-ops und eine verspätete `EXPIRATION` kann kein Abo
widerrufen, das eine neuere `RENEWAL` schon verlängert hat. `explainNoWrite`
(`:70-80`) trennt Replay/stale von `unknown-user`, damit eine falsche
`app_user_id` laut ist statt still „funktionierend". Die Entscheidungslogik ist
als reine Funktion herausgezogen (`decide.ts`) und mit 12 Fällen getestet
(`decide_test.ts`), inklusive der `TRANSFER`-Form ohne `app_user_id` — ein Bug,
den die meisten Implementierungen noch haben. Der CI fährt `deno fmt/lint/test`
darüber (`ci.yml:76-94`). `015:19` gewährt `service_role` nur `SELECT, UPDATE` auf
`profiles`: der Webhook kann selbst bei geleaktem Secret kein Konto anlegen.

**Z-26 · Webhook-Auth ist ein geteiltes Bearer-Secret, nicht konstantzeitig verglichen — LOW, Confidence hoch.**
`index.ts:85-92`. Das **ist** RevenueCats dokumentierter Mechanismus — es gibt
keine HMAC-Signatur zu prüfen, das ist also kein fehlender Signaturcheck. Zwei
Kleinigkeiten: `!==` auf Strings ist nicht konstantzeitig, und die Function muss
`--no-verify-jwt` deployt sein, also ist dieser eine Header das Einzige zwischen
Internet und Entitlement-Schreiber. Dazu **LOW**: `index.ts:133-138` gibt rohen
Postgres-Fehlertext zurück; der Code begründet den Trade-off explizit, eine
Korrelations-ID täte es aber auch.

**Z-27 · Vier von fünf Pro-Features sind nur clientseitig gegated — LOW, Confidence hoch.**
Serverseitig durchgesetzt ist allein das Collection-Limit
(`enforce_collection_limit`, `014:96-118`), und der Client übersetzt dessen
SQLSTATE `P0100` sauber in eine Paywall statt in einen Fehler
(`supabase_collections_datasource_impl.dart:57-62`). Gut gebaut. Die übrigen
`ProFeature`-Werte (`pro_feature.dart:9-23`) — `extendedStats`,
`advancedFilters`, `profileCustomization`, `adFree` — hängen an der Oberfläche.
Ein gepatchtes APK schaltet sie frei. Die Auswirkung ist gering: alle vier
rechnen über Daten, die ohnehin auf dem Gerät liegen. Es ist Umsatzleckage am
Rand, keine Sicherheitsgrenze — aber das sollte man wissen, nicht annehmen.

**Z-28 · Zwei unabhängige Konstanten für dasselbe Limit — LOW, Confidence hoch.**
`kFreeCollectionLimit = 3` (`free_limits.dart:9`) und `free_limit int := 3`
(`014:94`). `014:83-84` merkt an, dass sie übereinstimmen müssen; erzwungen wird
es von nichts. Driften sie, läuft der Nutzer in einen harten DB-Fehler, wo die
Oberfläche Erfolg versprochen hat. Dazu stehen in `free_limits.dart:3-5` und
`012:11-13` noch Kommentare, die serverseitige Durchsetzung als offen bezeichnen —
seit `014` erledigt.

---

## 1.2 Architektur

Die *Form* von Clean Architecture ist echt: `data/{datasources,models,repositories}`,
`domain/{entities,repositories,usecases}`, `presentation/{blocs,pages,widgets}`,
sieben Repository-Interfaces mit je einer Implementierung, Entities und Models
als getrennte Typen. Die Basis-Repositories sind keine Deko: `executeIgdbOperation<T>`
in `lib/data/repositories/base/` macht Konnektivitätsprüfung → Ausführung →
Exception-nach-`Failure` an einer Stelle, weshalb `Left(ServerFailure(...))`
61-mal statt 300-mal im Code steht. Gebrochen ist die Disziplin an zwei
bestimmten Nähten.

**Z-29 · Sieben Use Cases in `domain/` hängen an `UserRepositoryImpl` aus `data/` — CRITICAL, Confidence hoch**

`lib/domain/usecases/collection/`: `rate_game_use_case.dart` (Zeile 8 Import, 29
Feld), `remove_rating_use_case.dart` (8, 25), `toggle_wishlist_use_case.dart`
(8, 28), `toggle_recommended_use_case.dart` (8, 26),
`get_rated_games_use_case.dart` (8, 33), `get_wishlisted_games_use_case.dart`
(8, 29), `get_user_game_data_use_case.dart` (9, 40).

Die Abhängigkeitsregel ist damit umgedreht — die innerste Schicht zeigt nach
außen auf eine Implementierung. `injection_container.dart:525-528` muss die
konkrete Klasse extra registrieren, nur um das zu bedienen. Jede der sieben
Dateien trägt den Kommentar „requires UserRepositoryImpl as it uses
implementation-specific methods" — für den ich keine Belegstelle finde:
`rateGame`, `toggleWishlist`, `getRatedGames` sind gewöhnliche
Interface-Operationen. Der Fix ist mechanisch: die Methoden aufs Interface heben.

**Z-30 · Sieben doppelte Use-Case-Paare — zwei Schreibpfade auf dieselben Zeilen — CRITICAL, Confidence hoch**

Jede dieser Operationen existiert **zweimal**, in zwei Paketen, beide in
`injection_container.dart` registriert (`:431-443` und `:456-473`), je von einem
anderen BLoC benutzt:

| Operation | `usecases/game/` → `GameRepository` | `usecases/collection/` → `UserRepositoryImpl` |
|---|---|---|
| Bewerten | `RateGame` (GameBloc) | `RateGameUseCase` (CollectionBloc, UserGameDataBloc) |
| Wunschliste | `ToggleWishlist` | `ToggleWishlistUseCase` |
| Empfehlen | `ToggleRecommend` | `ToggleRecommendedUseCase` |
| Wunschliste lesen | `GetUserWishlist` | `GetWishlistedGamesUseCase` |
| Bewertete lesen | `GetUserRated` | `GetRatedGamesUseCase` |
| Empfehlungen lesen | `GetUserRecommendations` | `GetRecommendedGamesUseCase` |
| Top 3 lesen | `GetUserTopThree` | `GetTopThreeUseCase` |

Die schärfste Kante: beide Familien deklarieren eine Klasse **`RateGameParams`**,
mit **vertauschter Feldreihenfolge**:

```dart
// lib/domain/usecases/game/rate_game.dart:27
const RateGameParams({required this.gameId, required this.userId, required this.rating});

// lib/domain/usecases/collection/rate_game_use_case.dart:50
const RateGameParams({required this.userId, required this.gameId, required this.rating});
```

Sie bleiben nur auseinander, weil keine Datei beide importiert — und
`game_bloc.dart` mischt die Familien bereits (`RemoveRatingUseCase` aus
`collection/` neben `RateGame` aus `game/`). Benannte Parameter retten vor
stiller Fehlbindung; ein unachtsamer Import genügt trotzdem für einen echten
Fehler. Die zwei parallelen `UseCase`-Basisklassen (`base_usecase.dart`,
38 Nutzer; `usecase.dart`, 37 Nutzer) existieren wegen genau dieser Spaltung.

**Z-31 · `GameBloc`: 3402 Zeilen, 26 Abhängigkeiten, 37 Handler, kein Test — CRITICAL, Confidence hoch**

`lib/presentation/blocs/game/` über acht `part`-Dateien. Die Aufteilung ist
kosmetisch — es bleibt eine Klasse mit 26 Konstruktorabhängigkeiten
(`game_bloc.dart:50-76`) und 37 `on<Event>`-Registrierungen (`:78-135`), zuständig
für Suche, Detail, Home, Grove, Wunschliste, Bewertungen, Empfehlungen, Top 3,
DLCs, Expansions, Franchises, Collections, Events und Cache-Refresh. Das gehört
in mindestens vier BLoCs. Bemerkenswert: `UserGameDataBloc` existiert bereits als
eigener 696-Zeilen-BLoC mit überlappendem Gebiet — die Aufteilung wurde begonnen
und liegengelassen.

**Z-32 · Zwei bestätigte BLoC-Lecks — HIGH, Confidence hoch**

Beide holen eine **Factory**-Instanz (jedes Mal ein neues Objekt) in ein Feld und
schließen sie nie:

- `lib/presentation/pages/activity_feed/activity_feed_page.dart:33` —
  `_activityFeedBloc = sl<ActivityFeedBloc>()`. Selbst nachgeprüft: die Klasse
  hat **überhaupt kein** `dispose()`. Jeder Besuch des Activity Feeds leckt einen
  BLoC samt offener `GameRepository`-Referenz.
- `lib/presentation/pages/game_detail/game_detail_page.dart:96` —
  `_gameBloc = sl<GameBloc>()`. Selbst nachgeprüft: `dispose()` schließt
  `_scrollController` und `_mediaTabController`, **nicht** `_gameBloc`. Das ist
  die meistbesuchte Seite der App, und `GameBloc` ist das 26-Abhängigkeiten-Objekt
  aus Z-31.

Zum Kontrast: an acht anderen Stellen ist das Muster korrekt, u. a.
`grove_page.dart:41-44`, `search_page.dart:152-156`, `user_detail_page.dart:71-74`.

**Z-33 · Fünf Detailseiten zu ~90 % dupliziert, ~4856 Zeilen — HIGH, Confidence hoch**

`company_details_screen.dart` (1339), `event_details_screen.dart` (991),
`platform_details_screen.dart` (861), `game_engine_details_screen.dart` (847),
`character_detail_screen.dart` (818). Alle fünf haben dasselbe Gerüst privater
Methoden in derselben Reihenfolge. Ein Diff von `game_engine…:732-846` gegen
`platform…:734-861` ergibt 115 Zeilen mit 40 Diff-Zeilen, und jede davon ist eine
Namensersetzung — bis auf zwei echte Divergenz-Bugs (`?? ''` gegen
`?? 'Unknown'`; rohe `8` gegen `AppConstants.paddingSmall`). Die Extraktion wurde
**begonnen**: `lib/presentation/widgets/entity_detail/` hat 221 Zeilen, von vier
der fünf Seiten benutzt. Sie hörte bei 221 von ~4000 auf. Hier liegen 2500–3000
löschbare Zeilen.

**Z-34 · `presentation/` greift an der Architektur vorbei — HIGH, Confidence hoch**

- `search_page.dart` löst **zehnmal** `sl<GameRepository>()` aus Widget-Code auf
  (`:90, 235, 251, 267, 283, 299, 315, 331, 347, 363`) und schreibt die
  Ergebnisse per `setState` (`:96, 106, 115, 124, 133`). Serverdaten-Lebenszyklus
  in einem Widget verwaltet.
- `community_info_section.dart:398` — `Supabase.instance.client.auth.currentUser`
  direkt im Widget; `:404` — `sl<UserRepository>()`.
- `edit_profile_page.dart:76` — direkter Supabase-Client (siehe auch Z-22).
- `game_bloc.dart:8` importiert `data/models/game/game_model.dart`, und
  `game_state.dart:636/:651` legen `List<GameModel>` in den öffentlichen
  BLoC-Zustand. Beide Zustände sind ohnehin tot (Z-37) — löschen statt
  refaktorieren.
- `auth_repository.dart:4/:12` legt `Stream<supabase.User?>` ins Domain-Interface,
  obwohl eine eigene `User`-Entity existiert. **MEDIUM.**
- `domain/entities/event/network_type.dart:7` und `event_network.dart:7`
  importieren `flutter/material.dart` für `IconData`/`Color`. **MEDIUM** —
  kosmetisch, aber `domain/` kann so nie ein reines Dart-Paket werden.

Gut: **kein** BLoC und **kein** Widget importiert eine `*DataSource`. Diese
Grenze hält.

**Z-35 · Zwölf leere `catch`-Blöcke — HIGH, Confidence hoch**

`game_engine_bloc.dart:138, 201, 267` und `platform_bloc.dart:137, 200, 266`
(je Copy-Paste, `enrichmentService.enrichGames` schluckt lautlos —
ausgerechnet im BLoC, wo ein `Failure` gehörte und die Maschinerie danebensteht);
`external_links_section.dart:694, 704` (**Nutzer tippt auf einen externen Link,
nichts passiert, keine Rückmeldung** — die schlimmste UX-Wirkung der Gruppe);
`game_engine_model.dart:40, 52, 65` und `platform_model.dart:42` (JSON-Parsing,
ein kaputtes IGDB-Payload ergibt stillschweigend ein halb gefülltes Model).
Dazu `event_search_page.dart:139, 544` als `on Exception {}`.

**Z-36 · Neun ignorierte `Left`-Zweige — MEDIUM, Confidence hoch.**
`search_page.dart:95, 105, 114, 123, 132` (`(failure) => null`, fünf
Filteroptionen — bei Netzausfall rendert die Suchseite leere Dropdowns ohne
Erklärung), `user_game_data_bloc.dart:512, 564`,
`add_to_collection_sheet.dart:93`, `user_repository_impl.dart:1044`. Der Sinn von
`Either` ist, dass der Compiler zur Behandlung zwingt; hier wird sie verworfen.

**Z-37 · 22 tote Events und Zustände in `GameBloc` — MEDIUM, Confidence hoch.**
14 Events in `game_event.dart`, 8 Zustände in `game_state.dart`, dazu drei in
`game_extensions.dart`. Keine `on<>`-Registrierung, nie emittiert, nirgends
gematcht. ~250 Zeilen, und es löst Z-34s `GameModel`-Verstoß gratis mit.

**Z-38 · Der DCM-Block in `analysis_options.yaml` läuft nicht — MEDIUM, Confidence hoch.**
`analysis_options.yaml:41-75` konfiguriert `cyclomatic-complexity`,
`no-empty-block`, `avoid-unnecessary-setstate`, `long-method` und ein Dutzend
mehr. Die Abhängigkeit ist `dart_code_metrics_presets` — ein reines
Lint-Preset-Paket, nicht das DCM-Analyzer-Plugin, und es gibt keinen
`analyzer: plugins:`-Eintrag. **Keine dieser ~15 Regeln wird ausgeführt.** Das
erklärt, warum die leeren Blöcke aus Z-35 und die 1339-Zeilen-Datei eine
„strenge" Konfiguration überleben. Zusätzlich sind `:37-38`
(`- public_member_api_docs: false`) syntaktisch falsch — Map-Einträge in einer
Regelnamensliste; beide Regeln sind oben über `analyzer: errors:` ohnehin schon
abgeschaltet.

**Z-39 · Vier Feature-Flags ohne einen einzigen Leser, zwei davon lügen — LOW, Confidence hoch.**
`app_constants.dart:81-85`: `enableDarkMode`, `enableAnalytics = false`,
`enableCrashReporting = false`, `enableOfflineMode`. Jede hat genau eine
Referenz — ihre eigene Deklaration. `enableAnalytics = false`, während
`UmamiAnalyticsService` registriert ist und sendet; `enableCrashReporting = false`,
während Sentry eingebunden ist. Wer das liest, schließt das Gegenteil dessen,
was die App tut.

**Z-40 · Tote Abhängigkeiten und toter Code — LOW, Confidence hoch.**
- `fpdart` in `pubspec.yaml:12`: **null** Importe in `lib/`. `dartz` ist das
  echte Muster (93 Dateien). Selbst nachgezählt.
- `flutter_dotenv`: **null** Importe in `lib/` (envied macht die Arbeit). Selbst
  nachgezählt.
- `flutter_secure_storage`: deklariert, `FlutterSecureStorage` nirgends benutzt —
  und irreführend, weil es suggeriert, Tokens lägen im Keystore (Z-16).
- `flutter_lints: 3.0.2` als dev-Abhängigkeit, während `very_good_analysis: 10`
  die tatsächliche Basis ist.
- Tote Widgets in `core/widgets/error_widget.dart`: `ServerErrorWidget` (`:82`),
  `EmptyStateWidget` (`:99`), `AppErrorWidget` (`:158`).
- Tote Konstanten-Klassen `IGDBEndpoints`, `LanguageCodes`, `SupabaseTables`.
- ~200 Zeilen auskommentierter Code: `navigations.dart:609-700` (92 Zeilen),
  `game_bloc_details.dart:130-186` (57), `platform_section.dart:747-771`,
  `company_section.dart:466-487`.
- Leere Log-Methoden und leere Schleifen als Reste entfernter `print`s:
  `character_detail_screen.dart:817`, `company_details_screen.dart:1338`,
  `game_engine_details_screen.dart:846`, `game_enrichment_service.dart:271`,
  `platform_details_screen.dart:858` (leere `for`-Schleife),
  `top_three_dialog.dart:58` (ebenso).
- `ImageUtils.getSmallImageUrl` und `getScreenshotUrl`
  (`core/utils/image_utils.dart:35, 47`) werden **nirgends** aufgerufen — die
  Bildgrößenleiter wurde gebaut und nie benutzt. Siehe Z-42.

**Z-41 · 31 TODOs, kein FIXME/HACK — LOW bis MEDIUM, Confidence hoch.**
Gruppiert: 8× unfertige Nutzerstatistiken (`repo_user_stats.dart`), 8×
unfertige Navigationsziele (`navigations.dart`), 3× „Recent Searches aus
SharedPreferences laden/speichern" (`search_page.dart:173, 190, 749` — die
Zuletzt-Gesucht-Liste ist reiner Arbeitsspeicher und beim Neustart weg), 3×
gestubbte Collection-/Such-Schreiboperationen, 2× nie gebaute Cache-Schicht,
3× gestubbte Filterdialoge. Einer davon ist **MEDIUM**: `local_all_games_screen.dart:666`
liefert Nutzern buchstäblich `SnackBar(content: Text('Filters dialog - TODO'))`.

Weitere Größen: 13 Dateien über 800 Zeilen (nicht sieben — die größte ist
`company_details_screen.dart` mit 1339), 48 über 500. `user_repository_impl.dart`
(1165 Zeilen, 59 Methoden) ist lang, aber überwiegend dünne Delegation an den
Datasource — teilbar entlang fünf Domänen, aber kein Gott-Objekt im Sinne von
„nicht mehr durchschaubar". `navigations.dart` (955) besitzt jede Route der App
als statische Utility, mit 8 unfertigen Zielen und 92 auskommentierten Zeilen.

---

## 1.3 Performance auf echten Geräten

**Z-42 · Jedes Bild der App wird als 1920×1080 geladen und dekodiert — CRITICAL, Confidence hoch**

`core/constants/app_constants.dart:17` — `static const String largeImageSize = 't_1080p';`
`widgets/game_card/card_layers.dart:19` — `CachedImageWidget(imageUrl: ImageUtils.getLargeImageUrl(url))`

`CardArtwork` ist das Cover in **jeder** `GameCard`, und die rendert auf
**160×240 logischen Pixeln** (`widgets/game_card.dart:82-83`). Angefordert wird
ein 1920×1080-JPEG. Voll dekodiert sind das ~8,3 MB Bildspeicher **pro Karte**.
Ein zweispaltiges Grid mit 20 sichtbaren/gecachten Karten liegt bei 150+ MB —
Flutters `ImageCache` deckelt bei 100 MB, das Ding thrasht also: dekodieren,
verdrängen, bei jeder Scroll-Umkehr neu dekodieren. Auf einem Mittelklasse-Android
sieht das aus wie Ruckeln plus gelegentliche OOM-Kills.

Alle 12 Aufrufstellen nehmen dieselbe Größe, unabhängig von der Renderfläche.
Für Hero-Bild und Vollbildansicht ist 1080p richtig; für Karten, Thumbnails und
Grid-Zellen ist es um Faktoren daneben. Die passenden Helfer existieren und sind
tot (Z-40).

**Z-43 · Nirgends `memCacheWidth`/`cacheWidth` — CRITICAL, Confidence hoch**

Ein grep über `lib/` nach `memCacheWidth|memCacheHeight|cacheWidth|cacheHeight`
liefert **null** Treffer. `core/widgets/cached_image_widget.dart:34-51` ist der
eine Wrapper, durch den jedes Bild geht; er reicht `width`/`height` weiter — das
sind *Layout*-Constraints — aber nie die *Dekodier*-Größe. Das multipliziert sich
mit Z-42. Der Lichtblick: weil es genau einen Wrapper gibt, sind beide Fixes ~5
Zeilen in einer Datei plus ein Durchgang über die Aufrufstellen.

**Z-44 · `BaseGameSection` baut bei jeder `GameBloc`-Emission alles neu — HIGH, Confidence hoch.**
`widgets/sections/base_game_section.dart:52-65`: `BlocBuilder<GameBloc, GameState>`
ohne `buildWhen`. Jede Sektion abonniert den *gesamten* `GameBloc`; die
Grove-Seite stapelt fünf davon. Eine fertig geladene Sektion baut alle fünf neu,
samt `ChamberTint` → `TweenAnimationBuilder` → `LitSection` → `ListView.builder`.
Repoweit: 28 `BlocBuilder` + 8 `BlocConsumer`, aber nur **2** `buildWhen` (beide
in `game_card.dart`) und **1** `context.select`. `GameCard` macht es richtig
(`:97, 106-112`) — das Muster ist im Haus, es ist nur nie nach oben gewandert.

**Z-45 · `BackdropFilter` in scrollenden Listen — HIGH, Confidence hoch.**
`widgets/game_card/card_layers.dart:58-61` mattiert Cover bereits bewerteter
Spiele, angewandt pro Karte (`game_card.dart:131`). `BackdropFilter` erzwingt ein
`saveLayer` und liest den Hintergrund zurück; N davon in einem Scroll-Grid ist
einer der zuverlässigsten Wege, auf Mittelklasse-GPUs Frames zu verlieren — und
bei einem Nutzer mit vielen Bewertungen betrifft es *die meisten* Karten.
`event_card.dart:522-523` hat dasselbe in einer Liste.

Bemerkenswert: `widgets/sections/lit_section.dart:180-183` vermeidet `Opacity`
ausdrücklich aus genau diesem Grund, mit Kommentar. Jemand wusste es. Es kam nur
nicht in `card_layers.dart` an.

**Z-46 · `TweenAnimationBuilder` ohne `child:` — MEDIUM, Confidence mittel.**
`widgets/sections/chamber_tint.dart:92-97` baut 750 ms lang über `builder:` neu,
und der Builder enthält die ganze horizontale Liste. `lit_section.dart:176-178`
macht dasselbe Problem korrekt mit `ValueListenableBuilder` + `child:`.

**Z-47 · Kein `itemExtent`, drei Keys in der ganzen Präsentationsschicht — MEDIUM, Confidence hoch.**
`itemExtent|prototypeItem`: 0 Treffer. Jede horizontale Schiene ist per
Konstruktion fix hoch (`base_game_section.dart:99` `SizedBox(height: 280)`,
`:117` `Container(width: 160)`), `itemExtent: 168` wäre also gratis. Fehlende
Keys heißen: Sortierwechsel bauen neu statt zu verschieben.

**Gut, und ausdrücklich erwähnenswert:** die *großen* Listen sind alle korrekt
`builder`-basiert mit Paginierung — `user_game_list_page.dart:283, 323`,
`local_all_games_screen.dart:593, 616`, `search_page.dart:809`,
`base_game_section.dart:100`. Nur **4** `MediaQuery.of(context)`-Aufrufe in 51k
Zeilen. Alle 30 `.sort()`-Aufrufe liegen in Filtermethoden, nicht in `build()`.
Die sechs `_onScroll`-Handler wachen mit `if (isCollapsed != _isHeaderCollapsed)`,
setzen also einmal pro Schwellenüberschreitung. `core/theme/cover_tint.dart` ist
der sorgfältigste Code im Repo: dekodiert auf 16×16, dedupliziert parallele
Anfragen über `_inFlight`, entsorgt `frame.image` und `codec`, trennt eine reine
`tintFromPixels` zum Testen — und begründet im Kommentar, warum ein
Paletten-Paket abgelehnt wurde.

---

## 1.4 Barrierefreiheit

**Z-48 · 53 von 65 Seitendateien haben null `Semantics`, `semanticLabel` oder `tooltip` — HIGH, Confidence hoch.**
Ohne Ausnahme betroffen: alle primären Navigationsziele — `grove_page`,
`home_page`, `search_page`, `profile_page`, `game_detail_page`, `login_page`,
`register_page`, `user_search_page`, `leaderboard_page`, `activity_feed_page`,
`user_detail_page`, `edit_profile_page`, `splash_page`, plus alle Seiten unter
`pages/character/`, `pages/company/`, `pages/event/`, `pages/platform/`,
`pages/gameEngine/`. Die 12 Dateien, die etwas haben, sind ausnahmslos die
zuletzt gebauten.

**Z-49 · 62 von 69 `IconButton` ohne `tooltip` und ohne semantisches Label — HIGH, Confidence hoch.**
`IconButton` erzeugt kein Label von selbst; TalkBack sagt „Schaltfläche" und
sonst nichts. Am schlimmsten die Passwort-Sichtbarkeits-Umschalter
(`login_page.dart:151`, `register_page.dart:175, 210`) — ein Screenreader-Nutzer
kann nicht feststellen, ob sein Passwort gerade sichtbar ist. Dazu
`filter_bottom_sheet_ratings.dart` mit 10 Stellen und die App-Bar-Aktionen auf
`search_page.dart:525`, `profile_page.dart:53, 66`, `game_detail_page.dart:237, 277`.

**Z-50 · Tap-Ziele deutlich unter 48 dp — CRITICAL bis HIGH, Confidence hoch.**
- `widgets/top_three_dialog.dart:469-481` — der „aus Top 3 entfernen"-Knopf:
  `GestureDetector` → `Container(padding: EdgeInsets.all(3))` → `Icon(size: 14)`.
  **20×20 dp.** Destruktive Aktion, weniger als die Hälfte des Minimums, 3 dp von
  einer Ecke entfernt. **CRITICAL.**
- `widgets/sections/base_game_section.dart:213` — `minimumSize: Size(80, 32)` am
  Retry-Knopf jeder Sektion. **32 dp**, und es ist die einzige
  Wiederherstellungsmöglichkeit, wenn eine Sektion fehlschlägt. **HIGH.**
- `pages/character/widgets/character_filter_bar.dart:230-260` — Filter-Chips bei
  ~30 dp. **HIGH.**
- `pages/game_detail/widgets/game_info_card.dart:144-147` — `VisualDensity.compact`
  **plus** `MaterialTapTargetSize.shrinkWrap`; letzteres steigt ausdrücklich aus
  Materials 48-dp-Polsterung aus. **MEDIUM.**

Der Token existiert: `core/theme/gg_tokens.dart:38` definiert `minTapTarget: 48`,
und `gg_theme.dart:57, 64, 72` legt ihn auf die Button-Themes. Alle Fälle oben
umgehen diese Themes mit rohem `GestureDetector` oder expliziten Overrides.

**Z-51 · Textskalierung bricht bei 200 % — HIGH, Confidence hoch (Strukturbefund).**
127 literale `height:`-Constraints und 131 hartkodierte `fontSize:`-Werte. Die
gefährliche Schnittmenge sind fixe Höhen mit skalierendem Text:
`base_game_section.dart:148-172` (Leerzustand, `Container(height: 120)`) und
`:174-220` (Fehlerzustand, dieselbe Höhe, aber Icon + Text + Knopf darin) — beide
in *jeder* Sektion; `widgets/game_card/card_badges.dart:38-60` (32/44-dp-Scheiben
mit `fontSize: 8`/`9` — läuft ab ~150 % über, und 8 dp ist auch bei 1,0×
unterhalb jeder Lesbarkeitsgrenze).

**Die gute Nachricht:** es gibt **null** `textScaleFactor`-Overrides, null
`MediaQuery.withNoTextScaling`, null Clamping. Niemand hat Skalierung
unterdrückt — die Fehler sind rein geometrisch. Das ist das deutlich leichtere
Problem. Und `user_search_item.dart:77` macht es vor (reserviert Platz über
`MediaQuery.textScalerOf(context).scale(1)`), mit Test bei `TextScaler.linear(2)`.

**Z-52 · Kontrast: gerechnete Fehlschläge — HIGH, Confidence hoch.**
Gegen die Basisflächen `#0B1614` / `#12211D` nach WCAG-Formel:

| Verhältnis | Paar | Ort |
|---|---|---|
| 1,03:1 | `grey[900]` auf `surfaceContainer` | `video_player_screen.dart:338` — praktisch unsichtbar |
| 1,32:1 | `grey.shade300`-Rahmen auf Weiß | `character_filter_bar.dart:74, 78, 104, 118, 238` |
| 1,62:1 | `grey[400]`-Icon auf `grey[200]` | `top_three_dialog.dart:393` auf `:379` |
| 2,92:1 | `Colors.purple` auf dunkler Fläche | `character_filter_bar.dart:194, 196, 235`; `character_screen.dart:173` |
| 3,61:1 | `grey.shade600` auf `surfaceContainer` | `character_screen.dart:103, 246` |
| 3,97:1 | `grey[600]` auf `grey[200]`, `fontSize: 10` | `top_three_dialog.dart:400` |

Dahinter steckt ein systematischer Fund: `top_three_dialog.dart` und
`character_filter_bar.dart` sind gegen eine **helle** Palette geschrieben
(`grey[50]`, `grey[200]`, `Colors.white`-Text), während die App dunkel ist. Das
sind helle Flächen, in eine dunkle App gestanzt. Zum Ausgleich: `Colors.grey` auf
dunkel = 6,88:1, `white70` auf dunkel ≈ 8,8:1, Weiß auf `Colors.purple` = 6,3:1 —
nicht alles Hartkodierte ist kaputt. Aber nichts davon ist *geprüft*, während die
Theme-Paarungen es sind.

**Z-53 · Reduzierte Bewegung: vorbildlich — GUT.**
`MediaQuery.disableAnimationsOf(context)` an **16 Stellen**, und zwar richtig:
alle sechs Ladewidgets, `core/navigation/gg_reveal_route.dart:97`,
`game_detail_page.dart:467, 582`, `chamber_tint.dart:88`,
`lit_section.dart:119, 172`, `top_three_stack.dart:68, 88, 97`.
`chamber_tint.dart:84-90` erklärt im Kommentar, warum der Sprung auf die
Zielfarbe die gestalterische Absicht erhält. Das ist besser als der Branchenschnitt.

**Z-54 · Bilder ohne semantisches Label — MEDIUM, Confidence hoch.**
`core/widgets/cached_image_widget.dart` — der Wrapper, durch den jedes Bild geht —
hat keinen `semanticLabel`-Parameter. Cover in `GameCard` sind über
`MergeSemantics` + die Bildunterschrift halbwegs abgedeckt; `all_images_grid.dart:111`,
`enhanced_media_gallery.dart:244` und jedes Detailseiten-Headerbild sind
unbeschriftet und nicht ausgeschlossen. Dekoratives ist dort, wo darüber
nachgedacht wurde, gut behandelt: **18** `ExcludeSemantics`-Stellen, alle in der
neuen Schicht.

---

## 1.5 Oberflächen-Konsistenz

**Z-55 · Zwölf verschiedene Ladebehandlungen — HIGH, Confidence hoch.**

| Verwendungen | Behandlung |
|---|---|
| 27 | nacktes `CircularProgressIndicator` |
| 19 | `CustomShimmer` |
| 15 | `LiveLoadingProgress` |
| 14 | `PortalLoader` |
| 11 | `DitherSkeleton` |
| 9 | `CoinLoader` |
| 8 | `LoadingThumbnail` |
| 6 | `GameCardShimmer` |
| 5 | `GameListShimmer` |
| 2 | `LoadingIndicator` (Fremdpaket) |
| 1 | rohes `Shimmer.fromColors` |
| 1 | `LinearProgressIndicator` |

Zur Korrektur deiner Zahl: es sind **31** `CircularProgressIndicator` im Repo,
nicht ~40 — und **vier davon sind determinierte Fortschrittsringe**, keine
Ladeanzeigen: `card_badges.dart:79` (der Bewertungsring, `value: _score / 100`),
`activity_content.dart:192`, `local_all_games_screen.dart:418`,
`toast_service.dart:49`. Die dürfen bei einem Aufräumen **nicht** mitersetzt
werden. Das echte Ziel sind **27** unbestimmte Spinner.
`local_all_games_screen.dart` benutzt drei verschiedene Behandlungen in einer
Datei. `custom_shimmer.dart:40-42` hartkodiert `grey[300]/[100]/[300]` — ein
Hell-Shimmer in einer dunklen App.

**Z-56 · Acht handgebaute Leerzustände, keine gemeinsame Komponente — MEDIUM bis HIGH, Confidence hoch.**
Es gibt **kein** `EmptyState`-Widget im Repo. Die Qualität streut entsprechend:

Gut, weil sie dem Nutzer den nächsten Schritt geben: `collections_page.dart:239-270`
(`_EmptyView` mit Icon, Text **und** `onCreate`-Callback — der einzige Leerzustand,
der eine eigene Klasse mit CTA ist), `leaderboard_page.dart:187-212` und
`followers_following_page.dart:218-247` (unterscheiden „kein Suchtreffer" von
„wirklich leer").

Nackt oder gar nicht da:

| Severity | Bildschirm | Problem |
|---|---|---|
| HIGH | `pages/all_images_grid/all_images_grid.dart` | **kein Leerzustand**, leere Liste → leeres Grid |
| HIGH | `pages/allVideosGrid/all_videos_grid.dart` | **kein Leerzustand** |
| HIGH | `activity_feed_page.dart:70-75` | nackter Satz „Follow some users…" ohne Weg dorthin |
| MEDIUM | `user_game_list_page.dart:359` | eigene Wunschliste, kein „Spiele entdecken"-Knopf |
| MEDIUM | `character_screen.dart:232-255` | Icon + grauer Text, keine Aktion |
| MEDIUM | `profile_statistics_page.dart` | Nutzer ohne Bewertungen sieht leere Kacheln |

Dazu 42 `SizedBox.shrink()`-Rückgaben — jeweils eine Stelle, an der „keine Daten"
stumm nichts rendert statt es zu sagen.

**Z-57 · Fehlerzustände sind uneinheitlich — MEDIUM, Confidence mittel.**
Eine geteilte Komponente (`core/widgets/error_widget.dart`) plus
`BaseGameSection.buildErrorSection`. Alles andere ist ad hoc, meist
`ScaffoldMessenger.showSnackBar` — flüchtig und ohne Wiederholen. Ein
durchgängiges „dieser Bildschirm ist fehlgeschlagen, hier der Grund, hier
Wiederholen" gibt es nicht.

**Z-58 · 339 `Widget _build…`-Hilfsmethoden — LOW, Confidence hoch.**
Gegen die eigene Regel in `~/.claude/rules/flutter/architecture.md`. Schlimmste:
`event_card.dart` (13), `company_details_screen.dart` (13),
`character_detail_screen.dart` (12). Das trägt direkt zu Z-44 bei — eine
Hilfsmethode kann kein eigenes `buildWhen` und kein `const` haben, also ist jeder
Sektions-Rebuild total.

---

## 1.6 Theming — der stärkste Teil des Projekts

**Z-59 · Hell und dunkel sind beide erstklassig — GUT, Confidence hoch.**
Aus `core/theme/gg_color_schemes.dart:10-13`:

> „The light scheme is not an inversion. Brand gold `#F2A63C` scores 1.9:1 on a
> light ground and fails WCAG outright, so daylight gets its own darker gold.
> Contrast for every pairing the UI actually uses is asserted in
> `test/unit/core/theme/gg_contrast_test.dart`."

Das Hell-Schema benutzt `primary: #8A5410`, wo Dunkel `#F2A63C` hat — eine echt
neu hergeleitete Palette, keine Umkehrung. `:42-44` trennt sogar `outline`
(3:1-Pflicht) von `outlineVariant` (dekorativ, ausgenommen) und erklärt, dass
genau deren Vermengung den ersten Entwurf hat scheitern lassen. Der Test dazu
existiert. In der Theme-Schicht habe ich **kein** Anzeichen für „Hellmodus als
nachträglicher Einfall" gefunden.

`core/theme/gg_contrast.dart` ist eine korrekte WCAG-Luminanz-Implementierung mit
`readableForeground`/`legibleOn`, die defensiv gegen FlexColorSchemes schwächere
Paarungen eingesetzt wird — mit den richtigen Vorgaben 3:1 für Nicht-Text und
4,5:1 für Text.

**Z-60 · Umgangen wird das Theme in ~15 Altdateien — HIGH, Confidence hoch.**
472 hartkodierte Farbliterale in `lib/presentation/` (80× `Color(0x…)`, 392×
`Colors.<name>`) — aber dem stehen **852** `Theme.of(context)` und **653**
`colorScheme.` gegenüber. Das Theme *ist* das herrschende Idiom; die Hartkodierung
ballt sich in wenigen Dateien: `company_details_screen.dart` (61),
`top_three_dialog.dart` (25), `video_player_screen.dart` (25),
`character_detail_screen.dart` (24), `game_features_section.dart` (22),
`character_filter_bar.dart` (22). Genau dort sitzen auch die Kontrastfehler aus
Z-52. Dazu 150 rohe `TextStyle(`-Konstruktionen und 131 feste `fontSize:`, die
`GGTypography` umgehen.

**Z-61 · 413 `withOpacity(` — LOW, Confidence hoch.**
Seit Flutter 3.27 zugunsten von `withValues(alpha:)` deprecated. Die neue Schicht
benutzt bereits `withValues` — die Migration ist halb erledigt und macht den
Löwenanteil der 456 `deprecated_member_use`-Meldungen aus.

**Z-62 · Kein Token für Bild-Dekodiergrößen — MEDIUM, Confidence hoch.**
`GGTokens` deckt Abstand, Radius, Bewegung und Tap-Ziel ab. Ausgerechnet die
Achse, auf der die App kaputt ist (Z-42), hat keinen Token:
`AppConstants.largeImageSize` liegt in einer Konstantendatei ohne jeden Bezug zum
Theme oder zur Renderfläche.

---

## 1.7 Tests

325 Tests, alle grün, 61 Dateien. Und **14,2 % Zeilenabdeckung**. Die Verteilung
ist das eigentliche Ergebnis — sie steht auf dem Kopf:

| Abdeckung | Bereich |
|---|---|
| 100,0 % | `core/navigation` |
| 93,8 % | `core/analytics` |
| 88,9 % | `core/theme` |
| 32,9 % | `core/entitlements` |
| 23,3 % | `presentation/widgets` |
| 16,1 % | `presentation/pages` |
| **9,3 %** | `presentation/blocs` |
| **8,4 %** | `domain/usecases` |
| **6,9 %** | `domain/entities` |
| **5,1 %** | `data/repositories` |
| **1,4 %** | `data/datasources` |
| **1,3 %** | `data/models` |

Getestet ist das Neueste und Kleinste; die Geschäftslogik ist praktisch ungetestet.

**Z-63 · Der Auth-Stapel hat keine einzige Schicht, die echtes Verhalten testet — HIGH, Confidence hoch.**
`auth_bloc_test.dart` mockt alle acht Use Cases, prüft also nur die
Verzweigung des BLoCs. Darunter: `auth_repository_impl.dart` 0/90 Zeilen,
`supabase_auth_datasource_impl.dart` 0/93, alle acht `usecases/auth/*` ≈ 0 %,
und `supabase_auth_exceptions.dart` 0/78 — die gesamte Fehlerübersetzung, die
Nutzer tatsächlich zu sehen bekommen, ist ungetestet. `login_page.dart`,
`register_page.dart`, `splash_page.dart` und `main.dart` tauchen in `lcov.info`
**gar nicht auf**, sind also 0 %, nicht bloß wenig.

**Z-64 · Der echte Kaufpfad ist ungetestet — HIGH, Confidence hoch.**
Freie Stufe, `Entitlements` und `free_limits`: 100 %. `revenuecat_entitlement_service.dart`:
**0/52**, ausdrücklich als „durch einen echten Sandbox-Kauf verifiziert"
deklariert. `initBilling()` ungetestet. Für die Sache, bei der ein Fehler Geld
kostet, gibt es keine automatisierte Absicherung — der Webhook auf der anderen
Seite ist dagegen exemplarisch getestet (Z-25).

**Z-65 · Zwei „Tests", die nur Quelltext greppen — MEDIUM, Confidence hoch.**
`test/unit/data/igdb_proxy_test.dart` (3 Fälle) und
`test/unit/presentation/rating_scale_test.dart` (3 Fälle) lesen Dateien per
`File(...).readAsStringSync()` und prüfen `contains`. Ersteres prüft eine
**Deno-Datei** aus einem Dart-Test — die Proxy-Logik wird nie ausgeführt. Beide
begründen ihre Wahl ehrlich im Kommentar; der Laufzeitpfad bleibt trotzdem
unbedeckt. `igdb_datasource_impl.dart` ist 0/79: nichts prüft, dass ein echter
401 oder 429 je in `IgdbAuthenticationException`/`IgdbRateLimitException` mündet.

**Z-66 · Die Bewertungs-Oberfläche selbst ist ungetestet — HIGH, Confidence hoch.**
`rating_dialog.dart` 0/115, `user_states_section.dart` 0/161. Abdeckung
existiert nur auf BLoC-Ebene. (Nebenbei: es gibt keine geschriebenen
Rezensionen — nur eine Zahl. `review_text` existiert als Spalte und ist leer.)

**Z-67 · Suche → Detail ist ungetestet — HIGH, Confidence hoch.**
`search_page.dart` **1/442 Zeilen (0,2 %)**, `game_bloc_search.dart` 0/58,
`user_search_bloc.dart` 0/81. `game_detail_page.dart` liegt bei 59 %, aber alle
sechs seiner `widgets/*` bei 0 %.

**Z-68 · Goldens und Semantics decken ~8–11 % des Sichtbaren ab — HIGH, Confidence hoch.**
11 Golden-Dateien mit 31 Assertions und 39 Baselines, gegen 65 Seiten- + 66
Widget-Dateien. Keine Goldens für Login, Registrierung, Splash, Home, Grove,
Suche, Spieldetail, Profil, Paywall, Einstellungen, Activity Feed, Leaderboard.
Semantics: ~14 von 131 sichtbaren Dateien, und die Hälfte davon ist eine einzelne
Kontrastzeile. Die Regel „Goldens und Semantics-Tests sind Pflicht für alles
Sichtbare" gilt real für die zuletzt gebaute Schicht.

**Der Hebel ist klein:** das Semantics-Gate existiert bereits und ist gut gebaut.
Auf die Altbildschirme angewandt, fällt es laut und an genau den Stellen aus
Z-48 bis Z-52 durch. Das ist Verbreitung, keine Entdeckung.

**Z-69 · Keine Integrations- oder E2E-Tests — MEDIUM, Confidence hoch.**
`integration_test/` und `test_driver/` existieren nicht. Kein Test berührt DI,
den `main.dart`-Bootstrap, die `identify()`-Verdrahtung (`main.dart:126-152`)
oder Navigation (`navigations.dart` 2,7 %).

**Z-70 · Kleinere Testqualitätsmängel — LOW, Confidence hoch.**
Zwölf Stellen mit willkürlichen `pump(Duration)`-Werten (`seconds: 9` in
`top_three_stack_test.dart:131`, `seconds: 6` in `paywall_page_test.dart:114`) —
kodierte Animationsdauern als magische Zahlen. Ein paar schwache Assertions
(`isNotNull`, `findsWidgets`, `completes`). **Null** `skip:` — gut. Und die
Präferenz für handgeschriebene Fakes statt Mocks ist die richtige.

---

## 1.8 Build, Auslieferung, Abhängigkeiten

**Z-71 · `compileSdk = 35`, aber `targetSdk` löst auf 36 auf — MEDIUM, Confidence hoch.**
`android/app/build.gradle:16` setzt `compileSdk = 35` fest, während `:33`
`targetSdk = flutter.targetSdkVersion` nimmt — und Flutter 3.41.5 setzt
`targetSdkVersion = 36` (`FlutterExtension.kt:34`, nachgelesen im installierten
SDK). Die App **zielt** damit auf eine Plattform, gegen die sie nie kompiliert
wurde: alle Verhaltensänderungen von Android 16 greifen zur Laufzeit, während zur
Compilezeit nur API 35 sichtbar war. Das ist die riskanteste der möglichen
Kombinationen. Build 42 ist so ausgeliefert.

Zur Play-Frist, nachgeschlagen statt erinnert
(`developer.android.com/google/play/requirements/target-sdk`): **ab 31.08.2026**
brauchen neue Apps *und Updates* targetSdk **36**; Bestands-Apps ohne Update
bleiben ab targetSdk 35 für neue Nutzer verfügbar. Das Ziel ist also bereits
richtig — nur das `compileSdk` hinkt. `compileSdk = 36` setzen, gegen 36 bauen,
und die Frist ist ohne Hast erledigt.

Nebenbei, **LOW**: `minifyEnabled true` und `shrinkResources true` ohne jeden
`proguardFiles`-Eintrag. Es funktioniert (Build 42 läuft), aber R8 arbeitet allein
mit den Consumer-Regeln der Bibliotheken.

**Z-72 · Der Versionsname bewegt sich nicht — MEDIUM, Confidence hoch.**
`pubspec.yaml:4` steht auf `2.0.2+42`. Nutzer aktualisieren von „2.0.2" auf
„2.0.2". In Sentry heißen deshalb alle 40 Releases `…@2.0.2+N` — dort rettet die
Build-Nummer die Unterscheidbarkeit, im Store und gegenüber Nutzern nicht. Der
nächste Build gehört auf `2.1.0`, wie du sagst. Der `app_version_line`-Test
existiert bereits und hängt daran.

**Z-73 · Der CI ist solide, mit drei Lücken — GUT mit Auflagen.**
`ci.yml` fährt Format → Analyze → Test mit Coverage → Debug-APK, plus einen
eigenen Job für `deno fmt/lint/test` über die Edge Functions, mit der richtigen
Begründung im Kommentar. Was fehlt:
- **kein Coverage-Schwellwert** — `lcov.info` wird als Artefakt hochgeladen und
  nie geprüft; deshalb konnten 14,2 % unbemerkt entstehen (**MEDIUM**);
- **kein Dependency-Audit und kein Secret-Scan** (**MEDIUM**) — bei einem
  öffentlichen Repo mit `.env` in der Historie besonders schmerzhaft;
- **kein Release-Build** — der `--obfuscate`-Pfad aus `tool/build_release.sh`
  wird nie im CI ausgeführt, obwohl genau dort die Symbol-Prüfung sitzt (**LOW**).

Der Analyze-Schritt läuft bewusst mit `--no-fatal-infos` und der Kommentar nennt
die ~1400 infos als Phase-1-Rückstand. Real sind es **1195**, davon **1150 in
`lib/`**: 456 `deprecated_member_use`, 145 `discarded_futures`, 126
`avoid_returning_this`, 123 `avoid_catches_without_on_clauses`, 98
`avoid_dynamic_calls`, **14 `empty_catches`** (Z-35), 28 `flutter_style_todos`.

**Z-74 · Abhängigkeiten hängen zurück — MEDIUM, Confidence hoch.**
`flutter pub outdated`, die sicherheitsrelevanten zuerst:

| Paket | Aktuell | Verfügbar |
|---|---|---|
| `supabase_flutter` | 2.9.1 | **2.16.0** (Auth- und DB-Client, sieben Minor-Versionen) |
| `flutter_secure_storage` | 9.2.4 | 10.3.1 |
| `bloc` / `flutter_bloc` | 8.1.4 / 8.1.6 | **9.2.1 / 9.1.1** (Major) |
| `get_it` | 7.7.0 | **9.2.1** (zwei Major) |
| `purchases_flutter` | 10.4.2 | 10.7.0 |
| `sentry_flutter` | 9.24.0 | 9.26.0 |
| `dio` | 5.8.0+1 | 5.11.0 |
| `rxdart` | 0.27.7 | 0.28.0 |
| `intl` | 0.19.0 | 0.20.3 |

`supabase_flutter` ist der, der zuerst hochgehört.

---

## 1.9 Zwei offene Punkte, die ich nicht klären konnte

**Die Versionsverteilung von versionCode 5 — nachgetragen am 2026-08-04.**
Ursprünglich stand hier, die Zahl sei nicht erreichbar. Das war unvollständig:
sie steht in den Massenberichten im Cloud-Storage-Bucket, und das Dienstkonto
hatte die Berechtigung bereits — es fehlte nur der Bucketname, der die
Entwickler-ID enthält. Nach einer Nachfrage beim User liegt er in
`tool/play/versions.py`, samt Abfrage.

Aktive Geräteinstallationen von versionCode 5:

```
2025-12    9        (Produktionsrelease seit 2025-11-20)
2026-01    5
2026-02    8
2026-03   10
2026-04   11        ← Höchststand
2026-05    7
2026-06    5
2026-07    4 → 2    (ab 21.07. konstant 2)
```

Letzter Datenpunkt: **2026-07-23**, also zwölf Tage **vor** dem
Produktions-Rollout auf Build 42. Die Augustdatei wird von Play mit einigen
Tagen Verzug geschrieben und lag zum Zeitpunkt des Audits noch nicht vor.

**Einschätzung:** die Bedingung „nahezu null" ist mit 2 Geräten praktisch
erfüllt. Bei 11 Geräten im April hätte ich abgeraten, bei zweien nicht mehr.
Der schlechteste Fall sind zwei Installationen, die keine Spieldaten mehr laden,
bis sie aktualisieren — und der 100-%-Rollout ist inzwischen erfolgt. Sauber
wäre, die Augustdatei abzuwarten (`tool/play/versions.py 5`) und erst bei 0 zu
rotieren; vertretbar ist beides.

**Nebenbefund:** die gesamte aktive Installationsbasis waren am 23.07. **vier
Geräte** (versionCode 5, 8 und 12 mit je ein bis zwei). Das ist die ehrliche
Größenangabe zu Teil 2 — 25 Konten wurden angelegt, installiert ist die App auf
einer Handvoll Geräte. Und: versionCode 8 und 12 stehen nicht in
`bundles().list()`, sind also alte APK- statt AAB-Uploads.

**Umami.** Die Instanz auf `umami.playrackd.com` antwortet (`/api/heartbeat` →
200) und die Login-API funktioniert, aber auf dieser Maschine liegt keine
Zugangsdatei — `~/.gg-*` hat Sentry, Supabase, RevenueCat und Play, kein Umami.
Teil 2 stützt sich deshalb auf die **Live-Datenbank**, die einige der Fragen
sogar besser beantwortet (sie kennt Nutzer-IDs, Umami nicht — siehe P-03). Was
ohne Umami fehlt, ist alles **vor** der Registrierung: Installationen, erste
Öffnungen, Absprung auf dem Login-Bildschirm.

---

# Teil 2 — Produkt

## 2.1 Wofür die App steht

Der Store sagt es in einem Satz, und der Satz ist gut:

> „Rate games, keep your shelves, and see what your people are playing."

Drei Versprechen: bewerten, sammeln, sozial. Die Marke stützt ihn — die Höhle
des Gamers, dunkel als Raum, Gold als Licht, Pixel-Art als Machart. Das ist eine
Entscheidung mit Haltung, kein Standard-Theme, und die Theme-Schicht (Z-59) trägt
sie sauber.

**Wo das Produkt den Satz nicht hält:**

*„Rate games"* — es gibt eine Zahl und kein Wort. Die Spalte `review_text`
existiert und ist bei allen 1413 Zeilen leer, weil die App keinen Weg anbietet,
sie zu füllen. Letterboxd, das offensichtliche Vorbild, lebt genau davon: der
Text ist der Grund wiederzukommen, die Zahl ist nur die Sortierung. Ein
Bewertungsprodukt ohne Schreiben ist eine Datenbank mit Sternen.

*„see what your people are playing"* — 25 Profile, **8 Folgebeziehungen**
insgesamt. Das Soziale ist gebaut (Feed, Leaderboard, Nutzersuche, Follower) und
wird nicht benutzt. Bei dieser Größe kann es auch nicht: ein sozialer Feed
braucht eine Dichte, die eine App mit 25 Nutzern nicht hat. Das ist kein
Baufehler, sondern eine Reihenfolgefrage — dazu unten mehr.

*„keep your shelves"* — das ist der Teil, der hält. Sammlungen sind der am
besten gebaute und am besten getestete Bereich des Codes, und sie sind auch der
einzige Pro-Auslöser mit serverseitiger Durchsetzung.

## 2.2 Was die Nutzer wirklich tun

Aus der Live-Datenbank, nicht aus Annahmen. 25 Profile, Anmeldungen von
2025-11-08 bis 2026-08-03.

**Wie viele überhaupt irgendetwas getan haben:**

| | Nutzer |
|---|---|
| Profile insgesamt | **25** |
| die je eine `user_games`-Zeile erzeugt haben | **9** |
| die je ein Spiel **bewertet** haben | **6** |
| davon: Entwicklerkonto und Vorführkonto | 2 |
| **echte Nutzer, die je bewertet haben** | **4** |
| die je eine Sammlung angelegt haben | 3 (davon 2 die obigen Konten) |
| die je jemandem gefolgt sind | 4 |
| **Pro-Abonnenten** | **0** |

Die Verteilung der Bewertungen: 153 (Entwickler), 12 (Vorführkonto), dann 7, 2,
1, 1. Ein einziger Nutzer hat 1195 Spiele auf die Wunschliste gesetzt und **null**
bewertet — über drei Tage im Dezember. Das sind 85 % aller Zeilen in `user_games`
und mit ziemlicher Sicherheit kein menschliches Nutzungsmuster; ich würde da eine
Massenaktion oder einen Fehler vermuten (Confidence niedrig, aber es verzerrt
jede Kennzahl, die man aus Zeilenzahlen zieht).

**Retention, aus Zeilenstempeln gerechnet:**

```
Kohorte 25 Nutzer
D1  zurückgekehrt: 3   (12 %)
D7  zurückgekehrt: 3   (12 %)
D30 zurückgekehrt: 3   (12 %)
```

Es sind in allen drei Fenstern **dieselben drei**. Anders gesagt: wer nicht am
ersten Tag wiederkam, kam nie wieder. Nach eigenen aktiven Tagen:

| Nutzer | aktive Tage | Zeitraum |
|---|---|---|
| Entwickler | 7 | 2025-11-08 → 2025-12-18 |
| ein echter Nutzer | **7** | **2025-11-21 → 2026-07-30** |
| Massen-Wunschlister | 3 | 2025-12-03 → 2025-12-05 |
| drei weitere | 1–2 | |

Einer ist bemerkenswert: `0f47f300` kam über **acht Monate** wieder — 1 Zeile im
November, 3 im Dezember, 6 im Juli. Zehn Zeilen in acht Monaten sind keine
Nutzung, mit der man ein Produkt baut, aber es ist der Beleg, dass die Sache
jemanden halten kann.

**P-01 · Das Aktivierungsereignis ist gut definiert und wird von ~17 % erreicht — Confidence hoch.**
`ActivationTracker` (`core/analytics/activation_tracker.dart:35-66`) feuert beim
ersten Rating **oder** bei ≥3 Wunschlisteneinträgen und ≥1 Follow, einmal pro
Gerät, per SharedPreferences entprellt, vollständig unit-getestet. Das ist eine
saubere, verteidigbare Definition. Erreicht haben sie 4 von 23 echten Nutzern.

**Was die Ereignisse nicht beantworten können — und das ist selbst der Fund:**

**P-02 · Die Zeit bis zur Aktivierung ist nicht messbar — HIGH, Confidence hoch.**
`activation` trägt **keine Properties** (`analytics_events.dart:18`). Kein
`time_since_signup_ms`, kein `path` (bewertet vs. Wunschliste+Follow), keine
`source`. Man kann zählen, wie viele aktivieren, aber nicht, wie schnell oder
worüber — also auch nicht, ob eine Änderung am Onboarding etwas gebracht hat.
Der Fix sind drei Properties an `activation_tracker.dart:64` plus ein
gespeicherter `signup_at`.

**P-03 · Retention ist über Umami grundsätzlich nicht messbar — HIGH, Confidence hoch.**
Das Payload (`umami_analytics_service.dart:47-55`) enthält `website`, `hostname`,
`language`, `url`, `name`, `data` — **keine Nutzer-ID, keine Geräte-ID, keine
Session-ID**. `hostname` ist die Konstante `'gamergrove.app'`, `language` die
Konstante `'en'`, der User-Agent die Konstante `'GamerGrove/app (Flutter)'`.
Umami leitet seinen Besucher-Hash serverseitig aus IP + User-Agent ab. Bei
konstantem User-Agent heißt das: **alle Geräte hinter derselben Ausgangs-IP sind
ein Besucher, und ein Gerät im WLAN-Wechsel sind mehrere.** Retentionszahlen aus
diesem Aufbau wären nicht bloß fehlend, sondern **falsch**.

`AnalyticsService` (`analytics_service.dart:11-15`) hat nur `track` und `screen`
— **kein `identify`**. Dabei existiert die Identität längst: `main.dart:142` ruft
`sl<EntitlementService>().identify(authState.user.id)` für RevenueCat. Dieselbe
Stelle könnte Analytics mitbedienen. Minimum: `identify(String?)` plus eine
`installId` in SharedPreferences und eine `sessionId` pro Kaltstart.

Genau deshalb steht Teil 2 auf der Datenbank statt auf Umami: die DB **hat**
Nutzer-IDs und Zeitstempel, und die Zahlen oben sind damit echt und nicht
geschätzt.

**P-04 · `screen_view` ist deklariert und feuert nie — HIGH, Confidence hoch.**
`analytics_events.dart:41` und `umami_analytics_service.dart:40` sind die
einzigen Erwähnungen. `AnalyticsService.screen()` hat **null Aufrufstellen** in
`lib/`, es gibt keinen `NavigatorObserver`. Damit fehlt jede Zwischenstufe
zwischen „App geöffnet" und „registriert": ob Leute auf dem Splash, dem Login
oder im Registrierungsformular abspringen, ist unbeobachtbar. Ein
`NavigatorObserver` in `main.dart` schaltet das mit wenigen Zeilen frei.

**P-05 · Der Trichter Suche → Detail → Sammlung ist an keiner Stelle instrumentiert — HIGH, Confidence hoch.**
Kein `search`-Ereignis (`search_page.dart`, 963 Zeilen, null Analytics), kein
`game_view` (`game_detail_page.dart`, null Analytics), und
`collection_create` misst das Anlegen einer Sammlung, **nicht** das Hinzufügen
eines Spiels zu einer bestehenden. Der Kernpfad des Produkts ist blind. Nötig
wären `search_performed` {`result_count`, `filters_active`},
`search_result_tap` {`position`}, `game_view` {`game_id`, `source`} und
`collection_add_game`.

**P-06 · `purchase_start` zählt zu hoch — MEDIUM, Confidence hoch.**
`paywall_page.dart:84-87` feuert **vor** dem `onPurchase == null`-Zweig bei
`:89-99`. Taps, die nur „Coming soon" zeigen, gelten als Kaufstarts. Das bläht
den Nenner der Start→Abschluss-Quote auf. `paywall_page_test.dart:101-111`
zementiert das Verhalten — es ist so gewollt geschrieben, aber es misst falsch.
Ebenfalls fehlend: `purchase_failed`/`purchase_cancelled` (der
`success == false`-Zweig bei `:103` ist stumm), `paywall_dismiss`,
`restore_purchases`, und ein `pro_gate_hit` **vor** der Navigation
(`pro_access.dart:22`), um den Abfall zwischen „Schranke berührt" und „Paywall
gesehen" zu sehen.

**P-07 · `follow_user.source` trägt keine Information — LOW, Confidence hoch.**
`social_interactions_bloc.dart:67` setzt immer `'social_interactions'`,
unabhängig davon, welcher der vier Bildschirme ausgelöst hat.

**P-08 · `last_active_at` wird gelesen und nie geschrieben — MEDIUM, Confidence hoch.**
In der Live-DB ist `last_active_at` bei **allen 25** Profilen exakt gleich
`created_at`. Alle sieben Fundstellen in `lib/` sind Lesepfade (SELECT-Listen,
Model-Parsing, zwei Getter). Die Spalte, die Retention direkt beantworten würde,
wird nie aktualisiert. Immerhin sind `User.isRecentlyActive` (`user.dart:157`)
und `lastActiveDescription` (`:163`) **toter Code** — nirgends benutzt —, sonst
zeigte die App „Aktiv vor X" auf Basis des Anmeldedatums. Ein `UPDATE` beim
App-Start kostet fast nichts und liefert eine ehrliche Retentionsbasis.

**P-09 · DSGVO: sauber im Payload, offen bei der Einwilligung — MEDIUM, Confidence mittel.**
Gesendet werden nur `game_id`, `rating`, `screen`, `plan`, `source` — alles
Zahlen oder Compile-Zeit-Literale. Keine E-Mail, kein Nutzername, keine
Freitexte, keine Suchbegriffe. Sentry läuft mit `sendDefaultPii = false`
(`main.dart:65`). Aber: `main.dart:48` feuert `app_open` **bedingungslos beim
Start, vor jeder Oberfläche**, und der einzige Ausschalter ist ein leeres
`Env.umamiUrl` zur Bauzeit. Es gibt keinen Einwilligungsdialog und kein Opt-out.
Umamis Server sieht weiterhin die IP und hasht sie. Für einen EU-Launch ist das
auch ohne PII eine Lücke — und sie sollte geschlossen sein, bevor mehr Nutzer
kommen, nicht danach.

## 2.3 Warum jemand am siebten Tag wiederkommen sollte

Heute: **er kommt nicht.** D7 = 12 %, und es sind dieselben drei wie an D1.

Der Grund ist strukturell, nicht kosmetisch. Eine Katalog-App gibt beim ersten
Besuch alles her: man sucht sein Lieblingsspiel, vergibt Sterne, fühlt sich kurz
gut — und danach hat die App keinen Anlass mehr, an den sie erinnern könnte. Es
gibt keine Benachrichtigungen, keinen Digest, kein E-Mail-Lebenszyklus-Programm
(kein Versanddienst in den Abhängigkeiten), und der soziale Feed ist bei 8
Folgebeziehungen leer.

Es gibt genau eine Sorte Anlass, die eine Spiele-Katalog-App zuverlässig hat und
die hier nicht genutzt wird: **die Wunschliste weiß, was noch nicht erschienen
ist.** IGDB liefert Erscheinungsdaten. 1195 Wunschlisteneinträge liegen schon in
der Datenbank. Der Weg von dort zu „Dein gemerktes Spiel erscheint am Freitag"
ist kurz, und es ist die einzige Nachricht, die ein Nutzer als Dienst und nicht
als Werbung liest. Dazu unten als F-1.

## 2.4 Ist Pro 2,99 €/Monat wert, und sitzt der Auslöser richtig?

**Null Abonnenten von 25 Nutzern.** Bei 4 aktivierten Nutzern ist das statistisch
allerdings nichts — man kann daraus nicht schließen, dass der Preis falsch ist.
Was man beurteilen kann, ist das Paket.

Drin sind: mehr als 3 Sammlungen, erweiterte Statistiken, erweiterte Filter,
Profil-Themes, werbefrei (bei einer App ohne Werbung). Das ist eine
Aufzählung von Komfort. Nichts davon ist etwas, das ein Nutzer **vermisst**, bevor
er es sieht — und drei der fünf setzen voraus, dass er schon viele Daten in der
App hat. Erweiterte Statistiken über 2 bewertete Spiele sind kein Produkt.

Der einzige Auslöser mit echter Kraft ist der, der serverseitig durchgesetzt ist:
die vierte Sammlung. Der sitzt **richtig** — er trifft jemanden mitten in einer
Handlung, die er gerade tun will. Nur erreicht ihn fast niemand: 3 Nutzer haben
je eine Sammlung angelegt, und die zwei mit vier Sammlungen sind Entwickler- und
Vorführkonto.

Die ehrliche Diagnose ist deshalb **nicht** „Pro ist zu teuer", sondern: **Pro
verkauft Kapazität an Leute, die noch keine Daten haben.** Ein Preis lässt sich
erst beurteilen, wenn es Nutzer gibt, die genug in der App haben, um an eine
Grenze zu stoßen. Bis dahin ist jede Preisänderung ein Schuss ins Dunkle.

Was ich ändern würde, ohne den Preis anzufassen:
1. `pro_gate_hit` messen (P-06), damit man überhaupt sieht, wie oft eine Schranke
   berührt wird.
2. Das freie Sammlungslimit **nicht** senken. Die Versuchung ist groß und wäre
   falsch — bei 3 Nutzern mit Sammlungen ist das Problem die Nutzung, nicht die
   Großzügigkeit.
3. Pro erst wieder anfassen, wenn es ~50 Nutzer mit ≥10 bewerteten Spielen gibt.

## 2.5 Was ich bauen würde — wenige, begründet

Sortiert nach Wirkung gegen Aufwand.

**F-1 · Erscheinungs-Benachrichtigung für die Wunschliste. Aufwand: mittel. Wirkung: hoch.**
*Löst folgendes Problem:* Die App hat keinen einzigen Grund, an den sie erinnern
kann, und D7 liegt bei 12 %. Das ist der einzige Anlass, den eine Katalog-App von
Natur aus besitzt: IGDB kennt Erscheinungsdaten, die Wunschliste kennt das
Interesse, beides liegt schon da. Eine Nachricht, die ein Nutzer als Dienst liest.
Nötig: ein geplanter Job (die Edge-Function-Infrastruktur steht), Push-Setup und
eine Einstellung zum Abschalten. Das ist die einzige Empfehlung, bei der ich
sicher bin, dass sie die Kernkennzahl bewegt.

**F-2 · Ein Satz zur Bewertung. Aufwand: klein. Wirkung: mittel bis hoch.**
*Löst folgendes Problem:* Das Store-Versprechen sagt „rate games", und die App
kann nur zählen. `review_text` existiert bereits in der Tabelle und ist leer, weil
es kein Eingabefeld gibt. Ein einzeiliges Feld — nicht ein Rezensions-Editor —
verwandelt eine Zahl in etwas, das man wiederlesen und zeigen mag, und gibt dem
sozialen Teil endlich Inhalt. Der billigste Weg von „Datenbank mit Sternen" zu
„Produkt mit Stimme".

**F-3 · Analytics-Identität + die vier fehlenden Trichter-Ereignisse. Aufwand: klein. Wirkung: mittelbar hoch.**
*Löst folgendes Problem:* Man kann gerade nicht sehen, wo Leute abspringen (P-03,
P-04, P-05), und jede Produktentscheidung ist deshalb ein Bauchgefühl. Das ist
kein Feature, sondern die Voraussetzung dafür, dass F-1 und F-2 überhaupt bewertbar
werden. `identify` + `installId` + `sessionId`, ein `NavigatorObserver`, und
`search_performed` / `game_view` / `collection_add_game` / `pro_gate_hit`. Zuerst
bauen, nicht zuletzt.

**F-4 · Ein Jahresrückblick / „Dein Jahr in Spielen". Aufwand: mittel. Wirkung: mittel, saisonal.**
*Löst folgendes Problem:* Es gibt nichts, was ein Nutzer aus der App heraus zeigen
würde, und damit keinen organischen Kanal. Das Muster ist erprobt (Spotify,
Letterboxd), die Daten liegen vor, und es zahlt gleichzeitig auf Pro ein
(erweiterte Statistiken bekommen einen Anlass). Sinnvoll erst ab einer Nutzerbasis,
die genug bewertet hat — also nach F-1 und F-2.

**F-5 · Eine deutschsprachige Store-Eintragung. Aufwand: klein. Wirkung: klein bis mittel.**
*Löst folgendes Problem:* Es existiert nur `en-US` — live per Play-API geprüft.
Impressum und Rechtstexte sind deutsch, der Betrieb ist deutsch, und die ersten
Nutzer kommen mit hoher Wahrscheinlichkeit von hier. Eine `de-DE`-Eintragung
(Titel, Kurzbeschreibung, Beschreibung) kostet einen Nachmittag und verbessert die
Auffindbarkeit im relevantesten Markt. Die App-Sprache bleibt Englisch — das ist
kein Widerspruch, Store-Eintragungen werden anders gefunden als Oberflächen
gelesen.

## 2.6 Was ich nicht bauen würde — die nützlichere Liste

**Nichts weiter am sozialen Teil.** Feed, Leaderboard, Nutzersuche, Follower,
Aktivitätsverlauf sind gebaut und werden von 8 Folgebeziehungen benutzt. Soziale
Funktionen haben eine Dichteschwelle: unter ihr sind sie nicht unterbenutzt,
sondern *unbenutzbar* — ein leerer Feed ist schlimmer als kein Feed, weil er
Verlassenheit ausstellt. Mehr davon zu bauen, verschiebt die Schwelle nicht. Issue
**#35 „Playing right now"** und **#27 „AI recommendations"** fallen beide hierunter.
Sie sind nicht schlecht gedacht, sie sind nur zu früh.

**Keine KI-Empfehlungen (Issue #27).** Empfehlungen brauchen ein Signal. Das
Signal wären Bewertungen; es gibt 4 Nutzer, die je eine abgegeben haben. Ein
Empfehlungssystem auf dieser Basis erzeugt zuverlässig plausibel klingenden
Unsinn, und der Nutzer merkt das sofort. Frühestens sinnvoll bei ein paar hundert
bewertenden Nutzern.

**Keine Lokalisierung der App (Issue #28).** Deutliche Unterscheidung zu F-5: die
Store-Eintragung zu übersetzen ist billig und wirkt sofort, die **App** zu
lokalisieren heißt, 462 Dateien mit hartkodierten Strings anzufassen und
anschließend zwei Textstände zu pflegen — bei 25 Nutzern und ungeklärter
Zielgruppe. Später, und dann mit `l10n` von Anfang an in neuem Code.

**Keine der fünf großen Detailseiten weiter ausbauen.** `pages/company/`,
`pages/event/`, `pages/platform/`, `pages/gameEngine/`, `pages/character/` sind
zusammen ~4856 Zeilen zu 90 % duplizierten Codes (Z-33) für Bildschirme, die im
Kernversprechen der App gar nicht vorkommen. Wer eine Spielebewertungs-App
öffnet, sucht kein Entwicklerstudio. Ich würde sie nicht erweitern, sondern auf
die begonnene `entity_detail/`-Abstraktion zusammenziehen und dann in Ruhe lassen.

**Keine Absenkung des freien Sammlungslimits, um Pro zu verkaufen.** Siehe 2.4 —
das behandelt ein Nutzungsproblem als Preisproblem und macht das Produkt für die
wenigen aktiven Nutzer schlechter.

**Kein Offline-Modus.** `enableOfflineMode` steht als Flag im Code und wird von
niemandem gelesen (Z-39); es gibt keinen lokalen Speicher (kein Hive/Isar/sqflite,
nur `shared_preferences` und der Bildcache). Das ist ein großes Stück Arbeit für
ein Problem, das bei einer Katalog-App mit funktionierender Fehlerbehandlung kaum
jemanden trifft. Die Zeit gehört in F-1.

## 2.7 Widerspruch

Drei Stellen, an denen ich eine bestehende Priorität für falsch halte:

1. **Issue #6 „Fix RLS policies", medium prio, seit 2025-11-08.** Das ist der
   schwerste Fund dieses Audits (Z-01) und liegt seit neun Monaten auf mittel.
   Es gehört auf höchste Priorität, vor allem anderen in dieser Liste.

2. **„Sieben Dateien über 800 Zeilen" als bekannter Mangel.** Es sind dreizehn,
   und die Zeilenzahl ist ohnehin das falsche Maß. Die wirklichen Strukturprobleme
   sind `GameBloc` (3402 Zeilen über acht `part`-Dateien, kein Test) und die
   doppelten Use-Case-Familien mit zwei `RateGameParams` — beide fallen bei einer
   Zeilenzählung pro Datei durch das Raster.

3. **Der Store-Auftritt gilt als erledigt.** Er ist es für `en-US`. Für einen
   deutschen Betrieb mit deutschen Rechtstexten fehlt die naheliegendste
   Reichweitenmaßnahme, und sie ist billiger als jedes Feature auf dieser Liste.

---

# Anhang A — Die Issues zu diesem Audit

32 Issues, aus den Funden abgeleitet. #6 wurde aktualisiert statt dupliziert —
es beschrieb den schwersten Fund bereits, an der falschen Priorität.

**Vor dem nächsten Produktions-Rollout**

| # | Titel | Fund |
|---|---|---|
| #6 | RLS-Politiken (aktualisiert, `medium` → `high`) | Z-01 |
| #160 | Melden und Blockieren fehlen — Play-UGC-Richtlinie | Z-75 |
| #161 | IGDB-Function ist ein offenes Relay | Z-02 |
| #163 | Drei Tabellen ohne RLS, Baseline-Migration fehlt | Z-08, Z-09 |
| #164 | Sentry hat seit dem Launch kein Ereignis gesehen | Z-03 |
| #165 | Öffentliches Repo mit `.env` in der Historie | Z-04, Z-05, Z-07 |

**Hoch**

| # | Titel | Fund |
|---|---|---|
| #169 | Bilder als 1920×1080, kein `memCacheWidth` | Z-42, Z-43, Z-62 |
| #170 | Rebuild-Umfang und Blur | Z-44 – Z-47 |
| #171 | Zwei BLoC-Lecks | Z-32 |
| #172 | Tap-Ziele unter 48 dp | Z-50 |
| #173 | Semantics und `IconButton`-Label | Z-48, Z-49, Z-54 |
| #176 | Doppelte Use-Case-Paare, zwei `RateGameParams` | Z-29, Z-30 |
| #177 | `GameBloc` aufteilen | Z-31, Z-37 |
| #180 | 14,2 % Abdeckung, CI prüft sie nicht | Z-63 – Z-70, Z-73 |
| #182 | `compileSdk` 35 gegen `targetSdk` 36, Version, Abhängigkeiten | Z-71, Z-72, Z-74 |
| #184 | Analytics: keine Identität, `screen_view` tot | P-02 – P-07 |
| #188 | Erscheinungs-Benachrichtigung für die Wunschliste | F-1 |
| #191 | User-Aufgaben: Play-Zahl, Umami-Zugang, Vorführkonto | 1.9, Anhang B |

**Mittel**

| # | Titel | Fund |
|---|---|---|
| #162 | `supabase/config.toml` fehlt | Z-02 |
| #166 | Session-Token im Klartext, `allowBackup` | Z-16 |
| #167 | Avatar-Upload umgeht Validierung | Z-21, Z-22 |
| #168 | Datenbank-Härtung | Z-11 – Z-14, Z-28 |
| #174 | Textskalierung bei 200 % | Z-51 |
| #175 | Hartkodierte Farben, Kontrastfehler | Z-52, Z-60 |
| #178 | Leere Catches, ignorierte `Left`-Zweige | Z-35, Z-36 |
| #179 | Fünf duplizierte Detailseiten | Z-33 |
| #181 | Goldens und Semantics ausweiten | Z-68 |
| #185 | `last_active_at` wird nie geschrieben | P-08 |
| #186 | Analytics ohne Einwilligung | P-09 |
| #187 | Ladebehandlungen und Leerzustände | Z-55 – Z-57 |
| #189 | Ein Satz zur Bewertung | F-2 |
| #190 | Deutsche Store-Eintragung | F-5 |

**Niedrig**

| # | Titel | Fund |
|---|---|---|
| #183 | Toter Code, tote Abhängigkeiten, inerter DCM-Block | Z-37 – Z-41 |

F-3 (Analytics-Grundlage) ist #184, F-4 (Jahresrückblick) ist bewusst **nicht**
angelegt — er ergibt erst nach F-1 und F-2 Sinn.

Nicht angelegt und ausdrücklich empfohlen, sie **nicht** zu bauen (2.6): mehr am
sozialen Teil (#35), KI-Empfehlungen (#27), App-Lokalisierung (#28), Ausbau der
fünf Detailseiten, Absenkung des freien Sammlungslimits, Offline-Modus.

---

# Anhang B — Was ohne Zutun kaputtgehen kann

- **Das IGDB-Secret ist als öffentlich zu behandeln** und muss rotiert werden,
  sobald versionCode 5 aus dem Feld ist. Die Zahl steht noch aus (1.9). Das
  historisch geleakte Secret ist ein anderes und bereits gewechselt (Z-04).
- **Das Vorführkonto** (`~/.gg-showcase-account.json`, ID `e661b5e3…`, privates
  Profil, 12 Bewertungen, 5 Wunschliste, 4 Sammlungen, 14 Tage Pro) hat seinen
  Zweck erfüllt: die Store-Eintragung ist live und vollständig — 5 Screenshots,
  Feature-Graphic, Icon, Titel, Beschreibungen, per Play-API ausgelesen. Vor dem
  Löschen bleibt **eine** Prüfung, die ich nicht per API machen kann: in der Play
  Console unter *App-Inhalte → App-Zugriff*, ob dort Demo-Zugangsdaten für die
  Prüfung hinterlegt sind. Wenn ja, hängt jede künftige Prüfung an diesem Konto;
  wenn nein, kann es weg.
- **Melden und Blockieren gibt es nicht** — siehe Z-75. Das ist der einzige Fund
  dieses Audits, der die Store-Prüfung selbst gefährdet.
