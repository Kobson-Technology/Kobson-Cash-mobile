import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../storage/token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _client = http.Client();

  String get _baseUrl => AppConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await TokenStorage.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);

    final response = await _client.get(url, headers: headers);
    return _handleResponse(response, () => get(endpoint, requiresAuth: requiresAuth), requiresAuth);
  }

  Future<dynamic> post(String endpoint, {dynamic body, bool requiresAuth = true}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);

    final response = await _client.post(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response, () => post(endpoint, body: body, requiresAuth: requiresAuth), requiresAuth);
  }

  Future<dynamic> put(String endpoint, {dynamic body, bool requiresAuth = true}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);

    final response = await _client.put(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response, () => put(endpoint, body: body, requiresAuth: requiresAuth), requiresAuth);
  }

  Future<dynamic> _handleResponse(
    http.Response response,
    Future<dynamic> Function() retryCall,
    bool requiresAuth,
  ) async {
    // 401 Unauthorized -> Attempt token refresh
    if (response.statusCode == 401 && requiresAuth) {
      final refreshed = await _attemptRefreshToken();
      if (refreshed) {
        return await retryCall();
      }
      throw ApiException(statusCode: 401, message: 'Session expirée. Veuillez vous reconnecter.');
    }

    final bodyString = response.body;
    dynamic jsonBody;
    if (bodyString.isNotEmpty) {
      try {
        jsonBody = jsonDecode(bodyString);
      } catch (_) {
        jsonBody = bodyString;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonBody;
    }

    String errorMessage = 'Une erreur est survenue (${response.statusCode})';
    if (jsonBody is Map<String, dynamic>) {
      if (jsonBody.containsKey('error')) {
        errorMessage = jsonBody['error'].toString();
      } else if (jsonBody.containsKey('message')) {
        errorMessage = jsonBody['message'].toString();
      }
    }

    throw ApiException(statusCode: response.statusCode, message: errorMessage);
  }

  Future<bool> _attemptRefreshToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final url = Uri.parse('$_baseUrl/api/v1/auth/refresh');
      final res = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          await TokenStorage.saveTokens(accessToken: newAccessToken, refreshToken: newRefreshToken);
          return true;
        }
      }
    } catch (_) {}

    await TokenStorage.clearTokens();
    return false;
  }
}
