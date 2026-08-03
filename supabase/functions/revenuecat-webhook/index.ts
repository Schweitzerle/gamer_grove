// RevenueCat -> Supabase webhook.
//
// Mirrors the Pro entitlement into profiles.is_pro / pro_expires_at so the
// database can enforce paid limits (see SupabaseScripts/014). RevenueCat stays
// the source of truth; this is a cache that the client never writes.
//
// What each event means lives in decide.ts; this file does the IO.
//
// Deploy (016 must be applied first — it adds the column this writes):
//   supabase functions deploy revenuecat-webhook --no-verify-jwt
//   supabase secrets set REVENUECAT_WEBHOOK_SECRET=<random string>
//
// Then in the RevenueCat dashboard (Integrations -> Webhooks):
//   URL:            https://<project>.supabase.co/functions/v1/revenuecat-webhook
//   Authorization:  Bearer <the same random string>
//
// `--no-verify-jwt` is required because RevenueCat does not send a Supabase
// JWT; the shared secret in the Authorization header is what authenticates it.

import { createClient } from 'jsr:@supabase/supabase-js@2';
import type { SupabaseClient } from 'jsr:@supabase/supabase-js@2';
import { decide, type ProWrite } from './decide.ts';

function fail(status: number, message: string): Response {
  return new Response(message, { status });
}

/// Writes the Pro state for one user, unless a newer event already did.
///
/// The comparison against `pro_event_at` is what makes this safe against the
/// two things RevenueCat does not promise: ordering and single delivery. A
/// retry carries the same `event_timestamp_ms` as the original, so `lt` turns
/// replays into no-ops, and a late EXPIRATION cannot revoke a subscription
/// that a newer RENEWAL already extended.
async function applyPro(
  supabase: SupabaseClient,
  write: ProWrite,
  eventAt: string,
): Promise<{ applied: boolean; error?: string }> {
  const { data, error } = await supabase
    .from('profiles')
    .update({
      is_pro: write.isPro,
      pro_expires_at: write.expiresAt,
      pro_event_at: eventAt,
    })
    .eq('id', write.userId)
    // A plain comparison, and it has to stay one. The obvious spelling —
    // `.or('pro_event_at.is.null,pro_event_at.lt.…')`, back when the column was
    // nullable — reads fine and fails on an UPDATE: PostgREST qualifies columns
    // inside an `or` group as `profiles.<col>`, and in the statement it builds
    // for an UPDATE the relation is not called `profiles`, so Postgres answers
    // 42703 "column profiles.pro_event_at does not exist" about a column that
    // is plainly there. The same group on a SELECT works, which is what makes
    // it worth a comment. Migration 017 gives the column a default of
    // -infinity so no null case is left to handle.
    .lt('pro_event_at', eventAt)
    .select('id');

  if (error) return { applied: false, error: error.message };
  return { applied: (data ?? []).length > 0 };
}

/// Why nothing was written for a user that should exist.
///
/// Three ways to write nothing, and they need telling apart: a replay, an
/// event older than the one on record, or an app_user_id that is not a
/// Supabase user at all. The last is a misconfiguration that would otherwise
/// look like a working webhook forever.
async function explainNoWrite(
  supabase: SupabaseClient,
  userId: string,
): Promise<'unknown-user' | 'stale'> {
  const { data } = await supabase
    .from('profiles')
    .select('id')
    .eq('id', userId)
    .maybeSingle();
  return data == null ? 'unknown-user' : 'stale';
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') return fail(405, 'Method not allowed');

  const secret = Deno.env.get('REVENUECAT_WEBHOOK_SECRET');
  if (!secret) {
    console.error('REVENUECAT_WEBHOOK_SECRET is not set');
    return fail(500, 'Not configured');
  }
  if (req.headers.get('Authorization') !== `Bearer ${secret}`) {
    return fail(401, 'Unauthorized');
  }

  let event: Record<string, unknown>;
  try {
    const body = await req.json();
    event = (body.event ?? {}) as Record<string, unknown>;
  } catch {
    return fail(400, 'Bad request');
  }

  const decision = decide(event);
  if (decision.kind === 'reject') return fail(400, decision.reason);
  if (decision.kind === 'ignore') {
    console.log('ignored', { type: event.type, reason: decision.reason });
    return new Response(`Ignored: ${decision.reason}`, { status: 200 });
  }

  const supabase = createClient(
    // Service role: the guard trigger rejects Pro writes from anyone else.
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  const failures: string[] = [];
  const skipped: string[] = [];
  for (const write of decision.writes) {
    const result = await applyPro(supabase, write, decision.eventAt);
    if (result.error) {
      failures.push(`${write.userId}: ${result.error}`);
    } else if (!result.applied) {
      const why = await explainNoWrite(supabase, write.userId);
      if (why === 'unknown-user') {
        console.error('no profile for app_user_id', {
          type: event.type,
          userId: write.userId,
        });
      }
      skipped.push(`${write.userId}: ${why}`);
    }
  }

  if (failures.length > 0) {
    console.error('profile update failed', { type: event.type, failures });
    // 5xx makes RevenueCat retry, which is what we want for a transient fault.
    // The message goes back to the caller — only reachable with the shared
    // secret, and without it a failing webhook is near-impossible to diagnose.
    return fail(500, `Update failed: ${failures.join('; ')}`);
  }

  if (skipped.length === decision.writes.length) {
    // Replays and out-of-order deliveries are correct outcomes, and must
    // answer 2xx or RevenueCat keeps retrying them.
    console.log('nothing written', { type: event.type, skipped });
    return new Response(`Ignored: ${skipped.join('; ')}`, { status: 200 });
  }

  console.log('pro status updated', {
    type: event.type,
    writes: decision.writes,
    skipped,
  });
  return new Response('OK', { status: 200 });
});
