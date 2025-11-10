// lib/presentation/widgets/rating_dialog.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class RatingDialog extends StatefulWidget {
  final String gameName;
  final double? currentRating;
  final void Function(double rating) onRatingChanged;
  final VoidCallback? onRatingDeleted;

  const RatingDialog({
    super.key,
    required this.gameName,
    required this.onRatingChanged,
    this.onRatingDeleted,
    this.currentRating,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog>
    with TickerProviderStateMixin {
  late double _currentRating;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.currentRating ?? 5.0;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getRatingColor(double rating) {
    if (rating >= 8.0) return Colors.green;
    if (rating >= 6.0) return Colors.lightGreen;
    if (rating >= 4.0) return Colors.orange;
    if (rating >= 2.0) return Colors.deepOrange;
    return Colors.red;
  }

  String _getRatingText(double rating) {
    if (rating >= 9.0) return 'Masterpiece';
    if (rating >= 8.0) return 'Excellent';
    if (rating >= 7.0) return 'Great';
    if (rating >= 6.0) return 'Good';
    if (rating >= 5.0) return 'Average';
    if (rating >= 4.0) return 'Below Average';
    if (rating >= 3.0) return 'Poor';
    if (rating >= 2.0) return 'Bad';
    if (rating >= 1.0) return 'Awful';
    return 'Unplayable';
  }

  List<Widget> _buildStars() {
    List<Widget> stars = [];

    for (int i = 1; i <= 10; i++) {
      double starValue = i.toDouble();
      bool isSelected = starValue <= _currentRating;
      bool isHalfSelected =
          (starValue - 0.5) <= _currentRating && starValue > _currentRating;

      stars.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = starValue;
            });

            // Haptic feedback
            // HapticFeedback.selectionClick();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(4),
            child: Icon(
              isSelected || isHalfSelected ? Icons.star : Icons.star_outline,
              color: isSelected || isHalfSelected
                  ? _getRatingColor(_currentRating)
                  : Colors.grey[400],
              size: 28,
            ),
          ),
        ),
      );
    }

    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        title: Column(
          children: [
            Icon(
              Icons.star_rounded,
              size: 32,
              color: _getRatingColor(_currentRating),
            ),
            const SizedBox(height: 8),
            Text(
              'Rate Game',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Game Name
            Text(
              widget.gameName,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 24),

            // Star Rating
            Wrap(
              alignment: WrapAlignment.center,
              children: _buildStars(),
            ),

            const SizedBox(height: 16),

            // Rating Value & Text
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _getRatingColor(_currentRating).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getRatingColor(_currentRating).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _currentRating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getRatingColor(_currentRating),
                        ),
                  ),
                  Text(
                    _getRatingText(_currentRating),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getRatingColor(_currentRating),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Slider for precise control
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _getRatingColor(_currentRating),
                thumbColor: _getRatingColor(_currentRating),
                overlayColor: _getRatingColor(_currentRating).withOpacity(0.2),
                valueIndicatorColor: _getRatingColor(_currentRating),
                valueIndicatorTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Slider(
                value: _currentRating,
                min: 0.5,
                max: 10.0,
                divisions: 19, // 0.5 to 10 in 0.5 increments
                label: _currentRating.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _currentRating = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 8),

            // Helper text
            Text(
              'Tap stars or use slider to rate',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          if (widget.currentRating != null && widget.onRatingDeleted != null)
            TextButton(
              onPressed: () {
                widget.onRatingDeleted!();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              widget.onRatingChanged(_currentRating);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.check),
            label: Text(
              widget.currentRating != null ? 'Update' : 'Rate',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _getRatingColor(_currentRating),
            ),
          ),
        ],
      ),
    );
  }
}
