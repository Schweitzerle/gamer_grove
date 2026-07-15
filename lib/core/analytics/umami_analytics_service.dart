import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gamer_grove/core/analytics/analytics_events.dart';
import 'package:gamer_grove/core/analytics/analytics_service.dart';
import 'package:http/http.dart' as http;

/// Sends events to a self-hosted Umami (https://umami.is) instance via its
/// `/api/send` event API. Umami has no mobile SDK, so we post events over HTTP.
///
/// Fire-and-forget: network failures are swallowed (analytics must never break
/// the app). Disabled (no-op) when `baseUrl` or `websiteId` is empty.
class UmamiAnalyticsService implements AnalyticsService {
  UmamiAnalyticsService({
    required String baseUrl,
    required String websiteId,
    required http.Client client,
    String hostname = 'app.gamergrove',
  })  : _baseUrl = _trimTrailingSlash(baseUrl),
        _websiteId = websiteId,
        _client = client,
        _hostname = hostname;

  final String _baseUrl;
  final String _websiteId;
  final http.Client _client;
  final String _hostname;

  /// Umami rejects requests without a User-Agent; identify the app explicitly.
  static const String _userAgent = 'GamerGrove/app (Flutter)';

  /// Whether a usable Umami configuration is present.
  bool get isEnabled => _baseUrl.isNotEmpty && _websiteId.isNotEmpty;

  static String _trimTrailingSlash(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;

  @override
  Future<void> screen(String screenName) => track(
        AnalyticsEvents.screenView,
        properties: {AnalyticsProps.screen: screenName},
      );

  @override
  Future<void> track(String name, {Map<String, Object?>? properties}) async {
    if (!isEnabled) return;

    final payload = <String, Object?>{
      'website': _websiteId,
      'hostname': _hostname,
      'language': 'en',
      'url': '/app/$name',
      'name': name,
      if (properties != null && properties.isNotEmpty) 'data': properties,
    };

    try {
      await _client.post(
        Uri.parse('$_baseUrl/api/send'),
        headers: const {
          'Content-Type': 'application/json',
          'User-Agent': _userAgent,
        },
        body: jsonEncode({'type': 'event', 'payload': payload}),
      );
    } on Exception catch (error) {
      // Never propagate analytics failures into product code.
      if (kDebugMode) {
        debugPrint('[analytics:umami] failed to send "$name": $error');
      }
    }
  }
}
