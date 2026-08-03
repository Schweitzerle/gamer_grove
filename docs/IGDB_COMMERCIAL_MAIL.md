# Mail an IGDB — Entwurf

Offen seit Session 4 (`docs/PHASE2_IGDB_LICENSE.md`): die Bestätigung für die
kommerzielle Nutzung. Sie gehört **vor** den bezahlten Launch, weil GamerGrove
Pro verkauft — nicht danach.

An: `partner@igdb.com`
Betreff: `Commercial use confirmation — GamerGrove (Android)`

---

Hello,

I run GamerGrove, an Android app that uses the IGDB API to let people rate the
games they play, keep wishlists and their own collections, and follow other
players. It is live on Google Play as `com.schweizerle.gamergrove`.

I would like to confirm that our use is within the terms before we start
charging for anything.

**How we use the API**

- All game data is fetched from IGDB at request time through a server-side
  proxy. The client never holds our credentials.
- We store no IGDB metadata. Our database keeps only the numeric `game_id`
  alongside a user's own rating, wishlist flag and collection membership —
  everything shown about a game is fetched from IGDB each time it is needed.
- Every screen that shows game data carries the attribution: "This app uses the
  IGDB API but is not endorsed or certified by IGDB." The IGDB logo is shown in
  the app's settings.

**What we charge for**

The app is free. A subscription called GamerGrove Pro (€2.99 monthly / €19.99
yearly through Google Play) unlocks statistics about the user's own library,
additional filters, unlimited collections and colour themes.

**None of the paid features resell, redistribute or repackage IGDB data** — the
game data itself is fully available without paying. Pro is about what the user
has done with their own library.

We are a one-person company (SchweizerleLab, Julian Schweizer) based in Germany.

Could you confirm that this use is covered, or tell me what we would need to
change or which agreement we would need to sign?

Thank you,
Julian Schweizer
SchweizerleLab
schweizerlemail@gmail.com

---

## Warum genau so

- **Das Caching zuerst.** Die 24-Stunden-Regel der TDSA ist der Punkt, an dem
  Katalog-Apps auffallen. Wir speichern nur `game_id`, halten sie also ohne
  Ausnahme ein, und das steht im zweiten Absatz statt versteckt am Ende.
- **Der Preis ehrlich genannt.** Wer nachfragt, ob eine Bezahl-App in Ordnung
  ist, und den Preis verschweigt, bekommt eine Antwort auf eine andere Frage.
- **Die Trennung ausgesprochen:** Pro verkauft keine Spieldaten. Das ist die
  Unterscheidung, an der die Antwort hängen wird.
- **Eine Frage am Ende**, nicht drei. Sie kann mit „ja" beantwortet werden.
