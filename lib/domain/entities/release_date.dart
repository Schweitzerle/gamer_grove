// ===== RELEASE DATE ENTITY =====
// lib/domain/entities/release_date.dart
import 'package:equatable/equatable.dart';
import 'platform/platform.dart';

enum ReleaseRegion {
  europe,
  northAmerica,
  australia,
  newZealand,
  japan,
  china,
  asia,
  worldwide,
  korea,
  brazil,
  unknown,
}

class ReleaseDate extends Equatable {
  final int id;
  final DateTime? date;
  final Platform? platform;
  final ReleaseRegion region;
  final String? human; // Human readable date

  const ReleaseDate({
    required this.id,
    this.date,
    this.platform,
    this.region = ReleaseRegion.unknown,
    this.human,
  });

  @override
  List<Object?> get props => [id, date, platform, region, human];
}







