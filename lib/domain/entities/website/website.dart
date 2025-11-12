// lib/domain/entities/website.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/website/website_type.dart';

class Website extends Equatable {
  final int id;
  final String url;
  final WebsiteType type;
  final String? title;

  const Website({
    required this.id,
    required this.url,
    required this.type,
    this.title,
  });

  @override
  List<Object?> get props => [id, url, type, title];
}
