// lib/core/utils/url_utils.dart
import 'package:url_launcher/url_launcher.dart';

class UrlUtils {
  static Future<bool> openYouTubeVideo(String url) async {
    try {
      // Versuche YouTube App
      final videoId = _extractYouTubeVideoId(url);
      if (videoId != null) {
        final youtubeAppUrl = 'youtube://watch?v=$videoId';
        if (await canLaunchUrl(Uri.parse(youtubeAppUrl))) {
          return await launchUrl(
            Uri.parse(youtubeAppUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      }

      // Fallback: Browser
      return await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      return false;
    }
  }

  static String? _extractYouTubeVideoId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
}