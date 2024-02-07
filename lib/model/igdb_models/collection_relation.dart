class CollectionRelation {
  int id;
  final String? checksum;
  final DateTime? createdAt;
  final int? childCollection;
  final int? parentCollection;
  final int? type;
  final DateTime? updatedAt;

  CollectionRelation({
    required this.id,
    this.checksum,
    this.createdAt,
    this.childCollection,
    this.parentCollection,
    this.type,
    this.updatedAt,
  });

  factory CollectionRelation.fromJson(Map<String, dynamic> json) {
    return CollectionRelation(
      checksum: json['checksum'],
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000)
          : null,
      childCollection: json['child_collection'],
      parentCollection: json['parent_collection'],
      type: json['type'],
      updatedAt: json['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] * 1000)
          : null, id: json['id'],
    );
  }
}
