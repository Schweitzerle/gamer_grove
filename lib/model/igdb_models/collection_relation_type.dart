class CollectionRelationType {
  int id;
  final String? allowedChildType;
  final String? allowedParentType;
  final String? checksum;
  final DateTime? createdAt;
  final String? description;
  final String? name;
  final DateTime? updatedAt;

  CollectionRelationType({
    required this.id,
    this.allowedChildType,
    this.allowedParentType,
    this.checksum,
    this.createdAt,
    this.description,
    this.name,
    this.updatedAt,
  });

  factory CollectionRelationType.fromJson(Map<String, dynamic> json) {
    return CollectionRelationType(
      allowedChildType: json['allowed_child_type'],
      allowedParentType: json['allowed_parent_type'],
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
