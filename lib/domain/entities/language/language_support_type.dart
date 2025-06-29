// lib/domain/entities/language_support_type.dart
import 'package:equatable/equatable.dart';

class LanguageSupportType extends Equatable {
  final int id;
  final String checksum;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LanguageSupportType({
    required this.id,
    required this.checksum,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  // Helper to determine support level
  bool get isAudio => name.toLowerCase().contains('audio');
  bool get isSubtitles => name.toLowerCase().contains('subtitle');
  bool get isInterface => name.toLowerCase().contains('interface');
  bool get isFullAudio => name.toLowerCase().contains('full audio');

  // Get icon for support type
  String get iconName {
    if (isAudio) return 'volume_up';
    if (isSubtitles) return 'subtitles';
    if (isInterface) return 'language';
    return 'translate';
  }

  @override
  List<Object?> get props => [
    id,
    checksum,
    name,
    createdAt,
    updatedAt,
  ];
}

// Common language support types
class LanguageSupportTypes {
  static const int audio = 1;
  static const int subtitles = 2;
  static const int interface = 3;
  static const int fullAudio = 4;

  static const Map<int, String> typeNames = {
    audio: 'Audio',
    subtitles: 'Subtitles',
    interface: 'Interface',
    fullAudio: 'Full Audio',
  };

  static String getTypeName(int typeId) {
    return typeNames[typeId] ?? 'Unknown';
  }
}