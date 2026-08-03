// Run: deno test supabase/functions/revenuecat-webhook/
//
// The rules that decide who is Pro. Payload shapes follow RevenueCat's
// documented sample events — in particular TRANSFER, which carries no
// app_user_id and named neither side to the first version of this code.

import { assertEquals } from 'jsr:@std/assert@1';
import { decide } from './decide.ts';

const ALICE = '4bedb450-8ef2-11e9-b475-0800200c9a66';
const BOB = '00005a1c-6091-4f81-be77-f0a83a271ab6';
const AT = 1_754_000_000_000;
const AT_ISO = new Date(AT).toISOString();

const event = (extra: Record<string, unknown>) => ({
  event_timestamp_ms: AT,
  ...extra,
});

Deno.test('a purchase grants Pro until the period ends', () => {
  const expires = AT + 30 * 24 * 60 * 60 * 1000;
  const decision = decide(event({
    type: 'INITIAL_PURCHASE',
    app_user_id: ALICE,
    entitlement_ids: ['pro'],
    expiration_at_ms: expires,
  }));

  assertEquals(decision, {
    kind: 'write',
    eventAt: AT_ISO,
    writes: [{
      userId: ALICE,
      isPro: true,
      expiresAt: new Date(expires).toISOString(),
    }],
  });
});

Deno.test('an expiry revokes it', () => {
  const decision = decide(event({
    type: 'EXPIRATION',
    app_user_id: ALICE,
    entitlement_ids: ['pro'],
  }));

  assertEquals(decision, {
    kind: 'write',
    eventAt: AT_ISO,
    writes: [{ userId: ALICE, isPro: false, expiresAt: null }],
  });
});

Deno.test('a cancellation does not — access runs to the end of the period', () => {
  const decision = decide(event({
    type: 'CANCELLATION',
    app_user_id: ALICE,
    entitlement_ids: ['pro'],
  }));

  assertEquals(decision, { kind: 'ignore', reason: 'CANCELLATION' });
});

Deno.test('a billing issue does not — it opens a grace period', () => {
  const decision = decide(event({
    type: 'BILLING_ISSUE',
    app_user_id: ALICE,
    entitlement_ids: ['pro'],
  }));

  assertEquals(decision, { kind: 'ignore', reason: 'BILLING_ISSUE' });
});

Deno.test('a reversed refund grants Pro again', () => {
  // The REFUND before it set is_pro to false. Without this the user pays and
  // stays revoked until the next renewal, which may be a month away.
  const decision = decide(event({
    type: 'REFUND_REVERSED',
    app_user_id: ALICE,
    entitlement_ids: ['pro'],
    expiration_at_ms: AT + 1000,
  }));

  assertEquals(decision.kind, 'write');
  if (decision.kind !== 'write') return;
  assertEquals(decision.writes[0].isPro, true);
});

Deno.test('a transfer revokes the source and grants the destination', () => {
  // The event RevenueCat sends with no app_user_id. The old code rejected it,
  // which left BOB flagged Pro forever and ALICE paying for a limit she could
  // not pass.
  const decision = decide(event({
    type: 'TRANSFER',
    transferred_from: [BOB],
    transferred_to: [ALICE],
  }));

  assertEquals(decision, {
    kind: 'write',
    eventAt: AT_ISO,
    writes: [
      { userId: BOB, isPro: false, expiresAt: null },
      { userId: ALICE, isPro: true, expiresAt: null },
    ],
  });
});

Deno.test('a transfer from an anonymous id still grants the destination', () => {
  const decision = decide(event({
    type: 'TRANSFER',
    transferred_from: ['$RCAnonymousID:8a4b1c'],
    transferred_to: [ALICE],
  }));

  assertEquals(decision, {
    kind: 'write',
    eventAt: AT_ISO,
    writes: [{ userId: ALICE, isPro: true, expiresAt: null }],
  });
});

Deno.test('a transfer naming neither side is refused', () => {
  const decision = decide(event({ type: 'TRANSFER' }));
  assertEquals(decision, {
    kind: 'reject',
    reason: 'Transfer names neither side',
  });
});

Deno.test('a purchase under an anonymous id is ignored, not retried', () => {
  // Buying before signing in. Answering 4xx or 5xx here would have RevenueCat
  // retrying a request that can never succeed.
  const decision = decide(event({
    type: 'INITIAL_PURCHASE',
    app_user_id: '$RCAnonymousID:8a4b1c',
    entitlement_ids: ['pro'],
  }));

  assertEquals(decision, { kind: 'ignore', reason: 'Not a Supabase user' });
});

Deno.test('another entitlement never touches Pro', () => {
  const decision = decide(event({
    type: 'INITIAL_PURCHASE',
    app_user_id: ALICE,
    entitlement_ids: ['cosmetics'],
  }));

  assertEquals(decision, { kind: 'ignore', reason: 'Other entitlement' });
});

Deno.test('an event without a timestamp is refused', () => {
  // It is the only thing that can order two deliveries. Guessing would mean
  // guessing whether a late expiry outranks a fresh renewal.
  const decision = decide({ type: 'RENEWAL', app_user_id: ALICE });
  assertEquals(decision, {
    kind: 'reject',
    reason: 'Missing event_timestamp_ms',
  });
});

Deno.test('a grant with no expiry means active with no known end', () => {
  const decision = decide(event({
    type: 'NON_RENEWING_PURCHASE',
    app_user_id: ALICE,
    entitlement_ids: ['pro'],
  }));

  assertEquals(decision.kind, 'write');
  if (decision.kind !== 'write') return;
  assertEquals(decision.writes[0], {
    userId: ALICE,
    isPro: true,
    expiresAt: null,
  });
});
