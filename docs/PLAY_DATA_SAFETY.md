# Data-Safety-Erklärung — Antwortbogen

Play Console → **App-Inhalte → Datensicherheit**. Nur dort zu pflegen; die
Play-API kennt dieses Formular nicht.

Der Stand von versionCode 5 kennt weder RevenueCat noch Sentry noch Umami.

Aufgebaut in der Reihenfolge, in der das Formular fragt, mit den amtlichen
Bezeichnungen der Kategorien und Datentypen. Zu jeder Angabe die Stelle im
Code, aus der sie folgt — damit sie beim nächsten Mal nachprüfbar ist, statt
erinnert werden zu müssen.

---

## Die Fragefolge

Play fragt pro **Datentyp** immer dasselbe, in dieser Reihenfolge:

1. **Erhoben, geteilt, oder beides?**
2. **Wird ephemer verarbeitet?** — nur im Speicher, verlässt das Gerät nie. Ist
   das der Fall, entfällt die Angabe als „erhoben".
3. **Erforderlich oder optional?** — kann die Person die Erhebung abwählen?
4. **Zweck**, mehrfach wählbar — und für *erhoben* und *geteilt* getrennt.

**„Geteilt" ist enger, als es klingt:** Daten an einen Auftragsverarbeiter, der
sie nur für uns verarbeitet, gelten **nicht** als geteilt. Nur eine Weitergabe
an einen Dritten, der sie für eigene Zwecke nutzen darf, zählt.

> **Korrektur zu meinem ersten Entwurf:** Ich hatte die Nutzer-ID als „geteilt"
> geführt, weil sie an RevenueCat geht. Das ist falsch. RevenueCat verarbeitet
> sie ausschließlich für uns, damit ein Abo dem Konto zugeordnet werden kann,
> und wird in der Datenschutzerklärung genau so geführt. **Wir teilen nichts.**

---

## Personenbezogene Daten

### Name

| Frage | Antwort |
|---|---|
| Erhoben / geteilt | **erhoben**, nicht geteilt |
| Ephemer | nein |
| Erforderlich / optional | **erforderlich** |
| Zweck | App-Funktionalität · Kontoverwaltung |

Der Benutzername ist bei der Registrierung Pflicht (`profiles.username`), der
Anzeigename optional. Weil einer der beiden erforderlich ist, ist die Angabe
insgesamt erforderlich.

### E-Mail-Adresse

| Frage | Antwort |
|---|---|
| Erhoben / geteilt | **erhoben**, nicht geteilt |
| Ephemer | nein |
| Erforderlich / optional | **erforderlich** |
| Zweck | Kontoverwaltung |

Registrierung über Supabase Auth. Das Passwort ist kein eigener Datentyp im
Formular und wird ohnehin nur als Hash gespeichert.

### Nutzer-IDs

| Frage | Antwort |
|---|---|
| Erhoben / geteilt | **erhoben**, nicht geteilt |
| Ephemer | nein |
| Erforderlich / optional | **erforderlich** |
| Zweck | App-Funktionalität · Kontoverwaltung |

Die Supabase-Konto-ID. Sie geht an RevenueCat — als Auftragsverarbeiter, siehe
oben, also nicht „geteilt". Quelle:
`RevenueCatEntitlementService.configure(appUserId:)`.

---

## Finanzielle Informationen

### Kaufhistorie

| Frage | Antwort |
|---|---|
| Erhoben / geteilt | **erhoben**, nicht geteilt |
| Ephemer | nein |
| Erforderlich / optional | **optional** |
| Zweck | App-Funktionalität · Kontoverwaltung |

Nicht der Kauf selbst — den wickelt Google ab und wir sehen keine Zahlungsdaten
—, aber sein Ergebnis: `profiles.is_pro` und `pro_expires_at`, gespiegelt vom
`revenuecat-webhook`. Optional, weil das nur entsteht, wenn jemand ein Abo
abschließt.

**Nicht ankreuzen:** Zahlungsinformationen, Bonität, sonstige Finanzdaten.

---

## Fotos und Videos

### Fotos

| Frage | Antwort |
|---|---|
| Erhoben / geteilt | **erhoben**, nicht geteilt |
| Ephemer | nein |
| Erforderlich / optional | **optional** |
| Zweck | App-Funktionalität |

Das Profilbild, in Supabase Storage. Rein freiwillig.

---

## App-Aktivität

### App-Interaktionen

| Frage | Antwort |
|---|---|
| Erhoben / geteilt | **erhoben**, nicht geteilt |
| Ephemer | nein |
| Erforderlich / optional | **erforderlich** |
| Zweck | Analysen |

Die elf Umami-Ereignisse aus `analytics_events.dart`. Der Rumpf enthält
`website`, `hostname`, `language`, `url`, den Ereignisnamen und die
Eigenschaften `game_id`, `rating`, `screen`, `plan`, `source` — **keine
Nutzerkennung, keine Cookies, keine Geräte-ID**
(`umami_analytics_service.dart`). Selbst gehostet in Nürnberg.

> **„Erforderlich", weil es keinen Schalter gibt.** Die Frage lautet, ob die
> Person die Erhebung abwählen kann, nicht ob die App ohne sie liefe. Es gibt
> keine Abschaltung, also ist die ehrliche Antwort „erforderlich". Wenn dir das
> nicht gefällt, ist die Lösung ein Schalter in den Einstellungen — dann wird
> daraus „optional". Sag Bescheid, das ist eine überschaubare Änderung.

