import 'package:gamer_grove/model/igdb_models/game_version_feature_value.dart';

class GameVersionFeature {
  int id;
  CategoryEnum? category;
  String? checksum;
  String? description;
  int? position;
  String? title;
  List<GameVersionFeatureValue>? values;

  GameVersionFeature({
    required this.id,
    this.category,
    this.checksum,
    this.description,
    this.position,
    this.title,
    this.values,
  });

  factory GameVersionFeature.fromJson(Map<String, dynamic> json) {
    return GameVersionFeature(
      id: json['id'],
      category: CategoryEnumExtension.fromValue(json['category']),
      checksum: json['checksum'],
      description: json['description'],
      position: json['position'],
      title: json['title'],
      values: json['values'] != null
          ? List<GameVersionFeatureValue>.from(
        json['values'].map((values) {
          if (values is int) {
            return GameVersionFeatureValue(id: values);
          } else {
            return GameVersionFeatureValue.fromJson(values);
          }
        }),
      )
          : null,
    );
  }
}

enum CategoryEnum {
  boolean,
  description
}

extension CategoryEnumExtension on CategoryEnum {
  int get value {
    return this.index;
  }

  static CategoryEnum fromValue(int value) {
    return CategoryEnum.values[value];
  }
}
