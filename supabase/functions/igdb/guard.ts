// What a request to the IGDB proxy has to satisfy before any credential of
// ours is put on the wire — decided without network access, so it can be
// tested for what it is: a set of rules.
//
// The handler in index.ts turns the outcome into a Response and, for anything
// that passes, into the one round trip that establishes who is asking.

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
export const ALLOWED = new Set([
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
export const MAX_QUERY = 4000;

export type Rejection = { status: number; message: string };
export type Accepted = { endpoint: string; query: string };

/// The bearer token the caller presented, or null.
///
/// Returned verbatim rather than parsed here: this module must not be in the
/// business of trusting claims. Whether the token belongs to a real user is
/// settled by PostgREST, which checks the signature before the rate-limit
/// function runs — see SupabaseScripts/026.
export function bearerFrom(headers: Headers): string | null {
  const raw = headers.get('Authorization') ?? headers.get('authorization');
  if (!raw) return null;
  const match = /^Bearer\s+(.+)$/i.exec(raw.trim());
  if (!match) return null;
  const token = match[1].trim();
  return token.length > 0 ? token : null;
}

/// True when the token is the project's anon key rather than a user session.
///
/// A cheap first pass so the obvious case is refused without a round trip. It
/// is NOT the security boundary — a forged token would sail past it. The
/// boundary is `igdb_rate_limit_hit()`, which only ever sees a signature that
/// PostgREST already checked and refuses a null `auth.uid()`.
export function isAnonKey(token: string, anonKey: string | undefined): boolean {
  return anonKey !== undefined && anonKey.length > 0 && token === anonKey;
}

/// Validates the request body.
///
/// The rejection for an unknown endpoint deliberately does not name it. The
/// previous message echoed the caller's own string back — small, but it is
/// unvalidated input in a response, and it tells a prober exactly which of
/// their guesses got closest.
export function validate(body: unknown): Accepted | Rejection {
  if (typeof body !== 'object' || body === null) {
    return { status: 400, message: 'Body must be JSON' };
  }

  const { endpoint, query } = body as { endpoint?: unknown; query?: unknown };

  if (typeof endpoint !== 'string' || !ALLOWED.has(endpoint)) {
    return { status: 400, message: 'Unknown endpoint' };
  }
  if (typeof query !== 'string' || query.length === 0) {
    return { status: 400, message: 'A query is required' };
  }
  if (query.length > MAX_QUERY) {
    return { status: 413, message: 'Query too long' };
  }

  return { endpoint, query };
}

export function isRejection(v: Accepted | Rejection): v is Rejection {
  return 'status' in v;
}

/// Maps a Postgres error from `igdb_rate_limit_hit` onto a response.
///
/// 28000 is "not authenticated" — the anon key, or no session. 54000 is the
/// rate limit. Anything else is ours to fix, not the caller's to interpret,
/// so it becomes a flat 500 and gets logged server-side.
export function rateLimitOutcome(code: string | undefined): Rejection {
  if (code === '28000') {
    return { status: 401, message: 'Sign in to browse games' };
  }
  // PostgREST's own refusals for a token it will not accept — expired,
  // malformed, wrong signature. They mean the same thing to the caller as a
  // null auth.uid(), and reading as 500 would send them chasing our server.
  if (code === 'PGRST301' || code === 'PGRST302') {
    return { status: 401, message: 'Sign in to browse games' };
  }
  if (code === '54000') {
    return {
      status: 429,
      message: 'Too many requests — try again in a minute',
    };
  }
  return { status: 500, message: 'The IGDB proxy is not available' };
}

/// Whether calls presenting only the anon key are still served.
///
/// A transition switch, not a setting. Every build up to 2.1.0+43 sends the
/// anon key; the moment the proxy stops accepting it, those installations lose
/// the game catalogue entirely — the app becomes a shell. So the old path
/// stays open until a version that sends the session token has reached
/// everyone, and then it is closed with
///
///   supabase secrets set IGDB_ALLOW_ANON=false
///
/// which needs no redeploy.
///
/// While it is open the hole from #161 is open too: anon calls are served
/// without a caller and without a ceiling, exactly as before. What is gained
/// meanwhile is that they are counted in the logs, so "are there still any"
/// stops being guesswork.
export function anonStillAllowed(flag: string | undefined): boolean {
  return flag === 'true';
}
