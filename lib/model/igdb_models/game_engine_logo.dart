class GameEngineLogo {
  int id;
  final bool? alphaChannel;
  final bool? animated;
  final String? checksum;
  final int? height;
  final String? imageId;
  final String? url;
  final int? width;

  GameEngineLogo({
    required this.id,
    this.alphaChannel,
    this.animated,
    this.checksum,
    this.height,
    this.imageId,
    this.url,
    this.width,
  });

  factory GameEngineLogo.fromJson(Map<String, dynamic> json) {
    String? logoUrl = json["url"];
    if (logoUrl != null) {
      logoUrl = logoUrl.replaceFirst("t_thumb", "t_720p");
    }
    return GameEngineLogo(
      alphaChannel: json['alpha_channel'],
      animated: json['animated'],
      checksum: json['checksum'],
      height: json['height'],
      imageId: json['image_id'],
      url: 'https:$logoUrl',
      width: json['width'], id: json['id'],
    );
  }
}
