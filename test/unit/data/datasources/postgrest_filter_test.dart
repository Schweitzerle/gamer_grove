import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/data/datasources/remote/supabase/models/postgrest_filter.dart';

void main() {
  group('escapePostgrestFilterValue', () {
    test('wraps a plain value in double quotes', () {
      expect(escapePostgrestFilterValue('john'), '"john"');
    });

    test('preserves ilike wildcards so substring patterns still work', () {
      expect(escapePostgrestFilterValue('%john%'), '"%john%"');
    });

    test('neutralises commas that would start a new PostgREST filter', () {
      // Without quoting, this comma would break out of the ilike value and
      // inject an additional filter into the .or() tree.
      const malicious = '%john,is_admin.eq.true%';
      expect(escapePostgrestFilterValue(malicious), '"$malicious"');
    });

    test('neutralises parentheses used for filter grouping', () {
      expect(
        escapePostgrestFilterValue('%a)or(b%'),
        '"%a)or(b%"',
      );
    });

    test('escapes embedded double quotes', () {
      expect(escapePostgrestFilterValue('a"b'), r'"a\"b"');
    });

    test('escapes backslashes', () {
      expect(escapePostgrestFilterValue(r'a\b'), r'"a\\b"');
    });

    test('escapes backslash before double quote in the right order', () {
      // A trailing backslash must be doubled before the closing quote is added,
      // otherwise it would escape the structural closing quote.
      expect(escapePostgrestFilterValue(r'a\'), r'"a\\"');
    });

    test('handles empty input', () {
      expect(escapePostgrestFilterValue(''), '""');
    });
  });
}
