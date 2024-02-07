class PlayerPerspective {
  int id;
  String? checksum;
  int? createdAt;
  String? name;
  String? slug;
  int? updatedAt;
  String? url;

  PlayerPerspective({
    required this.id,
    this.checksum,
    this.createdAt,
    this.name,
    this.slug,
    this.updatedAt,
    this.url,
  });

  factory PlayerPerspective.fromJson(Map<String, dynamic> json) {
    return PlayerPerspective(
      checksum: json['checksum'],
      createdAt: json['created_at'],
      name: json['name'],
      slug: json['slug'],
      updatedAt: json['updated_at'],
      url: json['url'], id: json['id'],
    );
  }
}
