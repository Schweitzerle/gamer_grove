class CollectionType {
  int id;
  final String? checksum;
  final DateTime? createdAt;
  final String? description;
  final String? name;
  final DateTime? updatedAt;

  CollectionType({
    required this.id,
    this.checksum,
    this.createdAt,
    this.description,
    this.name,
    this.updatedAt,
  });

  factory CollectionType.fromJson(Map<String, dynamic> json) {
    return CollectionType(
      checksum: json['checksum'],
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000)
          : null,
      description: json['description'],
      name: json['name'],
      updatedAt: json['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] * 1000)
          : null, id: json['id'],
    );
  }
}
