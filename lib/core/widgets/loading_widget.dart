// core/widgets/loading_widget.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';

class CustomLoadingWidget extends StatelessWidget {

  const CustomLoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
  });
  final String? message;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              color: color ?? Theme.of(context).colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Specific loading widgets
class GameLoadingWidget extends StatelessWidget {
  const GameLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomLoadingWidget(
      message: 'Loading games...',
    );
  }
}

class AuthLoadingWidget extends StatelessWidget {
  const AuthLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomLoadingWidget(
      message: 'Authenticating...',
    );
  }
}

class ProfileLoadingWidget extends StatelessWidget {
  const ProfileLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomLoadingWidget(
      message: 'Loading profile...',
    );
  }
}

// Inline loading widget for buttons
class InlineLoadingWidget extends StatelessWidget {

  const InlineLoadingWidget({
    super.key,
    this.size = 16,
    this.color,
  });
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color ?? Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}

// Overlay loading widget
class OverlayLoadingWidget extends StatelessWidget {

  const OverlayLoadingWidget({
    required this.child, required this.isLoading, super.key,
    this.loadingMessage,
  });
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          ColoredBox(
            color: Colors.black.withOpacity(0.5),
            child: CustomLoadingWidget(
              message: loadingMessage,
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}

// Skeleton loading widget for lists
class SkeletonLoadingWidget extends StatelessWidget {

  const SkeletonLoadingWidget({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
  });
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.borderRadius / 2),
      ),
    );
  }
}

// Skeleton game card for lists
class SkeletonGameCard extends StatelessWidget {
  const SkeletonGameCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .colorScheme
                    .surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.borderRadius),
                ),
              ),
            ),
          ),
          // Content placeholder
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SkeletonLoadingWidget(height: 16),
                  const SizedBox(height: 4),
                  SkeletonLoadingWidget(
                    height: 12,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}