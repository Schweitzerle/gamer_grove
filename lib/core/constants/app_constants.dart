// core/constants/app_constants.dart
class AppConstants {
  // App Info
  static const String appName = 'Gamer Grove';
  static const String appVersion = '2.0.0';
  static const String appDescription = 'Discover, rate and recommend videogames';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  static const int minSearchLength = 2;

  // Image Sizes
  static const String smallImageSize = 't_thumb';
  static const String mediumImageSize = 't_cover_big';
  static const String largeImageSize = 't_1080p';
  static const String screenshotSize = 't_screenshot_med';

  // Rating Constraints
  static const double minRating = 0;
  static const double maxRating = 10;
  static const int maxTopGames = 3;

  // Cache Settings
  static const Duration defaultCacheDuration = Duration(hours: 1);
  static const Duration userCacheDuration = Duration(hours: 24);
  static const Duration imageCacheDuration = Duration(days: 7);

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // UI Constraints
  static const double borderRadius = 12;
  static const double cardElevation = 4;
  static const double avatarSize = 50;
  static const double iconSize = 24;

  // Spacing
  static const double paddingSmall = 8;
  static const double paddingMedium = 16;
  static const double paddingLarge = 24;
  static const double paddingXLarge = 32;

  // Grid Layout
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 0.65;
  static const double gridSpacing = 16;

  // Text Limits
  static const int usernameMinLength = 3;
  static const int usernameMaxLength = 30;
  static const int bioMaxLength = 500;
  static const int passwordMinLength = 6;

  // Validation Patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String usernamePattern = r'^[a-zA-Z0-9_]+$';

  // Error Messages
  static const String networkErrorMessage = 'No internet connection. Please check your network.';
  static const String serverErrorMessage = 'Something went wrong. Please try again later.';
  static const String authErrorMessage = 'Authentication failed. Please check your credentials.';
  static const String validationErrorMessage = 'Please check your input and try again.';

  // Success Messages
  static const String loginSuccessMessage = 'Welcome back!';
  static const String signupSuccessMessage = 'Account created successfully!';
  static const String profileUpdateSuccessMessage = 'Profile updated successfully!';
  static const String passwordUpdateSuccessMessage = 'Password updated successfully!';

  // Feature Flags
  static const bool enableDarkMode = true;
  static const bool enableAnalytics = false; // Disabled for student version
  static const bool enableCrashReporting = false; // Disabled for student version
  static const bool enableOfflineMode = true;

  // Supported Locales
  static const List<String> supportedLocales = ['en', 'de'];
  static const String defaultLocale = 'en';

  // Social Features
  static const int maxFollowingCount = 1000;
  static const int maxWishlistCount = 500;
  static const int maxRecommendationsCount = 100;

  // Search Features
  static const int maxRecentSearches = 10;
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);

  // Platform Icons
  static const Map<String, String> platformIcons = {
    'pc': 'desktop_windows',
    'playstation': 'sports_esports',
    'xbox': 'sports_esports_outlined',
    'nintendo': 'videogame_asset',
    'mobile': 'phone_android',
    'switch': 'videogame_asset',
  };

  // Genre Colors
  static const Map<String, int> genreColors = {
    'Action': 0xFFE53E3E,
    'Adventure': 0xFF38A169,
    'RPG': 0xFF805AD5,
    'Strategy': 0xFF3182CE,
    'Simulation': 0xFF00B5D8,
    'Sports': 0xFFECC94B,
    'Racing': 0xFFED8936,
    'Shooter': 0xFFE53E3E,
    'Fighting': 0xFFD53F8C,
    'Puzzle': 0xFF38A169,
  };
}