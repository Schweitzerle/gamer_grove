// RevenueCat -> Supabase webhook.
//
// Mirrors the Pro entitlement into profiles.is_pro / pro_expires_at so the
// database can enforce paid limits (see SupabaseScripts/014). RevenueCat stays
// the source of truth; this is a cache that the client never writes.
//
// Deploy:
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

/// Entitlement identifier configured in RevenueCat, matching the Flutter client.
const PRO_ENTITLEMENT = 'pro';

/// Event types that mean "Pro is active from now until expiration".
const GRANTING = new Set([
  'INITIAL_PURCHASE',
  'RENEWAL',
  'UNCANCELLATION',
  'NON_RENEWING_PURCHASE',
  'PRODUCT_CHANGE',
  'SUBSCRIPTION_EXTENDED',
]);

/// Event types that revoke access immediately.
const REVOKING = new Set(['EXPIRATION', 'REFUND', 'SUBSCRIPTION_PAUSED']);

// CANCELLATION is deliberately in neither set: the user keeps access until the
// period ends, and RevenueCat sends EXPIRATION when it actually lapses.

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  const secret = Deno.env.get('REVENUECAT_WEBHOOK_SECRET');
  if (!secret) {
    console.error('REVENUECAT_WEBHOOK_SECRET is not set');
    return new Response('Not configured', { status: 500 });
  }
  if (req.headers.get('Authorization') !== `Bearer ${secret}`) {
    return new Response('Unauthorized', { status: 401 });
  }

  let event: Record<string, unknown>;
  try {
    const body = await req.json();
    event = (body.event ?? {}) as Record<string, unknown>;
  } catch {
    return new Response('Bad request', { status: 400 });
  }

  const type = String(event.type ?? '');
  const userId = String(event.app_user_id ?? '');
  // The client sets appUserID to the Supabase user id, so this maps directly.
  if (!userId) {
    return new Response('Missing app_user_id', { status: 400 });
  }

  const entitlements = (event.entitlement_ids as string[] | undefined) ??
    (event.entitlement_id ? [String(event.entitlement_id)] : []);
  // Events for other entitlements must not touch Pro.
  if (entitlements.length > 0 && !entitlements.includes(PRO_ENTITLEMENT)) {
    return new Response('Ignored: other entitlement', { status: 200 });
  }

  let isPro: boolean;
  if (GRANTING.has(type)) {
    isPro = true;
  } else if (REVOKING.has(type)) {
    isPro = false;
  } else {
    // TEST, CANCELLATION, BILLING_ISSUE, TRANSFER, … — nothing to change.
    return new Response(`Ignored: ${type}`, { status: 200 });
  }

  const expiresMs = Number(event.expiration_at_ms ?? 0);
  const expiresAt = isPro && expiresMs > 0
    ? new Date(expiresMs).toISOString()
    : null;

  // Service role: the guard trigger rejects Pro writes from anyone else.
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  const { error } = await supabase
    .from('profiles')
    .update({ is_pro: isPro, pro_expires_at: expiresAt })
    .eq('id', userId);

  if (error) {
    console.error('profile update failed', { type, userId, error });
    // 5xx makes RevenueCat retry, which is what we want for a transient fault.
    // The message goes back to the caller — only reachable with the shared
    // secret, and without it a failing webhook is near-impossible to diagnose.
    return new Response(`Update failed: ${error.message}`, { status: 500 });
  }

  console.log('pro status updated', { type, userId, isPro, expiresAt });
  return new Response('OK', { status: 200 });
});
