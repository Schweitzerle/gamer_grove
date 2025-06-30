// ==========================================

// lib/domain/entities/recommendations/season.dart
enum Season {
  spring('spring', 'Spring', 'Fresh starts, growth, renewal'),
  summer('summer', 'Summer', 'Adventure, outdoor themes, high energy'),
  autumn('autumn', 'Autumn', 'Cozy, atmospheric, story-focused'),
  winter('winter', 'Winter', 'Warm, indoor, long-session games');

  const Season(this.value, this.displayName, this.description);
  final String value;
  final String displayName;
  final String description;

  static Season getCurrentSeason() {
    final month = DateTime.now().month;
    switch (month) {
      case 3:
      case 4:
      case 5:
        return spring;
      case 6:
      case 7:
      case 8:
        return summer;
      case 9:
      case 10:
      case 11:
        return autumn;
      default:
        return winter;
    }
  }
}

