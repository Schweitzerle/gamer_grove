// domain/entities/rating.dart
import 'package:equatable/equatable.dart';

class Rating extends Equatable {
  final String id;
  final String userId;
  final int gameId;
  final double value;
  final String? review;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Rating({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.value,
    this.review,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    gameId,
    value,
    review,
    createdAt,
    updatedAt,
  ];

  Rating copyWith({
    String? id,
    String? userId,
    int? gameId,
    double? value,
    String? review,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Rating(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gameId: gameId ?? this.gameId,
      value: value ?? this.value,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  bool get hasReview => review != null && review!.isNotEmpty;
  bool get isPositive => value >= 7.0;
  bool get isNegative => value <= 4.0;
  bool get isNeutral => value > 4.0 && value < 7.0;

  String get displayRating => '${value.toStringAsFixed(1)}/10';

  String get ratingCategory {
    if (value >= 9.0) return 'Excellent';
    if (value >= 8.0) return 'Great';
    if (value >= 7.0) return 'Good';
    if (value >= 6.0) return 'Okay';
    if (value >= 4.0) return 'Poor';
    return 'Terrible';
  }
}