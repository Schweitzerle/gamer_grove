// presentation/widgets/game_list_shimmer.dart
import 'package:flutter/material.dart';
import 'game_card_shimmer.dart';

class GameListShimmer extends StatelessWidget {
  const GameListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const GameCardShimmer(),
    );
  }
}