// ==================================================
// KEYWORDS SECTION
// ==================================================

// lib/presentation/pages/game_detail/widgets/sections/keywords_section.dart
import 'package:flutter/material.dart';
import '../../../../../domain/entities/keyword.dart';

class KeywordsSection extends StatelessWidget {
  final List<Keyword> keywords;

  const KeywordsSection({
    super.key,
    required this.keywords,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: keywords.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Chip(
              label: Text(
                keywords[index].name,
                style: const TextStyle(fontSize: 11),
              ),
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
}