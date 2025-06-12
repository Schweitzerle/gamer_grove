// core/network/api_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final http.Client client;

  ApiClient(this.client);

  Future<dynamic> get(
      String url, {
        Map<String, String>? headers,
        Map<String, String>? queryParameters,
      }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParameters);
      final response = await client.get(uri, headers: headers).timeout(
        ApiConstants.connectionTimeout,
      );

      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on HttpException {
      throw NetworkException();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<dynamic> post(
      String url, {
        Map<String, String>? headers,
        dynamic body,
        Map<String, String>? queryParameters,
      }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParameters);
      final response = await client
          .post(
        uri,
        headers: headers,
        body: body is String ? body : json.encode(body),
      )
          .timeout(ApiConstants.connectionTimeout);

      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on HttpException {
      throw NetworkException();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<dynamic> put(
      String url, {
        Map<String, String>? headers,
        dynamic body,
        Map<String, String>? queryParameters,
      }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParameters);
      final response = await client
          .put(
        uri,
        headers: headers,
        body: body is String ? body : json.encode(body),
      )
          .timeout(ApiConstants.connectionTimeout);

      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on HttpException {
      throw NetworkException();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<dynamic> delete(
      String url, {
        Map<String, String>? headers,
        Map<String, String>? queryParameters,
      }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParameters);
      final response = await client
          .delete(uri, headers: headers)
          .timeout(ApiConstants.connectionTimeout);

      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on HttpException {
      throw NetworkException();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        if (response.body.isEmpty) {
          return null;
        }
        return json.decode(response.body);
      case 400:
        throw ServerException(
          message: 'Bad request',
          statusCode: response.statusCode,
        );
      case 401:
        throw AuthException(
          message: 'Unauthorized',
          code: '401',
        );
      case 403:
        throw AuthException(
          message: 'Forbidden',
          code: '403',
        );
      case 404:
        throw ServerException(
          message: 'Not found',
          statusCode: response.statusCode,
        );
      case 500:
        throw ServerException(
          message: 'Internal server error',
          statusCode: response.statusCode,
        );
      default:
        throw ServerException(
          message: 'Error occurred with status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
    }
  }
}