### Sonstige nutzergenerierte Inhalte

| Frage | Antwort |
|---|---|
| Erhoben / geteilt | **erhoben**, nicht geteilt |
| Ephemer | nein |
| Erforderlich / optional | **optional** |
| Zweck | App-Funktionalität |

Bewertungen, Rezensionstexte, Wunschliste, Empfehlungen, Top 3,
Sammlungsnamen, Biografie. Tabellen `user_games`, `user_collections`,
`user_top_three`, `profiles`.

**Nicht ankreuzen:** In-App-Suchverlauf (Suchanfragen werden nicht
gespeichert), installierte Apps, sonstige Aktionen.

---

## App-Informationen und Leistung

### Absturzprotokolle

| Frage | Antwort |
|---|---|
| Erhoben / geteilt | **erhoben**, nicht geteilt |
| Ephemer | nein |
| Erforderlich / optional | **erforderlich** |
| Zweck | Analysen |

Sentry, deutsche Region. `main.dart` setzt `sendDefaultPii = false` — also
weder IP-Adresse noch Nutzerkennung, nur Stacktrace, App-Version und Gerätetyp.

### Diagnosedaten

| Frage | Antwort |
|---|---|
| Erhoben / geteilt | **erhoben**, nicht geteilt |
| Ephemer | nein |
| Erforderlich / optional | **erforderlich** |
| Zweck | Analysen |

Sentry-Performance-Traces: `tracesSampleRate = 0.2` im Release, also jede
fünfte Sitzung.

---

## Geräte- oder andere IDs

### Geräte- oder andere IDs

| Frage | Antwort |
|---|---|
| Erhoben / geteilt | **erhoben**, nicht geteilt |
| Ephemer | nein |
| Erforderlich / optional | **erforderlich** |
| Zweck | Analysen |

> **Hier bin ich mir nicht sicher, und das sage ich lieber, als es zu raten.**
> Sentry führt „Release Health" standardmäßig mit und legt dafür eine stabile
> Installations-Kennung an. `sendDefaultPii = false` schaltet IP und
> Nutzername ab, diese Kennung aber nicht zwangsläufig.
>
> **Sicherer Weg:** ankreuzen. Zu viel erklären kostet nichts, zu wenig ist ein
> Verstoß.
> **Sauberer Weg:** `enableAutoSessionTracking = false` setzen, dann entfällt
> die Kennung und das Häkchen mit ihr. Das kann ich machen — es kostet die
> Absturzfreiheitsrate pro Release, sonst nichts.

---

## Was leer bleibt

Für jedes davon gibt es einen Grund im Code, nicht nur eine Annahme:

- **Standort** — keine Ortungsberechtigung im Manifest
- **Zahlungsinformationen** — der Kauf läuft vollständig über Google Play Billing
- **Gesundheit und Fitness, Nachrichten, Audio, Dateien, Kalender, Kontakte** —
  keine Berechtigung, kein Code
- **Web-Browserverlauf** — die App hat keinen Browser
- **In-App-Suchverlauf** — Suchanfragen werden nicht gespeichert
- **Installierte Apps** — nicht abgefragt
- **Werbe-ID** — kein Werbe-SDK, keine Werbung

---

## Die zwei allgemeinen Fragen

| Frage | Antwort |
|---|---|
| Werden alle Nutzerdaten bei der Übertragung verschlüsselt? | **Ja** — Supabase, Sentry, Umami und der IGDB-Proxy laufen ausschließlich über HTTPS |
| Können Nutzer die Löschung ihrer Daten beantragen? | **Ja** |

> **Die URL, die Play zusätzlich verlangt:**
> `https://schweitzerle.github.io/gamer_grove/delete-account/`
>
> Sie gehört im Formular in das Feld für die Lösch-URL. Die Seite nennt, was
> gelöscht wird, wie es in der App geht, und wie man es ohne die App beantragt
> — für Leute, die die App schon deinstalliert haben.
>
> **Nicht auf Supabase gehostet, und das war eine Lehre:** das Edge-Gateway
> erzwingt `Content-Type: text/plain` und `CSP: default-src 'none'; sandbox`
> auf jede Function-Antwort, damit niemand browsbare Seiten auf `supabase.co`
> stellt. Die Seite kam als Quelltext heraus. Jetzt GitHub Pages aus `web/`.

---

## Ein Fund beim Abgleich

Die Datenschutzerklärung sagt noch:

> „IGDB / Twitch … Beim Abruf von Spielinformationen wird deine IP-Adresse an
> diesen Dienst übertragen."

**Das stimmt seit dem IGDB-Proxy (#142) nicht mehr.** Der Client spricht nur
noch mit unserer Edge Function in Frankfurt; IGDB sieht deren IP, nicht die des
Nutzers. Die Erklärung gibt also mehr an, als passiert — und die einzige
verbliebene Übermittlung in die USA ist die Konto-ID an RevenueCat.

Das gehört korrigiert, bevor die Data-Safety-Angabe daneben steht. Sag
Bescheid, dann ziehe ich `datenschutz.md` und die englische Fassung nach.

---

## Quellen

- [Provide information for Google Play's Data safety section](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en) — Kategorien, Datentypen, Zwecke
- [Google Play Data Safety Form: The Complete Walkthrough](https://applander.io/blog/google-play-data-safety-form-complete-guide) — Reihenfolge der Fragen je Datentyp
