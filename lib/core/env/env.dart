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
}
