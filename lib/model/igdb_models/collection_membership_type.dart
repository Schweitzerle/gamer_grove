class CollectionMembershipType {
  int id;
  final int? allowedCollectionType;
  final String? checksum;
  final DateTime? createdAt;
  final String? description;
  final String? name;
  final DateTime? updatedAt;

  CollectionMembershipType({
    required this.id,
    this.allowedCollectionType,
    this.checksum,
    this.createdAt,
    this.description,
    this.name,
    this.updatedAt,
  });

  factory CollectionMembershipType.fromJson(Map<String, dynamic> json) {
    return CollectionMembershipType(
      allowedCollectionType: json['allowed_collection_type'],
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
