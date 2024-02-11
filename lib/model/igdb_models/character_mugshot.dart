class CharacterMugshot {
  int id;
  final bool? alphaChannel;
  final bool? animated;
  final String? checksum;
  final int? height;
  final String? imageId;
  final String? url;
  final int? width;

  CharacterMugshot({
    required this.id,
    this.alphaChannel,
    this.animated,
    this.checksum,
    this.height,
    this.imageId,
    this.url,
    this.width,
  });

  factory CharacterMugshot.fromJson(Map<String, dynamic> json) {
    String? mugshotUrl = json["url"];
    if (mugshotUrl != null) {
      mugshotUrl = mugshotUrl.replaceFirst("t_thumb", "t_720p");
    }
    return CharacterMugshot(
      alphaChannel: json['alpha_channel'],
      animated: json['animated'],
      checksum: json['checksum'],
      height: json['height'],
      imageId: json['image_id'],
      url: 'https:$mugshotUrl',
      width: json['width'], id: json['id'],
    );
  }
}
