// core/widgets/loading_widget.dart
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CustomLoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const CustomLoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
  final double size;
  final Color? color;

  const InlineLoadingWidget({
    super.key,
    this.size = 16,
    this.color,
  });

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
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;

  const OverlayLoadingWidget({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
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
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoadingWidget({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
  });

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
            flex: 1,
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