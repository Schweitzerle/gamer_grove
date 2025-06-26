// lib/presentation/widgets/loading_skeleton_widgets.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../custom_shimmer.dart';

class HorizontalGameListSkeleton extends StatelessWidget {
  const HorizontalGameListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
        ),
        itemCount: 3, // Show 3 skeleton items for top 3 games
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: EdgeInsets.only(
              right: index < 2 ? AppConstants.paddingMedium : 0,
            ),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image skeleton
                  CustomShimmer(
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingSmall),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title skeleton
                        CustomShimmer(
                          child: Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Subtitle skeleton
                        CustomShimmer(
                          child: Container(
                            height: 12,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}