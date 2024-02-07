class CompanyWebsite {
  int id;
  CategoryEnum? category;
  String? checksum;
  bool? trusted;
  String? url;

  CompanyWebsite({
    required this.id,
    this.category,
    this.checksum,
    this.trusted,
    this.url,
  });

  factory CompanyWebsite.fromJson(Map<String, dynamic> json) {
    return CompanyWebsite(
      category: CategoryEnumExtension.fromValue(json['category']),
      checksum: json['checksum'],
      trusted: json['trusted'],
      url: json['url'], id: json['id'],
    );
  }
}

enum CategoryEnum {
  official,
  wikia,
  wikipedia,
  facebook,
  twitter,
  twitch,
  instagram,
  youtube,
  iphone,
  ipad,
  android,
  steam,
  reddit,
  itch,
  epicgames,
  gog,
  discord,
}

extension CategoryEnumExtension on CategoryEnum {
  int get value {
    switch (this) {
      case CategoryEnum.official:
        return 1;
      case CategoryEnum.wikia:
        return 2;
      case CategoryEnum.wikipedia:
        return 3;
      case CategoryEnum.facebook:
        return 4;
      case CategoryEnum.twitter:
        return 5;
      case CategoryEnum.twitch:
        return 6;
      case CategoryEnum.instagram:
        return 8;
      case CategoryEnum.youtube:
        return 9;
      case CategoryEnum.iphone:
        return 10;
      case CategoryEnum.ipad:
        return 11;
      case CategoryEnum.android:
        return 12;
      case CategoryEnum.steam:
        return 13;
      case CategoryEnum.reddit:
        return 14;
      case CategoryEnum.itch:
        return 15;
      case CategoryEnum.epicgames:
        return 16;
      case CategoryEnum.gog:
        return 17;
      case CategoryEnum.discord:
        return 18;
    }
  }

  static CategoryEnum fromValue(int value) {
    switch (value) {
      case 1:
        return CategoryEnum.official;
      case 2:
        return CategoryEnum.wikia;
      case 3:
        return CategoryEnum.wikipedia;
      case 4:
        return CategoryEnum.facebook;
      case 5:
        return CategoryEnum.twitter;
      case 6:
        return CategoryEnum.twitch;
      case 8:
        return CategoryEnum.instagram;
      case 9:
        return CategoryEnum.youtube;
      case 10:
        return CategoryEnum.iphone;
      case 11:
        return CategoryEnum.ipad;
      case 12:
        return CategoryEnum.android;
      case 13:
        return CategoryEnum.steam;
      case 14:
        return CategoryEnum.reddit;
      case 15:
        return CategoryEnum.itch;
      case 16:
        return CategoryEnum.epicgames;
      case 17:
        return CategoryEnum.gog;
      case 18:
        return CategoryEnum.discord;
      default:
        throw ArgumentError('Unknown CategoryEnum value: $value');
    }
  }
}

