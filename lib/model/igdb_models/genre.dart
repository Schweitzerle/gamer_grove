class Genre {
  int id;
  final String? checksum;
  final int? createdAt;
  final String? name;
  final String? slug;
  final int? updatedAt;
  final String? url;

  Genre({
    required this.id,
    this.checksum,
    this.createdAt,
    this.name,
    this.slug,
    this.updatedAt,
    this.url,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      checksum: json['checksum'],
      createdAt: json['created_at'],
      name: json['name'],
      slug: json['slug'],
      updatedAt: json['updated_at'],
      url: json['url'], id: json['id'],
    );
  }
}
