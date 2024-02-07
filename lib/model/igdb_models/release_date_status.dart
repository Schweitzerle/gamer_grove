class ReleaseDateStatus {
  int id;
  String? checksum;
  int? createdAt;
  String? description;
  String? name;
  int? updatedAt;

  ReleaseDateStatus({
    required this.id,
    this.checksum,
    this.createdAt,
    this.description,
    this.name,
    this.updatedAt,
  });

  factory ReleaseDateStatus.fromJson(Map<String, dynamic> json) {
    return ReleaseDateStatus(
      checksum: json['checksum'],
      createdAt: json['created_at'],
      description: json['description'],
      name: json['name'],
      updatedAt: json['updated_at'], id: json['id'],
    );
  }
}
