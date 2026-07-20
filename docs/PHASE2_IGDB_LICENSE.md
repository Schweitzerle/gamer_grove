# Phase 2 — Game-Data License Decision (IGDB vs. Alternatives)

> Research doc for the Phase-2 blocker "IGDB commercial license". Written
> 2026-07-20 (Session 4). This is a **business/legal decision for the user** —
> below is the research + a clear recommendation. Not legal advice; confirm the
> conservative items with IGDB/counsel before commercial launch.

## TL;DR — Recommendation: **Stay on IGDB, confirm the commercial arrangement, keep the adapter seam**

1. **Keep IGDB** as the primary data source. It is the richest source, already
   integrated, and — crucially — GamerGrove's architecture is **already
   compatible** with its strictest term (24-h caching), see §3.
2. **Confirm commercial standing** with IGDB (email `partner@igdb.com`) so we
   have it in writing before charging money. The API itself is free.
3. **Finish the Edge-Function proxy** (already a Phase-2 ticket): moves the
   Twitch/IGDB client secret off the device and gives a clean, auditable,
   server-side commercial integration.
4. **Keep the `IgdbDataSource` adapter seam clean** so RAWG can be a drop-in
   fallback if IGDB ever changes terms. Do **not** rip out IGDB.

The one genuine user action that gates commercial launch: **send the IGDB
commercial-use email and keep the reply.** Everything else is engineering we do.

---

## 1. IGDB (current source) — free, governed by the Twitch Developer Services Agreement (TDSA)

- IGDB was acquired by Twitch/Amazon (2019). The API is served through Twitch
  auth (Client-ID + Client-Secret → OAuth token) and is **free for both
  non-commercial and commercial use**, but commercial users are expected to
  operate under the **Twitch Developer Services Agreement** and to reach out for
  a commercial partnership: **`partner@igdb.com`**.
- **No mandatory in-app attribution** (unlike RAWG). Cleaner for a mobile UI.
- **TDSA constraints that matter to us:**
  - **24-hour caching limit**: you may not store copies of the data beyond a
    24-hour cache without written authorization, and must not re-syndicate it to
    third parties.
  - Must **honor deletions/changes** (delete/refresh when upstream changes).
  - Must **not** use the data to **target end users with off-platform
    marketing**.
- **Cost:** the API is free; a commercial agreement is a sign-off, not a price
  tier (no published fee). Rate limits apply (≈4 req/s per client) — the
  Edge-Function proxy is the right place to add caching within the 24-h window +
  backoff.

## 2. Alternatives (evaluated as fallback, not primary)

| Source | Commercial terms | Attribution | Redistribution | Verdict |
|---|---|---|---|---|
| **RAWG** | Free ≤ **100k MAU / 500k pageviews/mo**; above that email `api@rawg.io` | **Required: visible active hyperlink to RAWG on every page/screen that shows its data** | Prohibited (own project only) | Good **fallback**; the mandatory per-screen attribution link is intrusive in a mobile app, and the 100k-MAU ceiling is a future paywall trigger |
| **MobyGames** | Paid commercial API tiers | Per contract | Per contract | Deep historical data, but paid + smaller modern coverage; not worth a migration now |
| **Giant Bomb** | **Non-commercial only** by default | Required | Restricted | Not viable for a paid product |
| **Steam / store APIs** | Store-specific, PC-centric | — | — | Not a general games DB; complementary at best |

RAWG is the only realistic swap-in. Its data model differs (no direct 1:1 with
IGDB ids), so a real migration means an ID-mapping layer — a multi-week effort,
justified only if IGDB terms change.

## 3. Why IGDB is architecturally low-risk for us (important)

GamerGrove's Supabase schema stores **only `game_id` (INTEGER) references** —
tables `user_games`, `user_top_three`, `user_activity` key user data (rating,
wishlist, recommend, top-3) by IGDB game id. **No IGDB metadata (names, covers,
summaries) is persisted** in our DB; it is fetched live from IGDB at runtime and
held only transiently in memory.

➡️ This means we **do not violate the TDSA 24-h caching rule today**: we are not
a cache/mirror of IGDB content, we are a user-data layer keyed by IGDB ids.
Migrating sources would only require re-mapping those ids — the data seam is
already correct. This is a strong reason to stay.

**Residual items to close for a clean commercial posture:**
- [ ] **Edge-Function proxy** for IGDB (removes the client secret from the app —
      currently shipped via `envied`, obfuscated but present on-device — and
      centralizes auth + within-24h caching + rate-limit handling). *(Eng — us.)*
- [ ] If we ever add server-side caching of IGDB responses, **cap TTL ≤ 24 h**
      and exclude it from any third-party sharing. *(Eng — us.)*
- [ ] Name IGDB as a data source in the **privacy policy / imprint** (Phase 4
      legal). *(Eng — us, with user sign-off.)*

## 4. Action items

**User (gates commercial launch):**
- [ ] Email `partner@igdb.com` stating GamerGrove is a commercial app using the
      IGDB API under the TDSA; keep the reply on file. (Template can be drafted.)

**Engineering (we do, no blocker):**
- [ ] Keep `IgdbDataSource` the single seam; RAWG adapter remains a future option.
- [ ] Build the IGDB Edge-Function proxy (security + commercial hygiene).
- [ ] Ensure any future caching respects the 24-h TDSA window.

## Sources
- IGDB API docs / getting started — https://api-docs.igdb.com/
- Twitch Developer Forums, "Commercial use of IGDB API" — https://discuss.dev.twitch.com/t/commercial-use-of-igdb-api/23567
- Twitch Developer Services Agreement — https://legal.twitch.com/legal/developer-agreement/
- RAWG API docs — https://rawg.io/apidocs
- RAWG API Terms of Service — https://rawg.io/tos_api
