// What a RevenueCat event means for our Pro mirror — decided without touching
// the database, so it can be tested for what it is: a table of rules.
//
// The handler in index.ts turns the outcome into writes. Keeping the two apart
// is what made the transfer bug visible: it was never a database problem, it
// was this table missing a row.

/// Entitlement identifier configured in RevenueCat, matching the Flutter client.
export const PRO_ENTITLEMENT = 'pro';

/// Event types that mean "Pro is active from now until expiration".
///
/// REFUND_REVERSED belongs here: a refund that was reversed means the purchase
/// stands again, and the REFUND that preceded it already set is_pro to false.
const GRANTING = new Set([
  'INITIAL_PURCHASE',
  'RENEWAL',
  'UNCANCELLATION',
  'NON_RENEWING_PURCHASE',
  'PRODUCT_CHANGE',
  'SUBSCRIPTION_EXTENDED',
  'REFUND_REVERSED',
]);

/// Event types that revoke access immediately.
const REVOKING = new Set(['EXPIRATION', 'REFUND', 'SUBSCRIPTION_PAUSED']);

// CANCELLATION is deliberately in neither set: the user keeps access until the
// period ends, and RevenueCat sends EXPIRATION when it actually lapses.
// BILLING_ISSUE likewise — it opens a grace period, it does not end one.

/// Supabase user ids are uuids; RevenueCat's own ids (`$RCAnonymousID:…`) are
/// not. `profiles.id` is a uuid column, so handing it anything else is not a
/// missing user but a malformed query — it would come back as an error and
/// have RevenueCat retrying a request that can never succeed.
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export const isSupabaseUserId = (id: string): boolean => UUID.test(id);

/// One row to write.
export interface ProWrite {
  userId: string;
  isPro: boolean;
  /// ISO timestamp, or null for "active with no known end".
  expiresAt: string | null;
}

export type Decision =
  /// Apply these writes, none of them older than `eventAt`.
  | { kind: 'write'; writes: ProWrite[]; eventAt: string }
  /// Nothing to mirror. Still a 2xx — anything else makes RevenueCat retry.
  | { kind: 'ignore'; reason: string }
  /// The payload is not one we can act on.
  | { kind: 'reject'; reason: string };

export function decide(event: Record<string, unknown>): Decision {
  const type = String(event.type ?? '');

  // Every event carries this, and retries reuse it. Without it there is no way
  // to order two deliveries, so refuse rather than guess.
  const eventMs = Number(event.event_timestamp_ms ?? 0);
  if (!Number.isFinite(eventMs) || eventMs <= 0) {
    return { kind: 'reject', reason: 'Missing event_timestamp_ms' };
  }
  const eventAt = new Date(eventMs).toISOString();

  // A transfer moves a subscription between app user ids. It is the one event
  // with no `app_user_id` at all — it names both sides instead — which is why
  // the first version of this function answered 400 and changed nothing. That
  // left the source account flagged Pro forever (its EXPIRATION goes to the
  // destination from then on) and the destination unable to pass the
  // server-side limit it is paying for.
  if (type === 'TRANSFER') {
    const from = (event.transferred_from as string[] | undefined) ?? [];
    const to = (event.transferred_to as string[] | undefined) ?? [];
    if (from.length === 0 && to.length === 0) {
      return { kind: 'reject', reason: 'Transfer names neither side' };
    }

    const writes: ProWrite[] = [
      ...from.filter(isSupabaseUserId).map((userId) => ({
        userId,
        isPro: false,
        expiresAt: null,
      })),
      // No expiration is sent with a transfer. Null means "active, no known
      // end" — which self-corrects, because every later event for this
      // subscription (RENEWAL, EXPIRATION) now addresses the destination.
      ...to.filter(isSupabaseUserId).map((userId) => ({
        userId,
        isPro: true,
        expiresAt: null,
      })),
    ];
    if (writes.length === 0) {
      return { kind: 'ignore', reason: 'Transfer between non-Supabase ids' };
    }
    return { kind: 'write', writes, eventAt };
  }

  const userId = String(event.app_user_id ?? '');
  // The client sets appUserID to the Supabase user id, so this maps directly.
  if (!userId) return { kind: 'reject', reason: 'Missing app_user_id' };
  if (!isSupabaseUserId(userId)) {
    // A purchase made before signing in belongs to a RevenueCat anonymous id.
    // Nothing to mirror yet — the TRANSFER that follows the next login carries
    // it over to the real account.
    return { kind: 'ignore', reason: 'Not a Supabase user' };
  }

  const entitlements = (event.entitlement_ids as string[] | undefined) ??
    (event.entitlement_id ? [String(event.entitlement_id)] : []);
  // Events for other entitlements must not touch Pro.
  if (entitlements.length > 0 && !entitlements.includes(PRO_ENTITLEMENT)) {
    return { kind: 'ignore', reason: 'Other entitlement' };
  }

  let isPro: boolean;
  if (GRANTING.has(type)) {
    isPro = true;
  } else if (REVOKING.has(type)) {
    isPro = false;
  } else {
    // TEST, CANCELLATION, BILLING_ISSUE, TEMPORARY_ENTITLEMENT_GRANT, … —
    // nothing to change. A temporary grant is deliberately not mirrored: it
    // exists because RevenueCat could not reach the store, and the client SDK
    // already honours it for the features that live on the device.
    return { kind: 'ignore', reason: type };
  }

  const expiresMs = Number(event.expiration_at_ms ?? 0);
  const expiresAt = isPro && expiresMs > 0
    ? new Date(expiresMs).toISOString()
    : null;

  return { kind: 'write', writes: [{ userId, isPro, expiresAt }], eventAt };
}
