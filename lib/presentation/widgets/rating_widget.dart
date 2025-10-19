// presentation/widgets/rating_widget.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class RatingWidget extends StatefulWidget {
  final double? initialRating;
  final void Function(double) onRatingChanged;
  final bool isReadOnly;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const RatingWidget({
    super.key,
    this.initialRating,
    required this.onRatingChanged,
    this.isReadOnly = false,
    this.size = 32.0,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = (index + 1) * 2.0; // 0-10 scale
        return GestureDetector(
          onTap: widget.isReadOnly
              ? null
              : () {
                  setState(() {
                    _currentRating = starValue;
                  });
                  widget.onRatingChanged(starValue);
                },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.size * 0.05),
            child: Icon(
              _currentRating >= starValue ? Icons.star : Icons.star_border,
              size: widget.size,
              color: _currentRating >= starValue
                  ? (widget.activeColor ?? Colors.amber)
                  : (widget.inactiveColor ?? Colors.grey),
            ),
          ),
        );
      }),
    );
  }
}

class GameRatingCard extends StatelessWidget {
  final double? igdbRating;
  final int? ratingCount;
  final double? userRating;
  final VoidCallback? onRatePressed;

  const GameRatingCard({
    super.key,
    this.igdbRating,
    this.ratingCount,
    this.userRating,
    this.onRatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            // IGDB Rating
            if (igdbRating != null) ...[
              Expanded(
                child: _buildRatingColumn(
                  context,
                  rating: igdbRating!,
                  title: 'IGDB Score',
                  subtitle: ratingCount != null
                      ? '${_formatCount(ratingCount!)} ratings'
                      : null,
                  color: _getIGDBRatingColor(igdbRating!),
                ),
              ),

              // Divider
              Container(
                height: 60,
                width: 1,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],

            // User Rating
            Expanded(
              child: userRating != null
                  ? _buildRatingColumn(
                      context,
                      rating: userRating!,
                      title: 'Your Rating',
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : _buildRateButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingColumn(
    BuildContext context, {
    required double rating,
    required String title,
    String? subtitle,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
      ],
    );
  }

  Widget _buildRateButton(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onRatePressed,
          icon: Icon(
            Icons.star_border,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          'Rate this game',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getIGDBRatingColor(double rating) {
    if (rating >= 80) return Colors.green;
    if (rating >= 70) return Colors.lightGreen;
    if (rating >= 60) return Colors.orange;
    if (rating >= 50) return Colors.deepOrange;
    return Colors.red;
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class RatingDialog extends StatefulWidget {
  final String gameTitle;
  final double? initialRating;
  final void Function(double rating) onRatingSubmitted;

  const RatingDialog({
    super.key,
    required this.gameTitle,
    this.initialRating,
    required this.onRatingSubmitted,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rate ${widget.gameTitle}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How would you rate this game?',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Rating Stars
          RatingWidget(
            initialRating: _rating,
            onRatingChanged: (rating) {
              setState(() {
                _rating = rating;
              });
            },
            size: 40,
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          // Rating Text
          Text(
            _rating > 0 ? '${_rating.toStringAsFixed(1)}/10' : 'No rating',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _rating > 0
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
          ),

          if (_rating > 0) ...[
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              _getRatingLabel(_rating),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _rating > 0
              ? () {
                  widget.onRatingSubmitted(_rating);
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  String _getRatingLabel(double rating) {
    if (rating >= 9.0) return 'Masterpiece';
    if (rating >= 8.0) return 'Excellent';
    if (rating >= 7.0) return 'Great';
    if (rating >= 6.0) return 'Good';
    if (rating >= 5.0) return 'Average';
    if (rating >= 4.0) return 'Below Average';
    if (rating >= 3.0) return 'Poor';
    if (rating >= 2.0) return 'Bad';
    return 'Terrible';
  }
}

// Compact rating display for cards
class CompactRatingWidget extends StatelessWidget {
  final double rating;
  final bool showLabel;
  final double size;

  const CompactRatingWidget({
    super.key,
    required this.rating,
    this.showLabel = true,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getRatingColor(rating);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: size,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: size * 0.8,
              ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            _getRatingLabel(rating),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: size * 0.7,
                ),
          ),
        ],
      ],
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 8.0) return Colors.green;
    if (rating >= 7.0) return Colors.lightGreen;
    if (rating >= 6.0) return Colors.orange;
    if (rating >= 5.0) return Colors.deepOrange;
    return Colors.red;
  }

  String _getRatingLabel(double rating) {
    if (rating >= 8.0) return 'Great';
    if (rating >= 7.0) return 'Good';
    if (rating >= 6.0) return 'Okay';
    if (rating >= 5.0) return 'Meh';
    return 'Poor';
  }
}
