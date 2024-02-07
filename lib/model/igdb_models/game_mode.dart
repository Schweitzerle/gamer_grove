class GameMode {
  int id;
  final String? checksum;
  final int? createdAt;
  final String? name;
  final String? slug;
  final int? updatedAt;
  final String? url;

  GameMode({
    required this.id,
    this.checksum,
    this.createdAt,
    this.name,
    this.slug,
    this.updatedAt,
    this.url,
  });

  factory GameMode.fromJson(Map<String, dynamic> json) {
    return GameMode(
      checksum: json['checksum'],
      createdAt: json['created_at'],
      name: json['name'],
      slug: json['slug'],
      updatedAt: json['updated_at'],
      url: json['url'], id: json['id'],
    );
  }
}
