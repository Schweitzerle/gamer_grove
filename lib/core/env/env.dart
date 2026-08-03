import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env') // Hier wird auf deine lokale .env Datei verwiesen
abstract class Env {
  // The IGDB credentials used to live here. They do not any more: the app
  // talks to the `igdb` edge function, which holds them server-side. `envied`
  // masks a constant with XOR and ships the mask beside it, so this was never
  // more than a speed bump — the only way for a client not to leak a secret is
  // not to have one.

  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static final String supabaseAnonKey = _Env.supabaseAnonKey;

  // ===== Observability (optional; empty => feature disabled / no-op) =====
  // These are not secrets: a Sentry DSN and Umami site id are meant to be
  // embedded in clients. Kept unobfuscated with empty defaults so the app
  // runs fine when they are not configured (e.g. in CI).
  @EnviedField(varName: 'SENTRY_DSN', defaultValue: '')
  static const String sentryDsn = _Env.sentryDsn;

  @EnviedField(varName: 'UMAMI_URL', defaultValue: '')
  static const String umamiUrl = _Env.umamiUrl;

  @EnviedField(varName: 'UMAMI_WEBSITE_ID', defaultValue: '')
  static const String umamiWebsiteId = _Env.umamiWebsiteId;

  // ===== Billing (optional; empty => billing disabled / free tier) =====
  // RevenueCat's public SDK key is a client-embeddable key (not a secret),
  // like the Sentry DSN above. Empty default => no billing backend is
  // configured and the app runs on the free tier.
  @EnviedField(varName: 'REVENUECAT_API_KEY', defaultValue: '')
  static const String revenueCatApiKey = _Env.revenueCatApiKey;
}
