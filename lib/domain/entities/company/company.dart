// ===== COMPANY ENTITY (UPDATED WITH LOGO URL) =====
// lib/domain/entities/company/company.dart
import 'package:equatable/equatable.dart';
import 'company_logo.dart'; // Import für CompanyLogo

enum CompanyChangeDateCategory {
  yyyymmdd(0),
  yyyymm(1),
  yyyy(2),
  yyyyq1(3),
  yyyyq2(4),
  yyyyq3(5),
  yyyyq4(6),
  tbd(7),
  unknown(-1);

  const CompanyChangeDateCategory(this.value);
  final int value;

  static CompanyChangeDateCategory fromValue(int value) {
    return values.firstWhere(
          (category) => category.value == value,
      orElse: () => unknown,
    );
  }
}

class Company extends Equatable {
  final int id;
  final String checksum;
  final String name;
  final String? description;
  final String? slug;
  final String? url;
  final int? country; // ISO 3166-1 country code
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Company hierarchy & changes
  final DateTime? changeDate;
  final CompanyChangeDateCategory? changeDateCategory; // DEPRECATED
  final int? changeDateFormatId;
  final int? changedCompanyId;
  final int? parentId;

  // Company data
  final int? logoId;
  final CompanyLogo? logo; // NEU: Direktes Logo Objekt
  final int? statusId;
  final DateTime? startDate;
  final CompanyChangeDateCategory? startDateCategory; // DEPRECATED
  final int? startDateFormatId;

  // Associated data
  final List<int> developedGameIds;
  final List<int> publishedGameIds;
  final List<int> websiteIds;

  const Company({
    required this.id,
    required this.checksum,
    required this.name,
    this.description,
    this.slug,
    this.url,
    this.country,
    this.createdAt,
    this.updatedAt,
    this.changeDate,
    this.changeDateCategory,
    this.changeDateFormatId,
    this.changedCompanyId,
    this.parentId,
    this.logoId,
    this.logo, // NEU
    this.statusId,
    this.startDate,
    this.startDateCategory,
    this.startDateFormatId,
    this.developedGameIds = const [],
    this.publishedGameIds = const [],
    this.websiteIds = const [],
  });

  // Helper getters
  bool get hasLogo => logo != null || logoId != null;
  bool get hasParent => parentId != null;
  bool get hasStatus => statusId != null;
  bool get hasWebsites => websiteIds.isNotEmpty;
  bool get hasDevelopedGames => developedGameIds.isNotEmpty;
  bool get hasPublishedGames => publishedGameIds.isNotEmpty;
  bool get hasFoundingDate => startDate != null;
  bool get hasDescription => description != null && description!.isNotEmpty;

  int get totalGamesCount => developedGameIds.length + publishedGameIds.length;
  bool get isDeveloper => developedGameIds.isNotEmpty;
  bool get isPublisher => publishedGameIds.isNotEmpty;
  bool get isDeveloperAndPublisher => isDeveloper && isPublisher;

  // NEU: Logo URL getters
  String? get logoUrl => logo?.logoMedUrl;
  String? get logoThumbUrl => logo?.thumbUrl;
  String? get logoMedUrl => logo?.logoMedUrl;
  String? get logoMed2xUrl => logo?.logoMed2xUrl;
  String? get logoMicroUrl => logo?.microUrl;

  @override
  List<Object?> get props => [
    id,
    checksum,
    name,
    description,
    slug,
    url,
    country,
    createdAt,
    updatedAt,
    changeDate,
    changeDateCategory,
    changeDateFormatId,
    changedCompanyId,
    parentId,
    logoId,
    logo, // NEU
    statusId,
    startDate,
    startDateCategory,
    startDateFormatId,
    developedGameIds,
    publishedGameIds,
    websiteIds,
  ];
}