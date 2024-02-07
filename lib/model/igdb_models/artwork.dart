class Artwork {
  int id;
  final bool? alphaChannel;
  final bool? animated;
  final String? checksum;
  final int? gameID; // Typ hier kann sich je nach Implementierung ändern, je nachdem, wie du die Referenz implementierst.
  final int? height;
  final String? imageId;
  final String? url;
  final int? width;

  Artwork({
    required this.id,
    this.alphaChannel,
    this.animated,
    this.checksum,
    this.gameID,
    this.height,
    this.imageId,
    this.url,
    this.width,
  });

  factory Artwork.fromJson(Map<String, dynamic> json) {
    String? artworkUrl = json["url"];
    if (artworkUrl != null) {
      artworkUrl = artworkUrl.replaceFirst("t_thumb", "t_720p");
    }
    return Artwork(
      alphaChannel: json['alpha_channel'],
      animated: json['animated'],
      checksum: json['checksum'],
      gameID: json['game'],
      height: json['height'],
      imageId: json['image_id'],
      url: 'https:$artworkUrl',
      width: json['width'], id: json['id'],
    );
  }
}
