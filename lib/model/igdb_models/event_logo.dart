class EventLogo {
  int id;
  final bool? alphaChannel;
  final bool? animated;
  final String? checksum;
  final int? createdAt;
  final int? event;
  final int? height;
  final String? imageId;
  final int? updatedAt;
  final String? url;
  final int? width;

  EventLogo({
    required this.id,
    this.alphaChannel,
    this.animated,
    this.checksum,
    this.createdAt,
    this.event,
    this.height,
    this.imageId,
    this.updatedAt,
    this.url,
    this.width,
  });

  factory EventLogo.fromJson(Map<String, dynamic> json) {
    return EventLogo(
      alphaChannel: json['alpha_channel'],
      animated: json['animated'],
      checksum: json['checksum'],
      createdAt: json['created_at'],
      event: json['event'],
      height: json['height'],
      imageId: json['image_id'],
      updatedAt: json['updated_at'],
      url: json['url'],
      width: json['width'], id: json['id'],
    );
  }
}
