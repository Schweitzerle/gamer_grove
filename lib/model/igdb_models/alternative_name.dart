class AlternativeName {
  int id;
  final String? checksum;
  final String? comment;
  final int? gameID; // Typ hier kann sich je nach Implementierung ändern, je nachdem, wie du die Referenz implementierst.
  final String? name;

  AlternativeName({
    required this.id,
    this.checksum,
    this.comment,
    this.gameID,
    this.name,
  });

  factory AlternativeName.fromJson(Map<String, dynamic> json) {
    return AlternativeName(
      checksum: json['checksum'],
      comment: json['comment'],
      gameID: json['game'],
      name: json['name'], id: json['id']
    );
  }
}
