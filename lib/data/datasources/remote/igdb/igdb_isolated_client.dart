// lib/data/datasources/remote/igdb/igdb_isolated_client.dart
// UPDATED - verwendet SharedPrefsTokenManager

import 'dart:convert';
import 'package:gamer_grove/data/datasources/remote/igdb/shared_preft_topken_manager.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';

class IsolatedIGDBClient {
  static IsolatedIGDBClient? _instance;
  static IsolatedIGDBClient get instance => _instance ??= IsolatedIGDBClient._();

  IsolatedIGDBClient._();

  final http.Client _httpClient = http.Client();

  Future<List<dynamic>> makeIGDBRequest(String endpoint, String body) async {
    try {
      // Hole Token vom SharedPrefs Manager
      final token = await SharedPrefsTokenManager.instance.getValidToken();

      print('📡 IGDB: Making request to $endpoint');
      print('🔧 IGDB: Using managed token: ${token.substring(0, 10)}...');

      final request = http.Request('POST', Uri.parse('${ApiConstants.igdbBaseUrl}/$endpoint'));

      request.headers['Client-ID'] = ApiConstants.igdbClientId;
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'text/plain';
      request.headers['Accept'] = 'application/json';

      request.body = body.trim();

      print('🔧 IGDB: Request body: ${request.body}');

      final streamedResponse = await _httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      print('📨 IGDB: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('✅ IGDB: Successfully parsed ${jsonList.length} items');
        return jsonList;
      } else {
        throw ServerException(
          message: 'IGDB request failed: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('💥 IGDB: Request error: $e');
      throw ServerException(message: 'IGDB request failed: $e');
    }
  }

  Future<http.Response> makeIGDBRawRequest(String endpoint, String body) async {
    try {
      final token = await SharedPrefsTokenManager.instance.getValidToken();

      final request = http.Request('POST', Uri.parse('${ApiConstants.igdbBaseUrl}/$endpoint'));
      request.headers['Client-ID'] = ApiConstants.igdbClientId;
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'text/plain';
      request.headers['Accept'] = 'application/json';
      request.body = body.trim();

      final streamedResponse = await _httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'IGDB request failed: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      return response;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'IGDB raw request failed: $e');
    }
  }
}