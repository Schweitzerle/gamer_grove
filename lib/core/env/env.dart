import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env') // Hier wird auf deine lokale .env Datei verwiesen
abstract class Env {
  @EnviedField(varName: 'IGDB_CLIENT_ID', obfuscate: true)
  static final String igdbClientId = _Env.igdbClientId;

  @EnviedField(varName: 'IGDB_CLIENT_SECRET', obfuscate: true)
  static final String igdbClientSecret = _Env.igdbClientSecret;

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
}
