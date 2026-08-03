import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gamer_grove/presentation/widgets/loading/portal_loader.dart';

/// The legal texts shipped with the app.
///
/// Kept as markdown assets so the same source can feed the website later; the
/// German privacy policy is the legally binding one.
enum LegalDocument {
  privacyPolicy('Privacy Policy', 'assets/legal/privacy-policy.md'),
  datenschutz('Datenschutzerklärung', 'assets/legal/datenschutz.md'),
  impressum('Impressum', 'assets/legal/impressum.md'),
  agb('AGB', 'assets/legal/agb.md');

  const LegalDocument(this.title, this.assetPath);

  final String title;
  final String assetPath;
}

/// Renders a bundled legal document.
///
/// Reading these must work offline and without an account, so the text ships
/// with the app rather than being fetched.
class LegalDocumentPage extends StatefulWidget {
  const LegalDocumentPage({required this.document, super.key});

  final LegalDocument document;

  static Route<void> route(LegalDocument document) {
    return MaterialPageRoute<void>(
      builder: (_) => LegalDocumentPage(document: document),
    );
  }

  @override
  State<LegalDocumentPage> createState() => _LegalDocumentPageState();
}

class _LegalDocumentPageState extends State<LegalDocumentPage> {
  late Future<String> _content;

  @override
  void initState() {
    super.initState();
    _content = rootBundle.loadString(widget.document.assetPath);
  }

  @override
  void didUpdateWidget(LegalDocumentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Flutter reuses this State when the page is rebuilt in place, so the
    // content has to follow the document rather than stay at the first one.
    if (oldWidget.document != widget.document) {
      _content = rootBundle.loadString(widget.document.assetPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.document.title)),
      body: FutureBuilder<String>(
        future: _content,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load this document.'));
          }
          final text = snapshot.data;
          if (text == null) {
            return const Center(child: PortalLoader());
          }
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: _renderMarkdown(context, text),
            ),
          );
        },
      ),
    );
  }
}

/// Minimal renderer for the subset of markdown these documents use: `#`/`##`
/// headings, `-` bullets and blank-line separated paragraphs.
///
/// A dedicated package would be overkill for three static documents — and the
/// documents are written without inline formatting so nothing needs escaping.
List<Widget> _renderMarkdown(BuildContext context, String source) {
  final theme = Theme.of(context);
  final widgets = <Widget>[];
  final paragraph = <String>[];

  void flushParagraph() {
    if (paragraph.isEmpty) return;
    widgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          paragraph.join(' '),
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ),
    );
    paragraph.clear();
  }

  for (final raw in source.split('\n')) {
    final line = raw.trimRight();

    if (line.trim().isEmpty) {
      flushParagraph();
      continue;
    }

    if (line.startsWith('### ')) {
      flushParagraph();
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            line.substring(4),
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      );
    } else if (line.startsWith('## ')) {
      flushParagraph();
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            line.substring(3),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else if (line.startsWith('# ')) {
      flushParagraph();
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            line.substring(2),
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else if (line.startsWith('- ')) {
      flushParagraph();
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•  ', style: theme.textTheme.bodyMedium),
              Expanded(
                child: Text(
                  line.substring(2),
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      paragraph.add(line.trim());
    }
  }

  flushParagraph();
  return widgets;
}
