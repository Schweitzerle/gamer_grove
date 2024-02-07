import 'package:gamer_grove/model/igdb_models/company_logo.dart';
import 'package:gamer_grove/model/igdb_models/company_website.dart';
import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/igdb_models/website.dart';

class Company {
  int id;
  final String? changeDate;
  final ChangeDateCategoryEnum? changeDateCategory;
  final Company? changedCompanyId;
  final String? checksum;
  final String? country;
  final int? createdAt;
  final String? description;
  final List<Game>? developed;
  final CompanyLogo? logo;
  final String? name;
  final Company? parent;
  final List<Game>? published;
  final String? slug;
  final String? startDate;
  final StartDateCategoryEnum? startDateCategory;
  final int? updatedAt;
  final String? url;
  final List<CompanyWebsite>? websites;

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
      changeDateCategory: ChangeDateCategoryEnumExtension.fromValue(
        json['change_date_category'],
      ),
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
        json['developed'].map((developed) {
          if (developed is int) {
            return Game(id: developed);
          } else {
            return Game.fromJson(developed);
          }
        }),
      )
          : null,
      logo: json['logo'],
      name: json['name'],
      parent: json['parent'] != null
          ? (json['parent'] is int
          ? Company(id: json['parent'])
          : Company.fromJson(json['parent']))
          : null,
      published: json['published'] != null
          ? List<Game>.from(
        json['published'].map((published) {
          if (published is int) {
            return Game(id: published);
          } else {
            return Game.fromJson(published);
          }
        }),
      )
          : null,
      slug: json['slug'],
      startDate: json['start_date'],
      startDateCategory: StartDateCategoryEnumExtension.fromValue(
        json['start_date_category'],
      ),
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
