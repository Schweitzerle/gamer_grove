class LanguageSupportType {
  int id;
  final String? checksum;
  final int? createdAt;
  final String? name;
  final int? updatedAt;

  LanguageSupportType({
    required this.id,
    this.checksum,
    this.createdAt,
    this.name,
    this.updatedAt,
  });

  factory LanguageSupportType.fromJson(Map<String, dynamic> json) {
    return LanguageSupportType(
      checksum: json['checksum'],
      createdAt: json['created_at'],
      name: json['name'],
      updatedAt: json['updated_at'], id: json['id'],
    );
  }
}
