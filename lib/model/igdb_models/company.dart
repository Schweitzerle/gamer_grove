import 'package:gamer_grove/model/igdb_models/company_logo.dart';
import 'package:gamer_grove/model/igdb_models/company_website.dart';
import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/igdb_models/website.dart';

import '../../repository/igdb/IGDBApiService.dart';
import '../firebase/firebaseUser.dart';
import '../firebase/gameModel.dart';

class Company {
  int id;
  final int? changeDate;
  final ChangeDateCategoryEnum? changeDateCategory;
  final Company? changedCompanyId;
  final String? checksum;
  final int? country;
  final int? createdAt;
  final String? description;
  final List<Game>? developed;
  final CompanyLogo? logo;
  final String? name;
  final Company? parent;
  final List<Game>? published;
  final String? slug;
  final int? startDate;
  final StartDateCategoryEnum? startDateCategory;
  final int? updatedAt;
  final String? url;
  List<CompanyWebsite>? websites;

  Company({
    this.checksum,
    required this.id,
    this.changeDate,
    this.changeDateCategory,
    this.changedCompanyId,
    this.country,
    this.createdAt,
    this.description,
    this.developed,
    this.logo,
    this.name,
    this.parent,
    this.published,
    this.slug,
    this.startDate,
    this.startDateCategory,
    this.updatedAt,
    this.url,
    this.websites,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      changeDate: json['change_date'],
      changeDateCategory: json['change_date_category'] != null ? ChangeDateCategoryEnumExtension.fromValue(
        json['change_date_category']) : null,
      changedCompanyId: json['changed_company_id'] != null
          ? (json['changed_company_id'] is int
          ? Company(id: json['changed_company_id'])
          : Company.fromJson(json['changed_company_id']))
          : null,
      checksum: json['checksum'],
      country: json['country'],
      createdAt: json['created_at'],
      description: json['description'],
      developed: json['developed'] != null
          ? List<Game>.from(
        json['developed'].map((dlc) {
          if (dlc is int) {
            return Game(id: dlc, gameModel: GameModel(id: '0', wishlist: false, recommended: false, rating: 0));
          } else {
            return Game.fromJson(dlc, IGDBApiService.getGameModel(dlc['id']));
          }
        }),
      )
          : null,
      logo: json['logo'] != null
          ? (json['logo'] is int
          ? CompanyLogo(id: json['logo'])
          : CompanyLogo.fromJson(json['logo']))
          : null,
      name: json['name'],
      parent: json['parent'] != null
          ? (json['parent'] is int
          ? Company(id: json['parent'])
          : Company.fromJson(json['parent']))
          : null,
      published: json['published'] != null
          ? List<Game>.from(
        json['published'].map((dlc) {
          if (dlc is int) {
            return Game(id: dlc, gameModel: GameModel(id: '0', wishlist: false, recommended: false, rating: 0));
          } else {
            return Game.fromJson(dlc, IGDBApiService.getGameModel(dlc['id']));
          }
        }),
      )
          : null,
      slug: json['slug'],
      startDate: json['start_date'],
      startDateCategory: json['start_date_category'] != null ? StartDateCategoryEnumExtension.fromValue(
        json['start_date_category'],
      ) : null,
      updatedAt: json['updated_at'],
      url: json['url'],
      websites: json['websites'] != null
          ? List<CompanyWebsite>.from(
        json['websites'].map((companyWebsite) {
          if (companyWebsite is int) {
            return CompanyWebsite(id: companyWebsite);
          } else {
            return CompanyWebsite.fromJson(companyWebsite);
          }
        }),
      )
          : null,
      id: json['id'],
    );
  }
}

enum ChangeDateCategoryEnum {
  YYYYMMMMDD,
  YYYYMMMM,
  YYYY,
  YYYYQ1,
  YYYYQ2,
  YYYYQ3,
  YYYYQ4,
  TBD,
}

enum StartDateCategoryEnum {
  YYYYMMMMDD,
  YYYYMMMM,
  YYYY,
  YYYYQ1,
  YYYYQ2,
  YYYYQ3,
  YYYYQ4,
  TBD,
}

extension ChangeDateCategoryEnumExtension on ChangeDateCategoryEnum {
  int get value {
    return this.index;
  }

  static ChangeDateCategoryEnum fromValue(int value) {
    return ChangeDateCategoryEnum.values[value];
  }
}

extension StartDateCategoryEnumExtension on StartDateCategoryEnum {
  int get value {
    return this.index;
  }

  static StartDateCategoryEnum fromValue(int value) {
    return StartDateCategoryEnum.values[value];
  }
}
