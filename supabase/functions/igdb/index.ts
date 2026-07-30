// IGDB proxy.
//
// The app used to call api.igdb.com directly, which meant it had to carry
// IGDB_CLIENT_SECRET to mint Twitch tokens. `envied` obfuscates that constant
// with a XOR mask, which raises the effort of extracting it and no more: the
// mask and the masked bytes both ship in the same binary. Obfuscating the whole
// binary (see tool/build_release.sh) raises it again, and still the only honest
// statement about a secret in a client is that it is not secret.
//
// So the secret lives here now. The app sends the query it wants; this holds
// the credentials, mints and caches the Twitch token, and forwards to IGDB.
//
// Deploy:
//   supabase functions deploy igdb
//   supabase secrets set IGDB_CLIENT_ID=<id> IGDB_CLIENT_SECRET=<secret>
//
// JWT verification stays ON (unlike the RevenueCat webhook): callers must
// present a Supabase key, which every build of the app already has. That does
// not make the endpoint private — the anon key is public by design — but it
// keeps the IGDB credentials off every device, which is the point.

/// Endpoints the app actually asks for.
///
/// An allowlist rather than a passthrough: without it this function would
/// forward any path to any IGDB endpoint on request, with our credentials
/// attached — a proxy and an open relay differ by exactly this list.
///
/// Derived from `endpoint:` in `igdb_datasource_impl.dart`, not typed by hand.
/// The hand-written first draft was missing four of them, which would have
/// broken age ratings, game statuses, game types and languages while
/// everything else kept working — the kind of failure that gets found by a
/// user, not by a build.
const ALLOWED = new Set([
  'age_rating_categories',
  'characters',
  'collections',
  'companies',
  'events',
  'franchises',
  'game_engines',
  'game_modes',
  'game_statuses',
  'game_types',
  'games',
  'genres',
  'keywords',
  'languages',
  'multiplayer_modes',
  'platforms',
  'player_perspectives',
  'themes',
]);

/// A query longer than this is not something the app sends.
const MAX_QUERY = 4000;

const TWITCH_TOKEN_URL = 'https://id.twitch.tv/oauth2/token';
const IGDB_BASE = 'https://api.igdb.com/v4';

/// Cached across invocations that happen to reuse this isolate. Twitch tokens
/// last about two months, so re-minting one per request would be both slow and
/// rude.
let token: { value: string; expiresAt: number } | null = null;

async function accessToken(id: string, secret: string): Promise<string> {
  // A minute of headroom, so a token that expires mid-flight is never used.
  if (token && Date.now() < token.expiresAt - 60_000) return token.value;

  const params = new URLSearchParams({
    client_id: id,
    client_secret: secret,
    grant_type: 'client_credentials',
  });
  const response = await fetch(`${TWITCH_TOKEN_URL}?${params}`, {
    method: 'POST',
  });
  if (!response.ok) {
    throw new Error(`Twitch refused the credentials (${response.status})`);
  }

  const body = await response.json();
  token = {
    value: body.access_token,
    expiresAt: Date.now() + body.expires_in * 1000,
  };
  return token.value;
}

function fail(status: number, message: string): Response {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

Deno.serve(async (request) => {
  if (request.method !== 'POST') return fail(405, 'POST only');

  const id = Deno.env.get('IGDB_CLIENT_ID');
  const secret = Deno.env.get('IGDB_CLIENT_SECRET');
  if (!id || !secret) {
    // Loud rather than silent: a missing secret here looks exactly like IGDB
    // being down, and would be chased in the wrong place for hours.
    console.error('IGDB_CLIENT_ID or IGDB_CLIENT_SECRET is not set');
    return fail(500, 'The IGDB proxy is not configured');
  }

  let endpoint: unknown;
  let query: unknown;
  try {
    ({ endpoint, query } = await request.json());
  } catch {
    return fail(400, 'Body must be JSON');
  }

  if (typeof endpoint !== 'string' || !ALLOWED.has(endpoint)) {
    return fail(400, `Unknown endpoint: ${endpoint}`);
  }
  if (typeof query !== 'string' || query.length === 0) {
    return fail(400, 'A query is required');
  }
  if (query.length > MAX_QUERY) {
    return fail(413, 'Query too long');
  }

  try {
    const bearer = await accessToken(id, secret);
    const response = await fetch(`${IGDB_BASE}/${endpoint}`, {
      method: 'POST',
      headers: {
        'Client-ID': id,
        'Authorization': `Bearer ${bearer}`,
        'Content-Type': 'text/plain',
      },
      body: query,
    });

    // A token can be revoked or rotated out from under the cache; one retry
    // with a fresh token turns that from an outage into a hiccup.
    if (response.status === 401) {
      token = null;
      const retryBearer = await accessToken(id, secret);
      const retry = await fetch(`${IGDB_BASE}/${endpoint}`, {
        method: 'POST',
        headers: {
          'Client-ID': id,
          'Authorization': `Bearer ${retryBearer}`,
          'Content-Type': 'text/plain',
        },
        body: query,
      });
      return new Response(await retry.text(), {
        status: retry.status,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    return new Response(await response.text(), {
      status: response.status,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    console.error('IGDB proxy failed', error);
    return fail(502, 'IGDB is unreachable');
  }
});
