import { assertEquals } from 'jsr:@std/assert@1';
import {
  ALLOWED,
  anonStillAllowed,
  bearerFrom,
  isAnonKey,
  isRejection,
  MAX_QUERY,
  rateLimitOutcome,
  validate,
} from './guard.ts';

const ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.anon.signature';
const SESSION = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.session.signature';

function headers(value?: string): Headers {
  return value === undefined
    ? new Headers()
    : new Headers({ Authorization: value });
}

Deno.test('a request without Authorization presents no token', () => {
  assertEquals(bearerFrom(headers()), null);
});

Deno.test('a bare token without the Bearer scheme is not accepted', () => {
  assertEquals(bearerFrom(headers(SESSION)), null);
});

Deno.test('Bearer is read case-insensitively and trimmed', () => {
  assertEquals(bearerFrom(headers(`bearer   ${SESSION}  `)), SESSION);
  assertEquals(bearerFrom(headers(`Bearer ${SESSION}`)), SESSION);
});

Deno.test('an empty Bearer value is no token', () => {
  assertEquals(bearerFrom(headers('Bearer   ')), null);
});

Deno.test('the anon key is recognised — the case that used to be all traffic', () => {
  // Every build of the app sent this. It is readable out of the APK and sits
  // in the public git history, which is what made the proxy a free IGDB API.
  assertEquals(isAnonKey(ANON, ANON), true);
  assertEquals(isAnonKey(SESSION, ANON), false);
});

Deno.test('with no anon key configured, nothing is mistaken for it', () => {
  // Otherwise an unset env var would turn every token into "the anon key" and
  // lock out every real user.
  assertEquals(isAnonKey(SESSION, undefined), false);
  assertEquals(isAnonKey(SESSION, ''), false);
  assertEquals(isAnonKey('', ''), false);
});

Deno.test('an unknown endpoint is refused without repeating it back', () => {
  const outcome = validate({ endpoint: 'users; drop table', query: 'f *;' });
  assertEquals(isRejection(outcome), true);
  if (!isRejection(outcome)) return;
  assertEquals(outcome.status, 400);
  // The old message interpolated the caller's own string into the response.
  assertEquals(outcome.message, 'Unknown endpoint');
  assertEquals(outcome.message.includes('drop table'), false);
});

Deno.test('every allowed endpoint passes', () => {
  for (const endpoint of ALLOWED) {
    const outcome = validate({ endpoint, query: 'fields *;' });
    assertEquals(isRejection(outcome), false, `${endpoint} was refused`);
  }
});

Deno.test('a non-object body is refused', () => {
  for (const body of [null, 'games', 42, undefined]) {
    assertEquals(isRejection(validate(body)), true);
  }
});

Deno.test('a missing or empty query is refused', () => {
  assertEquals(isRejection(validate({ endpoint: 'games' })), true);
  assertEquals(isRejection(validate({ endpoint: 'games', query: '' })), true);
  assertEquals(isRejection(validate({ endpoint: 'games', query: 7 })), true);
});

Deno.test('the query length ceiling holds at the boundary', () => {
  const atLimit = 'f'.repeat(MAX_QUERY);
  assertEquals(
    isRejection(validate({ endpoint: 'games', query: atLimit })),
    false,
  );

  const over = validate({
    endpoint: 'games',
    query: 'f'.repeat(MAX_QUERY + 1),
  });
  assertEquals(isRejection(over), true);
  if (isRejection(over)) assertEquals(over.status, 413);
});

Deno.test('an accepted request carries the endpoint and query through', () => {
  const outcome = validate({ endpoint: 'games', query: 'fields name;' });
  assertEquals(isRejection(outcome), false);
  if (isRejection(outcome)) return;
  assertEquals(outcome.endpoint, 'games');
  assertEquals(outcome.query, 'fields name;');
});

Deno.test('a null auth.uid becomes 401, not 500', () => {
  // 28000 is what igdb_rate_limit_hit raises for the anon key. It has to read
  // as "sign in", otherwise the app shows a server error for what is a plain
  // authentication problem.
  const outcome = rateLimitOutcome('28000');
  assertEquals(outcome.status, 401);
});

Deno.test('the rate limit becomes 429 with a wait hint', () => {
  const outcome = rateLimitOutcome('54000');
  assertEquals(outcome.status, 429);
  assertEquals(outcome.message.includes('minute'), true);
});

Deno.test("any other database error stays ours, not the caller's", () => {
  for (const code of ['42501', 'XX000', undefined]) {
    assertEquals(rateLimitOutcome(code).status, 500);
  }
});

Deno.test('anon calls are refused unless the switch is explicitly on', () => {
  // The switch exists because every build up to 2.1.0+43 sends the anon key:
  // closing the path before those installations are gone turns the app into a
  // shell. Anything other than the literal "true" keeps it closed — an unset
  // variable, a typo, "1", "yes".
  assertEquals(anonStillAllowed('true'), true);
  for (const flag of [undefined, '', 'false', 'True', '1', 'yes']) {
    assertEquals(anonStillAllowed(flag), false, `${flag} opened the old path`);
  }
});

Deno.test('a token PostgREST will not accept reads as sign-in, not as our fault', () => {
  // Expired or malformed JWTs come back as PGRST301. Mapping them to 500 would
  // send a signed-out reader chasing a server problem that is not there.
  assertEquals(rateLimitOutcome('PGRST301').status, 401);
  assertEquals(rateLimitOutcome('PGRST302').status, 401);
});
