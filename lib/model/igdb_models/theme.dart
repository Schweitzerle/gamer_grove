class ThemeIDGB {
  int id;
  String? checksum;
  int? created_at;
  String? name;
  String? slug;
  int? updated_at;
  String? url;

  ThemeIDGB({
    required this.id,
    this.checksum,
    this.created_at,
    this.name,
    this.slug,
    this.updated_at,
    this.url,
  });

  factory ThemeIDGB.fromJson(Map<String, dynamic> json) {
    return ThemeIDGB(
      checksum: json['checksum'],
      created_at: json['created_at'],
      name: json['name'],
      slug: json['slug'],
      updated_at: json['updated_at'],
      url: json['url'], id: json['id'],
    );
  }
}
