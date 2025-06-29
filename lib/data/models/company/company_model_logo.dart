// ===== COMPANY LOGO MODEL =====
// lib/data/models/company/company_logo_model.dart
import '../../../../domain/entities/company/company_logo.dart';

class CompanyLogoModel extends CompanyLogo {
  const CompanyLogoModel({
    required super.id,
    required super.checksum,
    required super.imageId,
    required super.height,
    required super.width,
    super.alphaChannel = false,
    super.animated = false,
    super.url,
  });

  factory CompanyLogoModel.fromJson(Map<String, dynamic> json) {
    return CompanyLogoModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      imageId: json['image_id'] ?? '',
      height: json['height'] ?? 0,
      width: json['width'] ?? 0,
      alphaChannel: json['alpha_channel'] ?? false,
      animated: json['animated'] ?? false,
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'image_id': imageId,
      'height': height,
      'width': width,
      'alpha_channel': alphaChannel,
      'animated': animated,
      'url': url,
    };
  }

  // Factory method for easy creation with IGDB image URL
  factory CompanyLogoModel.withImageUrl({
    required int id,
    required String checksum,
    required String imageId,
    required int height,
    required int width,
    bool alphaChannel = false,
    bool animated = false,
    String? customUrl,
  }) {
    return CompanyLogoModel(
      id: id,
      checksum: checksum,
      imageId: imageId,
      height: height,
      width: width,
      alphaChannel: alphaChannel,
      animated: animated,
      url: customUrl ?? 'https://images.igdb.com/igdb/image/upload/t_logo_med/$imageId.jpg',
    );
  }
}

