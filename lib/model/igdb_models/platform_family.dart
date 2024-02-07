class PlatformFamily {
  int id;
  final String? checksum;
  final String? name;
  final String? slug;

  PlatformFamily({
    required this.id,
    this.checksum,
    this.name,
    this.slug,
  });

  factory PlatformFamily.fromJson(Map<String, dynamic> json) {
    return PlatformFamily(
      checksum: json['checksum'],
      name: json['name'],
      slug: json['slug'], id: json['id'],
    );
  }
}
