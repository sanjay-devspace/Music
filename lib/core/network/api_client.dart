import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:tunehive/core/constants/app_constants.dart';
import 'package:tunehive/core/errors/app_exception.dart';
import 'package:tunehive/core/network/network_response.dart';

/// Minimal typed HTTP client.
///
/// Contains no business logic — only request construction, JSON decoding and
/// exception mapping. Auth headers can be attached per request.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void addHeader(String key, String value) => _headers[key] = value;
  void removeHeader(String key) => _headers.remove(key);
  Map<String, String> get headers => Map.unmodifiable(_headers);

  Future<NetworkResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(path).replace(queryParameters: query);
      final response = await _client
          .get(uri, headers: {..._headers, ...?headers})
          .timeout(AppConstants.networkTimeout);
      return _decode(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(cause: e);
    }
  }

  Future<NetworkResponse<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(path),
            headers: {..._headers, ...?headers},
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(AppConstants.networkTimeout);
      return _decode(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(cause: e);
    }
  }

  NetworkResponse<Map<String, dynamic>> _decode(http.Response response) {
    final status = response.statusCode;
    if (status < 200 || status > 299) {
      return NetworkResponse.failure(statusCode: status);
    }
    if (response.body.isEmpty) {
      return NetworkResponse<Map<String, dynamic>>(
        data: const {},
        statusCode: status,
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return NetworkResponse(data: decoded, statusCode: status);
    }
    return NetworkResponse.failure(statusCode: status);
  }
}