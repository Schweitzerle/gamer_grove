// core/services/toast_service.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toasty_box.dart';

/// Service for showing context-aware toasts throughout the app
class GamerGroveToastService {

  /// Show rating toast with circular progress indicator like on game card
  static void showRatingToast(
    BuildContext context, {
    required String gameName,
    required double rating,
  }) {
    final displayRating = (rating * 100).toInt(); // Convert 0-1 to 0-100 for display
    final color = ColorScales.getRatingColor(displayRating.toDouble());
    final ratingProgress = rating; // 0-1 range for progress indicator

    ToastService.showWidgetToast(
      context,
      isClosable: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shadowColor: color.withOpacity(0.4),
      length: ToastLength.medium,
      expandedHeight: 100,
      slideCurve: Curves.easeInOut,
      positionCurve: Curves.easeInOut,
      dismissDirection: DismissDirection.up,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Rating Circle (wie auf game_card)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.75),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  // Circular Progress
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: ratingProgress,
                      strokeWidth: 3,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  // Center Content
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.white,
                        ),
                        Text(
                          displayRating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rating Updated',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gameName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show recommended toast with green thumb up icon
  static void showRecommendedToast(
    BuildContext context, {
    required String gameName,
    required bool isRecommended,
  }) {
    ToastService.showWidgetToast(
      context,
      isClosable: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shadowColor: Colors.green.withOpacity(0.3),
      length: ToastLength.medium,
      expandedHeight: 100,
      slideCurve: Curves.easeInOut,
      positionCurve: Curves.easeInOut,
      dismissDirection: DismissDirection.up,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Recommend Circle (wie auf game_card)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRecommended
                    ? Colors.green.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                border: Border.all(
                  color: isRecommended
                      ? Colors.green.withOpacity(0.8)
                      : Colors.grey.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.thumb_up,
                size: 24,
                color: isRecommended ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isRecommended
                        ? 'Added to Recommendations'
                        : 'Removed from Recommendations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gameName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show wishlist toast with red heart icon
  static void showWishlistToast(
    BuildContext context, {
    required String gameName,
    required bool isWishlisted,
  }) {
    ToastService.showWidgetToast(
      context,
      isClosable: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shadowColor: Colors.red.withOpacity(0.3),
      length: ToastLength.medium,
      expandedHeight: 100,
      slideCurve: Curves.easeInOut,
      positionCurve: Curves.easeInOut,
      dismissDirection: DismissDirection.up,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Wishlist Circle (wie auf game_card)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isWishlisted
                    ? Colors.red.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                border: Border.all(
                  color: isWishlisted
                      ? Colors.red.withOpacity(0.8)
                      : Colors.grey.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.favorite,
                size: 24,
                color: isWishlisted ? Colors.red : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isWishlisted
                        ? 'Added to Wishlist'
                        : 'Removed from Wishlist',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gameName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show top three toast with trophy icon
  static void showTopThreeToast(
    BuildContext context, {
    required String gameName,
    required int position,
    required bool isAdded,
  }) {
    final color = ColorScales.getTopThreeColor(position);

    ToastService.showWidgetToast(
      context,
      isClosable: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shadowColor: color.withOpacity(0.3),
      length: ToastLength.medium,
      expandedHeight: 100,
      slideCurve: Curves.easeInOut,
      positionCurve: Curves.easeInOut,
      dismissDirection: DismissDirection.up,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Top Three Circle (wie auf game_card)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
                border: Border.all(
                  color: color.withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 20,
                    color: color,
                  ),
                  Text(
                    '#$position',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isAdded
                        ? 'Added to Top #$position'
                        : 'Removed from Top #$position',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gameName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show generic success toast
  static void showSuccess(
    BuildContext context, {
    required String title,
    String? message,
  }) {
    ToastService.showWidgetToast(
      context,
      isClosable: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shadowColor: Colors.green.withOpacity(0.3),
      length: ToastLength.medium,
      expandedHeight: message != null ? 100 : 80,
      slideCurve: Curves.easeInOut,
      positionCurve: Curves.easeInOut,
      dismissDirection: DismissDirection.up,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.2),
                border: Border.all(
                  color: Colors.green.withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check,
                size: 24,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show generic error toast
  static void showError(
    BuildContext context, {
    required String title,
    String? message,
  }) {
    ToastService.showWidgetToast(
      context,
      isClosable: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shadowColor: Colors.red.withOpacity(0.3),
      length: ToastLength.medium,
      expandedHeight: message != null ? 100 : 80,
      slideCurve: Curves.easeInOut,
      positionCurve: Curves.easeInOut,
      dismissDirection: DismissDirection.up,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.2),
                border: Border.all(
                  color: Colors.red.withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 24,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show generic info toast
  static void showInfo(
    BuildContext context, {
    required String title,
    String? message,
  }) {
    ToastService.showWidgetToast(
      context,
      isClosable: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shadowColor: Colors.blue.withOpacity(0.3),
      length: ToastLength.medium,
      expandedHeight: message != null ? 100 : 80,
      slideCurve: Curves.easeInOut,
      positionCurve: Curves.easeInOut,
      dismissDirection: DismissDirection.up,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.2),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.info_outline,
                size: 24,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show generic warning toast
  static void showWarning(
    BuildContext context, {
    required String title,
    String? message,
  }) {
    ToastService.showWidgetToast(
      context,
      isClosable: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shadowColor: Colors.orange.withOpacity(0.3),
      length: ToastLength.medium,
      expandedHeight: message != null ? 100 : 80,
      slideCurve: Curves.easeInOut,
      positionCurve: Curves.easeInOut,
      dismissDirection: DismissDirection.up,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.2),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 24,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
