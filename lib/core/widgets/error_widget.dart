// core/widgets/error_widget.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';

class CustomErrorWidget extends StatelessWidget {

  const CustomErrorWidget({
    required this.message, super.key,
    this.onRetry,
    this.icon,
    this.buttonText,
  });
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? buttonText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.paddingLarge),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(buttonText ?? 'Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Specific error widgets for common scenarios
class NetworkErrorWidget extends StatelessWidget {

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message: AppConstants.networkErrorMessage,
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
      buttonText: 'Check Connection',
    );
  }
}

class ServerErrorWidget extends StatelessWidget {

  const ServerErrorWidget({
    super.key,
    this.onRetry,
  });
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message: AppConstants.serverErrorMessage,
      icon: Icons.cloud_off_rounded,
      onRetry: onRetry,
    );
  }
}

class EmptyStateWidget extends StatelessWidget {

  const EmptyStateWidget({
    required this.title, required this.message, required this.icon, super.key,
    this.onAction,
    this.actionText,
  });
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: AppConstants.paddingLarge),
              FilledButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class AppErrorWidget extends StatelessWidget {

  const AppErrorWidget({
    required this.message, super.key,
    this.onRetry,
    this.icon,
  });
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.paddingLarge),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}