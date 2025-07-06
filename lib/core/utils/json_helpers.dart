// ===== UNIVERSAL JSON PARSING HELPERS =====
// lib/core/utils/json_helpers.dart

/// Universal JSON parsing utilities for handling both basic and expanded IGDB API responses
///
/// Handles the difference between:
/// - Basic fields: { "company": 123 }
/// - Complete fields: { "company": { "id": 123, "name": "Company Name", ... } }
class JsonHelpers {

  // ==========================================
  // ID EXTRACTION METHODS
  // ==========================================

  /// Extract ID from either int or Map<String, dynamic>
  /// Handles both basic fields (just ID) and complete fields (full object)
  ///
  /// Examples:
  /// - extractId(123) -> 123
  /// - extractId({"id": 123, "name": "Test"}) -> 123
  /// - extractId(null) -> null
  static int? extractId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is Map<String, dynamic>) {
      return value['id'] as int?;
    }
    return null;
  }

  /// Extract list of IDs from either List<int> or List<Map<String, dynamic>>
  ///
  /// Examples:
  /// - extractIds([1, 2, 3]) -> [1, 2, 3]
  /// - extractIds([{"id": 1}, {"id": 2}]) -> [1, 2]
  /// - extractIds(null) -> []
  static List<int> extractIds(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => extractId(item))
          .where((id) => id != null)
          .cast<int>()
          .toList();
    }
    return [];
  }

  // ==========================================
  // STRING EXTRACTION METHODS
  // ==========================================

  /// Extract string value from either string or Map with 'name' field
  ///
  /// Examples:
  /// - extractName("Test") -> "Test"
  /// - extractName({"id": 1, "name": "Test"}) -> "Test"
  /// - extractName(null) -> null
  static String? extractName(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['name'] as String?;
    }
    return null;
  }

  /// Extract URL from either string or Map with 'url' field
  ///
  /// Examples:
  /// - extractUrl("https://example.com") -> "https://example.com"
  /// - extractUrl({"id": 1, "url": "https://example.com"}) -> "https://example.com"
  /// - extractUrl(null) -> null
  static String? extractUrl(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['url'] as String?;
    }
    return null;
  }

  /// Extract slug from either string or Map with 'slug' field
  static String? extractSlug(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['slug'] as String?;
    }
    return null;
  }

  /// Extract description from either string or Map with 'description' field
  static String? extractDescription(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['description'] as String?;
    }
    return null;
  }

  // ==========================================
  // DATE/TIME PARSING
  // ==========================================

  /// Parse DateTime from various formats (string ISO, Unix timestamp)
  ///
  /// Examples:
  /// - parseDateTime("2024-01-01T00:00:00.000Z") -> DateTime object
  /// - parseDateTime(1672531200) -> DateTime object (from Unix timestamp)
  /// - parseDateTime(null) -> null
  static DateTime? parseDateTime(dynamic date) {
    if (date == null) return null;

    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is int) {
      try {
        // IGDB uses Unix timestamps in seconds
        return DateTime.fromMillisecondsSinceEpoch(date * 1000);
      } catch (e) {
        print('⚠️ JsonHelpers: Failed to parse timestamp: $date');
        return null;
      }
    }
    return null;
  }

  // ==========================================
  // NESTED VALUE EXTRACTION
  // ==========================================

  /// Extract nested value safely using dot notation
  ///
  /// Examples:
  /// - extractNested({"user": {"profile": {"name": "John"}}}, "user.profile.name") -> "John"
  /// - extractNested({"user": {"id": 123}}, "user.id") -> 123
  /// - extractNested({}, "missing.path") -> null
  static T? extractNested<T>(dynamic value, String path) {
    if (value == null) return null;

    final keys = path.split('.');
    dynamic current = value;

    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }

    return current is T ? current : null;
  }

  /// Extract multiple nested values at once
  ///
  /// Example:
  /// - extractMultipleNested(json, ["user.name", "user.email", "user.id"])
  ///   -> {"user.name": "John", "user.email": "john@example.com", "user.id": 123}
  static Map<String, dynamic> extractMultipleNested(
      dynamic value,
      List<String> paths
      ) {
    final result = <String, dynamic>{};
    for (final path in paths) {
      result[path] = extractNested(value, path);
    }
    return result;
  }

  // ==========================================
  // LIST PROCESSING
  // ==========================================

  /// Extract list of names from array of objects
  ///
  /// Examples:
  /// - extractNames([{"name": "A"}, {"name": "B"}]) -> ["A", "B"]
  /// - extractNames(["A", "B"]) -> ["A", "B"]
  /// - extractNames(null) -> []
  static List<String> extractNames(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => extractName(item))
          .where((name) => name != null && name.isNotEmpty)
          .cast<String>()
          .toList();
    }
    return [];
  }

  /// Extract list of URLs from array of objects
  static List<String> extractUrls(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => extractUrl(item))
          .where((url) => url != null && url.isNotEmpty)
          .cast<String>()
          .toList();
    }
    return [];
  }

  // ==========================================
  // TYPE CHECKING & VALIDATION
  // ==========================================

  /// Check if value is an expanded object (has 'id' field)
  static bool isExpandedObject(dynamic value) {
    return value is Map<String, dynamic> && value.containsKey('id');
  }

  /// Check if value is a simple reference (just an ID)
  static bool isSimpleReference(dynamic value) {
    return value is int;
  }

  /// Check if list contains expanded objects
  static bool hasExpandedObjects(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return isExpandedObject(value.first);
    }
    return false;
  }

  // ==========================================
  // DATA TRANSFORMATION
  // ==========================================

  /// Convert expanded object back to simple reference for API calls
  /// Useful when you need to send data back to API in simplified form
  static Map<String, dynamic> simplifyReferences(Map<String, dynamic> json) {
    final simplified = <String, dynamic>{};

    json.forEach((key, value) {
      if (value is Map<String, dynamic> && value.containsKey('id')) {
        // Convert expanded object to just ID
        simplified[key] = value['id'];
      } else if (value is List) {
        // Convert list of expanded objects to list of IDs
        simplified[key] = value.map((item) {
          if (item is Map<String, dynamic> && item.containsKey('id')) {
            return item['id'];
          }
          return item;
        }).toList();
      } else {
        // Keep as-is
        simplified[key] = value;
      }
    });

    return simplified;
  }

  // ==========================================
  // DEBUGGING UTILITIES
  // ==========================================

  /// Debug helper to analyze JSON structure
  /// Very useful for understanding what IGDB API returns
  static void analyzeJsonStructure(
      Map<String, dynamic> json, {
        String prefix = '',
        int maxDepth = 2,
        int currentDepth = 0,
      }) {
    if (currentDepth >= maxDepth) return;

    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final keys = value.keys.take(8).join(', ');
        final moreKeys = value.keys.length > 8 ? '...' : '';
        print('$prefix$key: Map with keys: $keys$moreKeys');

        if (value.containsKey('id')) {
          print('$prefix  └─ Expanded object with ID: ${value['id']}');
        }

        // Recurse into nested objects
        if (currentDepth < maxDepth - 1) {
          analyzeJsonStructure(value, prefix: '$prefix  ', maxDepth: maxDepth, currentDepth: currentDepth + 1);
        }
      } else if (value is List) {
        if (value.isNotEmpty) {
          final first = value.first;
          if (first is Map<String, dynamic>) {
            final keys = first.keys.take(6).join(', ');
            final moreKeys = first.keys.length > 6 ? '...' : '';
            print('$prefix$key: List<Map> (${value.length} items) with keys: $keys$moreKeys');
          } else {
            print('$prefix$key: List<${first.runtimeType}> (${value.length} items)');
          }
        } else {
          print('$prefix$key: Empty list');
        }
      } else {
        final valueStr = value.toString();
        final displayValue = valueStr.length > 50
            ? '${valueStr.substring(0, 50)}...'
            : valueStr;
        print('$prefix$key: ${value.runtimeType} = $displayValue');
      }
    });
  }

  /// Quick check to see what type of API response you're dealing with
  static void analyzeApiResponseType(Map<String, dynamic> json) {
    int expandedObjects = 0;
    int simpleReferences = 0;
    int totalFields = 0;

    json.forEach((key, value) {
      totalFields++;
      if (isExpandedObject(value)) {
        expandedObjects++;
      } else if (isSimpleReference(value)) {
        simpleReferences++;
      } else if (value is List && hasExpandedObjects(value)) {
        expandedObjects++;
      }
    });

    print('📊 API Response Analysis:');
    print('   Total fields: $totalFields');
    print('   Expanded objects: $expandedObjects');
    print('   Simple references: $simpleReferences');
    print('   Response type: ${expandedObjects > simpleReferences ? "COMPLETE" : "BASIC"}');
  }

  // ==========================================
  // IGDB SPECIFIC HELPERS
  // ==========================================

  /// Extract IGDB image URL with proper formatting
  /// Handles both direct URLs and image_id constructions
  static String? extractImageUrl(
      dynamic value, {
        String size = 'cover_big', // cover_small, cover_big, 720p, 1080p, etc.
      }) {
    if (value == null) return null;

    // Direct URL
    if (value is String) return value;

    // Image object with image_id
    if (value is Map<String, dynamic>) {
      final imageId = value['image_id'] as String?;
      if (imageId != null) {
        return 'https://images.igdb.com/igdb/image/upload/t_$size/$imageId.jpg';
      }

      // Fallback to direct URL field
      return value['url'] as String?;
    }

    return null;
  }

  /// Parse IGDB rating (0-100 scale)
  static double? parseRating(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Parse IGDB date (Unix timestamp to DateTime)
  static DateTime? parseIGDBDate(dynamic value) {
    return parseDateTime(value);
  }
}