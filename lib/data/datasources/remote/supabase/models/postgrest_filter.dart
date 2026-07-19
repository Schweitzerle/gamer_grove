// core/../supabase/models/postgrest_filter.dart
//
// Helpers for building PostgREST filter expressions safely.
//
// PostgREST parses the string passed to `.or()` / `.filter()` as a filter
// tree, where characters such as `,` `(` `)` and `.` are structural. Any user
// input interpolated into such a string can therefore alter the filter logic
// (a PostgREST-level injection). Wrapping the value in double quotes makes
// PostgREST treat those reserved characters as literal data instead of syntax.

/// Escapes and double-quotes [value] for safe use inside a PostgREST filter
/// expression (e.g. the pattern in `column.ilike.<value>` within `.or(...)`).
///
/// PostgREST reserves `,` `(` `)` `.` as filter syntax. Double-quoting the
/// value neutralises them; inside a quoted value only `"` and `\` need
/// escaping. LIKE/ILIKE wildcards (`%`, `_`) are intentionally left untouched
/// so callers can still build substring patterns like `%term%`.
String escapePostgrestFilterValue(String value) {
  final escaped = value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
  return '"$escaped"';
}
