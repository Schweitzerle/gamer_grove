// ===== UPDATED AGE RATING ORGANIZATION ENTITY =====
// lib/domain/entities/ageRating/age_rating_organization.dart
import 'package:equatable/equatable.dart';

class AgeRatingOrganization extends Equatable {

  const AgeRatingOrganization({
    required this.id,
    required this.checksum,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final DateTime? createdAt;
  final String name;
  final DateTime? updatedAt;

  // NEU: Helper getters für verschiedene Rating-Systeme
  bool get esrb => id == 1 || name.toLowerCase().contains('esrb');
  bool get pegi => id == 2 || name.toLowerCase().contains('pegi');
  bool get cero => id == 3 || name.toLowerCase().contains('cero');
  bool get usk => id == 4 || name.toLowerCase().contains('usk');
  bool get grac => id == 5 || name.toLowerCase().contains('grac');
  bool get classInd => id == 6 || name.toLowerCase().contains('class');
  bool get acb => id == 7 || name.toLowerCase().contains('acb');

  // Alternative naming conventions
  bool get isESRB => esrb;
  bool get isPEGI => pegi;
  bool get isCERO => cero;
  bool get isUSK => usk;
  bool get isGRAC => grac;
  bool get isClassInd => classInd;
  bool get isACB => acb;

  // Helper für Display
  String get displayName {
    switch (id) {
      case 1: return 'ESRB';
      case 2: return 'PEGI';
      case 3: return 'CERO';
      case 4: return 'USK';
      case 5: return 'GRAC';
      case 6: return 'ClassInd';
      case 7: return 'ACB';
      default: return name;
    }
  }

  @override
  List<Object?> get props => [id, checksum, name, createdAt, updatedAt];
}