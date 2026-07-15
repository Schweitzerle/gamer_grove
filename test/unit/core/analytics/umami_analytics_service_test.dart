import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/analytics/analytics_events.dart';
import 'package:gamer_grove/core/analytics/umami_analytics_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('UmamiAnalyticsService', () {
    test('is disabled and sends nothing when baseUrl is empty', () async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return http.Response('', 200);
      });
      final service = UmamiAnalyticsService(
        baseUrl: '',
        websiteId: 'site-1',
        client: client,
      );

      expect(service.isEnabled, isFalse);
      await service.track(AnalyticsEvents.appOpen);
      expect(calls, 0);
    });

    test('is disabled when websiteId is empty', () {
      final service = UmamiAnalyticsService(
        baseUrl: 'https://umami.example.com',
        websiteId: '',
        client: MockClient((_) async => http.Response('', 200)),
      );
      expect(service.isEnabled, isFalse);
    });

    test('posts a well-formed Umami event payload when enabled', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response('ok', 200);
      });
      final service = UmamiAnalyticsService(
        baseUrl: 'https://umami.example.com/',
        websiteId: 'site-1',
        client: client,
      );

      await service.track(
        AnalyticsEvents.rateGame,
        properties: const {AnalyticsProps.gameId: 42, AnalyticsProps.rating: 9},
      );

      // Trailing slash trimmed, correct endpoint.
      expect(captured.url.toString(), 'https://umami.example.com/api/send');
      expect(captured.headers['User-Agent'], isNotNull);
      expect(captured.headers['Content-Type'], contains('application/json'));

      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['type'], 'event');
      final payload = body['payload'] as Map<String, dynamic>;
      expect(payload['website'], 'site-1');
      expect(payload['name'], AnalyticsEvents.rateGame);
      expect(payload['url'], '/app/${AnalyticsEvents.rateGame}');
      expect(payload['data'], {'game_id': 42, 'rating': 9});
    });

    test('never throws when the network call fails', () async {
      final service = UmamiAnalyticsService(
        baseUrl: 'https://umami.example.com',
        websiteId: 'site-1',
        client: MockClient((_) async => throw Exception('network down')),
      );

      // Should complete without throwing.
      await expectLater(
        service.track(AnalyticsEvents.appOpen),
        completes,
      );
    });

    test('screen() tracks a screen_view event with the screen name', () async {
      late http.Request captured;
      final service = UmamiAnalyticsService(
        baseUrl: 'https://umami.example.com',
        websiteId: 'site-1',
        client: MockClient((request) async {
          captured = request;
          return http.Response('ok', 200);
        }),
      );

      await service.screen('home');

      final payload = (jsonDecode(captured.body)
          as Map<String, dynamic>)['payload'] as Map<String, dynamic>;
      expect(payload['name'], AnalyticsEvents.screenView);
      expect(payload['data'], {'screen': 'home'});
    });
  });
}
