// lib/domain/entities/character_gender.dart
import 'package:equatable/equatable.dart';

class CharacterGender extends Equatable {

  const CharacterGender({
    required this.id,
    required this.checksum,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, checksum, name, createdAt, updatedAt];
}


// Character Gender Enum (DEPRECATED but still useful)
enum CharacterGenderEnum {
  male(0),
  female(1),
  other(2),
  unknown(-1);

  const CharacterGenderEnum(this.value);
  final int value;

  static CharacterGenderEnum fromValue(int value) {
    return values.firstWhere(
          (gender) => gender.value == value,
      orElse: () => unknown,
    );
  }

  String get displayName {
    switch (this) {
      case male: return 'Male';
      case female: return 'Female';
      case other: return 'Other';
      case unknown: return 'Unknown';
    }
  }
}