class Language {
  int id;
  final String? checksum;
  final int? createdAt;
  final String? locale;
  final String? name;
  final String? nativeName;
  final int? updatedAt;

  Language({
    required this.id,
    this.checksum,
    this.createdAt,
    this.locale,
    this.name,
    this.nativeName,
    this.updatedAt,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      checksum: json['checksum'],
      createdAt: json['created_at'],
      locale: json['locale'],
      name: json['name'],
      nativeName: json['native_name'],
      updatedAt: json['updated_at'], id: json['id'],
    );
  }
}
