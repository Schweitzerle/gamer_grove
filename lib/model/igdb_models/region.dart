class Region {
  int id;
  String? category;
  String? checksum;
  int? createdAt;
  String? identifier;
  String? name;
  int? updatedAt;

  Region({
    required this.id,
    this.category,
    this.checksum,
    this.createdAt,
    this.identifier,
    this.name,
    this.updatedAt,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      category: json['category'],
      checksum: json['checksum'],
      createdAt: json['created_at'],
      identifier: json['identifier'],
      name: json['name'],
      updatedAt: json['updated_at'], id: json['id'],
    );
  }
}
