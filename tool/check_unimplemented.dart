import 'dart:io';

void main() {
  print('🔍 Checking for UnimplementedError in lib/...\n');

  final libDir = Directory('lib');
  final issues = <Map<String, dynamic>>[];

  // Durchsuche alle Dart-Dateien
  libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .forEach((file) {
    final content = file.readAsStringSync();
    final lines = content.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('UnimplementedError') ||
          line.contains('throw UnimplementedError')) {
        // Extrahiere Methodennamen wenn möglich
        String? methodName;
        for (var j = i - 1; j >= 0 && j >= i - 10; j--) {
          if (lines[j].contains('Future<') ||
              lines[j].contains('void ') ||
              lines[j].contains('async')) {
            final match = RegExp(r'(\w+)\s*\(').firstMatch(lines[j]);
            if (match != null) {
              methodName = match.group(1);
              break;
            }
          }
        }

        issues.add({
          'file': file.path,
          'line': i + 1,
          'method': methodName ?? 'unknown',
          'code': line.trim(),
        });
      }
    }
  });

  if (issues.isEmpty) {
    print('✅ No UnimplementedError found!');
    exit(0);
  } else {
    print('❌ Found ${issues.length} UnimplementedError(s):\n');

    // Gruppiere nach Datei
    final groupedByFile = <String, List<Map<String, dynamic>>>{};
    for (final issue in issues) {
      final file = issue['file'] as String;
      groupedByFile.putIfAbsent(file, () => []).add(issue);
    }

    // Ausgabe
    groupedByFile.forEach((file, fileIssues) {
      print('📁 $file');
      for (final issue in fileIssues) {
        print('   Line ${issue['line']}: ${issue['method']}()');
      }
      print('');
    });

    print(
        '\n💡 Empfehlung: Diese Methoden sollten entweder implementiert oder gelöscht werden.\n',);
    exit(1);
  }
}
