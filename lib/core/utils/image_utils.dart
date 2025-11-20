// core/utils/image_utils.dart
import 'package:gamer_grove/core/constants/app_constants.dart';

class ImageUtils {
  // Build IGDB image URL with proper size
  static String buildIgdbImageUrl(String? baseUrl,
      {String size = AppConstants.mediumImageSize,}) {
    if (baseUrl == null || baseUrl.isEmpty) return '';

    // IGDB URLs come without https: prefix
    if (baseUrl.startsWith('//')) {
      baseUrl = 'https:$baseUrl';
    }

    // If URL doesn't start with http, add https://
    if (!baseUrl.startsWith('http')) {
      baseUrl = 'https://$baseUrl';
    }

    // IGDB URL structure: https://images.igdb.com/igdb/image/upload/t_{size}/{hash}.jpg
    // We need to replace the size part in the path, not just the t_thumb part

    // Find and replace any existing size parameter
    final sizeRegex = RegExp('t_[a-zA-Z0-9_]+');
    if (sizeRegex.hasMatch(baseUrl)) {
      baseUrl = baseUrl.replaceAll(sizeRegex, size);
    }

    return baseUrl;
  }

  // Get different image sizes
  static String getSmallImageUrl(String? baseUrl) {
    return buildIgdbImageUrl(baseUrl, size: AppConstants.smallImageSize);
  }

  static String getMediumImageUrl(String? baseUrl) {
    return buildIgdbImageUrl(baseUrl);
  }

  static String getLargeImageUrl(String? baseUrl) {
    return buildIgdbImageUrl(baseUrl, size: AppConstants.largeImageSize);
  }

  static String getScreenshotUrl(String? baseUrl) {
    return buildIgdbImageUrl(baseUrl, size: AppConstants.screenshotSize);
  }

  // Check if URL is valid image
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    final lowerUrl = url.toLowerCase();
    return lowerUrl.startsWith('http') &&
        (lowerUrl.contains('.jpg') ||
            lowerUrl.contains('.jpeg') ||
            lowerUrl.contains('.png') ||
            lowerUrl.contains('.webp') ||
            lowerUrl.contains('.gif'));
  }

  // Get platform icon
  static String getPlatformIcon(String platformName) {
    final lowerName = platformName.toLowerCase();

    for (final entry in AppConstants.platformIcons.entries) {
      if (lowerName.contains(entry.key)) {
        return entry.value;
      }
    }

    return 'devices'; // Default icon
  }

  // Get genre color
  static int getGenreColor(String genreName) {
    return AppConstants.genreColors[genreName] ?? 0xFF9CA3AF; // Default gray
  }

  // Generate placeholder image URL
  static String generatePlaceholderUrl(int width, int height, {String? text}) {
    final displayText = text ?? '${width}x$height';
    return 'https://via.placeholder.com/${width}x$height.png?text=$displayText';
  }

  // Resize image URL for better performance
  static String getOptimizedImageUrl(String? originalUrl,
      {int? width, int? height,}) {
    if (originalUrl == null || originalUrl.isEmpty) return '';

    // For IGDB images, use appropriate size
    if (originalUrl.contains('igdb.com')) {
      if (width != null && height != null) {
        if (width <= 90 && height <= 120) {
          return getSmallImageUrl(originalUrl);
        } else if (width <= 264 && height <= 352) {
          return getMediumImageUrl(originalUrl);
        } else {
          return getLargeImageUrl(originalUrl);
        }
      }
      return getMediumImageUrl(originalUrl);
    }

    return originalUrl;
  }

  // Extract image dimensions from URL if possible
  static Map<String, int>? extractImageDimensions(String url) {
    // Try to extract dimensions from URL patterns like "300x200"
    final dimensionRegex = RegExp(r'(\d+)x(\d+)');
    final match = dimensionRegex.firstMatch(url);

    if (match != null) {
      return {
        'width': int.parse(match.group(1)!),
        'height': int.parse(match.group(2)!),
      };
    }

    return null;
  }
}


