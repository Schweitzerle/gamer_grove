// ==================================================
// KEYWORDS SECTION
// ==================================================

// lib/presentation/pages/game_detail/widgets/sections/keywords_section.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/domain/entities/keyword.dart';

class KeywordsSection extends StatelessWidget {

  const KeywordsSection({
    required this.keywords, super.key,
  });
  final List<Keyword> keywords;

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
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
}
