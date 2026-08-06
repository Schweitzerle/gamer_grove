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
// Who may call it: a signed-in user, and no more than 120 times a minute.
//
// That is newer than the rest of this file. Until #161 the only requirement
// was "present a Supabase key", and the app sent the ANON key — which is
// readable out of the APK and sits in this repository's public git history.
// The function was therefore a free IGDB API on our Twitch credentials, with
// no caller and no ceiling, against an upstream budget of 4 requests/second.
//
// The check is a single call to `igdb_rate_limit_hit()` with the caller's own
// JWT (SupabaseScripts/026). PostgREST verifies the signature before the
// function body runs, the function refuses a null `auth.uid()`, and the same
// call counts the hit — identity and ceiling in one round trip.

import { createClient } from 'jsr:@supabase/supabase-js@2';
import {
  anonStillAllowed,
  bearerFrom,
  isAnonKey,
  isRejection,
  rateLimitOutcome,
  validate,
} from './guard.ts';

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

  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return fail(400, 'Body must be JSON');
  }

  const checked = validate(body);
  if (isRejection(checked)) return fail(checked.status, checked.message);
  const { endpoint, query } = checked;

  // ------------------------------------------------ who is asking, and how often
  // `callerToken`, not `token`: the module already has a `token` — the cached
  // Twitch credential. Shadowing it here made the cache invalidation on line
  // 149 assign to this constant instead, which the linter caught and a reader
  // would not have.
  const callerToken = bearerFrom(request.headers);
  if (callerToken === null) return fail(401, 'Sign in to browse games');

  // The case that used to be the whole of the app's traffic. Refused without a
  // round trip — but only once the installed base has moved; see
  // anonStillAllowed.
  const anonCall = isAnonKey(callerToken, Deno.env.get('SUPABASE_ANON_KEY'));
  if (anonCall) {
    if (!anonStillAllowed(Deno.env.get('IGDB_ALLOW_ANON'))) {
      return fail(401, 'Sign in to browse games');
    }
    // Counted so the tail of old installations is a number rather than a
    // guess. When this stops appearing, IGDB_ALLOW_ANON can go to false.
    console.warn('igdb: anon-key call served (pre-2.2 client)');
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
  if (!supabaseUrl || !anonKey) {
    console.error('SUPABASE_URL or SUPABASE_ANON_KEY is not set');
    return fail(500, 'The IGDB proxy is not configured');
  }

  // The caller's JWT, not the service role: the point is to act AS them, so
  // that auth.uid() is theirs and the count lands on their row.
  const caller = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: `Bearer ${callerToken}` } },
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { error: limitError } = anonCall
    ? { error: null }
    : await caller.rpc('igdb_rate_limit_hit');
  if (limitError) {
    const outcome = rateLimitOutcome(limitError.code);
    if (outcome.status === 500) {
      console.error('igdb_rate_limit_hit failed', limitError);
    }
    return fail(outcome.status, outcome.message);
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
