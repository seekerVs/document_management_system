import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService._();

  static const String _baseUrl = String.fromEnvironment('API_BASE_URL');

  static const String _apiKey = String.fromEnvironment('API_SECRET_KEY');

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'x-api-key': _apiKey,
  };

  // ─── POST ─────────────────────────────────────────────────────────────────

  static Future<ApiResult> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      debugPrint('API POST: $uri');
      final response = await http
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _parseResponse(response);
    } catch (e) {
      return const ApiResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ─── GET ──────────────────────────────────────────────────────────────────

  static Future<ApiResult> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl$endpoint',
      ).replace(queryParameters: queryParams);
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));
      return _parseResponse(response);
    } catch (e) {
      return const ApiResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static ApiResult _parseResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResult(
        success: body['success'] == true,
        message: body['message'] ?? '',
        data: body['data'],
        statusCode: response.statusCode,
      );
    } catch (_) {
      return ApiResult(
        success: false,
        message: 'Unexpected server response.',
        statusCode: response.statusCode,
      );
    }
  }
}

// ─── Result wrapper ───────────────────────────────────────────────────────────

class ApiResult {
  final bool success;
  final String message;
  final dynamic data;
  final int? statusCode;

  const ApiResult({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });
}
