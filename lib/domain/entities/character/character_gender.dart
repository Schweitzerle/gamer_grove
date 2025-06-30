// lib/domain/entities/character_gender.dart
import 'package:equatable/equatable.dart';

class CharacterGender extends Equatable {
  final int id;
  final String checksum;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CharacterGender({
    required this.id,
    required this.checksum,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, checksum, name, createdAt, updatedAt];
}

// ==========================================

// lib/domain/entities/character/character_gender.dart
enum CharacterGender {
  male(0, 'Male'),
  female(1, 'Female'),
  other(2, 'Other');

  const CharacterGender(this.value, this.displayName);
  final int value;
  final String displayName;

  static CharacterGender fromValue(int value) {
    return values.firstWhere(
          (gender) => gender.value == value,
      orElse: () => other,
    );
  }
}