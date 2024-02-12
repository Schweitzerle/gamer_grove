class CompanyLogo {
  int id;
  final bool? alphaChannel;
  final bool? animated;
  final String? checksum;
  final int? height;
  final String? imageId;
  final String? url;
  final int? width;

  CompanyLogo({
    required this.id,
    this.alphaChannel,
    this.animated,
    this.checksum,
    this.height,
    this.imageId,
    this.url,
    this.width,
  });

  factory CompanyLogo.fromJson(Map<String, dynamic> json) {
    String? logoURL = json["url"];
    if (logoURL != null) {
      logoURL = logoURL.replaceFirst("t_thumb", "t_720p");
    }
    return CompanyLogo(
      alphaChannel: json['alpha_channel'],
      animated: json['animated'],
      checksum: json['checksum'],
      height: json['height'],
      imageId: json['image_id'],
      url: 'https:$logoURL',
      width: json['width'], id: json['id'],
    );
  }
}
