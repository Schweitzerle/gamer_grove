import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Which build of the app this actually is.
///
/// Read from the installed package rather than from a constant in the source.
/// A constant is the reason this line said "v2.0.0" for three releases: it is
/// one more thing to remember, and nobody remembers it. The platform already
/// knows, and what it knows is the truth about what is on the device — which is
/// the only reason to show a build number at all.
class AppVersionLine extends StatefulWidget {
  const AppVersionLine({super.key});

  @override
  State<AppVersionLine> createState() => _AppVersionLineState();
}

class _AppVersionLineState extends State<AppVersionLine> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _info = info);
    } on Exception {
      // A version line that cannot be read is not worth a broken sheet; the
      // placeholder below simply stays.
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    final text = info == null
        ? 'GamerGrove'
        : 'GamerGrove v${info.version} (Build ${info.buildNumber})';

    return Semantics(
      // Testers read this out to say which build they are on, so it has to be
      // announced as one piece rather than parsed from the layout.
      label: 'App version: $text',
      child: ExcludeSemantics(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
