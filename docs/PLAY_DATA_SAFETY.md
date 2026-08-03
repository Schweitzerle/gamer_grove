# Data-Safety-Erklärung — Antwortbogen

Play Console → **Richtlinien → App-Inhalte → Datensicherheit**. Nur dort zu
pflegen; die Play-API kennt dieses Formular nicht.

Der Stand von versionCode 5 kennt weder RevenueCat noch Sentry noch Umami. Was
hier steht, ist aus dem Code und der Datenschutzerklärung abgeleitet — beide
müssen dasselbe sagen, sonst ist die Erklärung falsch und das ist ein
Ablehnungsgrund.

Zu jeder Angabe die Quelle, damit sie beim nächsten Mal nachprüfbar ist statt
erinnert werden zu müssen.

---

## Vorab-Fragen

| Frage | Antwort | Warum |
|---|---|---|
| Erhebt oder teilt deine App die geforderten Nutzerdatentypen? | **Ja** | Konto, Inhalte, Absturzdaten |
| Werden alle Nutzerdaten bei der Übertragung verschlüsselt? | **Ja** | Supabase, Sentry, Umami und IGDB laufen ausschließlich über HTTPS |
| Können Nutzer die Löschung ihrer Daten beantragen? | **Ja — Löschung im Konto möglich** | „Delete account" im Profil; `013_delete_own_account.sql` löscht Profil, Bewertungen, Top 3 **und** die Identität in `auth.users` |

> **Wichtig zur letzten Frage:** Play verlangt zusätzlich eine **Web-URL zur
> Löschung**, wenn man „Konto löschen" anbietet. Die haben wir noch nicht. Ohne
> sie reicht die In-App-Löschung formal nicht. Das ist der eine Punkt, an dem
> ich noch etwas bauen muss — sag Bescheid, dann mache ich eine kleine Seite.

---

## Erhobene Datentypen

Für jeden Typ fragt Play dasselbe: **erhoben** oder **geteilt**, ob
**verpflichtend**, und **wozu**. „Geteilt" heißt bei Play: an einen Dritten
weitergegeben, der sie für eigene Zwecke nutzen darf — Auftragsverarbeiter
zählen **nicht** als „geteilt".

### Personenbezogene Daten

| Datentyp | Erhoben | Geteilt | Pflicht | Zweck |
|---|---|---|---|---|
| **E-Mail-Adresse** | Ja | Nein | Ja | Kontoverwaltung |
| **Nutzer-IDs** | Ja | **Ja** | Ja | Kontoverwaltung, App-Funktionalität |
| **Name** (Anzeigename) | Ja | Nein | Nein | Kontoverwaltung, App-Funktionalität |

> **Warum Nutzer-IDs „geteilt" sind:** Die Konto-ID geht an RevenueCat, damit
> ein gekauftes Abo dem Konto zugeordnet werden kann. RevenueCat ist ein
> eigenständiger Anbieter in den USA, kein reiner Auftragsverarbeiter —
> Quelle: `RevenueCatEntitlementService.configure(appUserId:)`.

### Fotos und Videos

| Datentyp | Erhoben | Geteilt | Pflicht | Zweck |
|---|---|---|---|---|
| **Fotos** (Profilbild) | Ja | Nein | Nein | App-Funktionalität |

Quelle: `profiles.avatar_url`, Supabase Storage. Optional.

### App-Aktivität

| Datentyp | Erhoben | Geteilt | Pflicht | Zweck |
|---|---|---|---|---|
| **Sonstige nutzergenerierte Inhalte** | Ja | Nein | Nein | App-Funktionalität |
| **Sonstige Aktionen** | Ja | Nein | Nein | Analysen |

Nutzergenerierte Inhalte: Bewertungen, Wunschliste, Empfehlungen, Top 3,
Sammlungsnamen, Biografie — alles in `user_games`, `user_collections`,
`user_top_three`, `profiles`.

Sonstige Aktionen: die elf Umami-Ereignisse aus `analytics_events.dart`
(`app_open`, `signup`, `rate_game`, …). **Ohne Nutzerkennung und ohne Cookies**,
selbst gehostet in Nürnberg.

### App-Informationen und Leistung

| Datentyp | Erhoben | Geteilt | Pflicht | Zweck |
|---|---|---|---|---|
| **Absturzprotokolle** | Ja | Nein | Nein | Analysen |
| **Diagnosedaten** | Ja | Nein | Nein | Analysen |

Quelle: Sentry, deutsche Region. `main.dart` setzt `sendDefaultPii = false` —
also **keine** IP-Adresse und **keine** Nutzerkennung in den Fehlerberichten,
nur Stacktrace, App-Version und Gerätetyp.

---

## Was ausdrücklich **nicht** erhoben wird

Diese Häkchen bleiben leer, und dafür gibt es jeweils einen Grund im Code:

- **Standort** — die App fragt keine Ortungsberechtigung an
- **Finanzdaten** — der Kauf läuft vollständig über Google Play Billing; wir
  sehen keine Zahlungsdaten
- **Kontakte, Kalender, SMS, Anrufe, Gesundheit, Musik, Dateien** — keine
  Berechtigung, kein Code dafür
- **Werbe-ID** — die App zeigt keine Werbung und bindet kein Werbe-SDK ein
- **Suchverlauf** — Suchanfragen werden nicht gespeichert
- **Installierte Apps** — nicht abgefragt

---

## Verschlüsselung und Aufbewahrung

- **Bei der Übertragung verschlüsselt:** ja, durchgehend HTTPS.
- **Nutzer können Löschung beantragen:** ja, in der App.
- Aufbewahrung: siehe § 5 der Datenschutzerklärung.

---

## Nach dem Ausfüllen

Die Erklärung muss zur **Datenschutzerklärung** passen, die im Store verlinkt
ist. Beide sagen dasselbe — wenn du hier etwas anders anklickst, als in
`assets/legal/datenschutz.md` steht, ändere zuerst die Datenschutzerklärung
und sag mir Bescheid, damit die Fassung in der App mitkommt.
