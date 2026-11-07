import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';
import 'cache_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() {
    try {
      final session = LocalCacheService().get('auth_session');
      if (session is Map && session['isLoggedIn'] == true) {
        final token = session['token']?.toString() ?? '';
        if (token.isNotEmpty) _token = token;
        final refToken = session['refreshToken']?.toString() ?? '';
        if (refToken.isNotEmpty) _refreshToken = refToken;
      }
    } catch (_) {}
  }

  // Persistent shared HTTP client instance with HTTP keep-alive connection reuse
  final http.Client _client = http.Client();

  // Session tokens are empty by default; populated upon login or restored from active session
  String _token = '';

  // Refresh token for session renewal
  String _refreshToken = '';

  String get token => _token;
  String get refreshToken => _refreshToken;

  void setToken(String token) {
    _token = token;
  }

  void setRefreshToken(String refreshToken) {
    _refreshToken = refreshToken;
  }

  void clearToken() {
    _token = '';
  }

  void clearRefreshToken() {
    _refreshToken = '';
  }

  void clearSession() {
    _token = '';
    _refreshToken = '';
  }

  Map<String, String> get _headers {
    final map = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token.isNotEmpty) {
      map['Authorization'] = 'Bearer $_token';
    }
    return map;
  }

  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final fullUrl = '${ApiConstants.baseUrl}$endpoint';
    final uri = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    return await _client.get(uri, headers: _headers).timeout(timeout);
  }

  Future<Uint8List?> getBytes(
    String endpointOrUrl, {
    Map<String, String>? queryParams,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    try {
      final Uri uri;
      if (endpointOrUrl.startsWith('http://') || endpointOrUrl.startsWith('https://')) {
        uri = Uri.parse(endpointOrUrl);
      } else {
        uri = _buildUri(endpointOrUrl, queryParams);
      }
      final response = await _client.get(uri, headers: {
        'Accept': 'application/pdf, application/octet-stream, */*',
        if (_token.isNotEmpty) 'Authorization': 'Bearer $_token',
      }).timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
    } catch (_) {}
    return null;
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final uri = _buildUri(endpoint);
    return await _client
        .post(
          uri,
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(timeout);
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final uri = _buildUri(endpoint);
    return await _client
        .put(
          uri,
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(timeout);
  }

  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final uri = _buildUri(endpoint);
    return await _client
        .patch(
          uri,
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(timeout);
  }

  Future<http.Response> delete(
    String endpoint, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final uri = _buildUri(endpoint);
    return await _client.delete(uri, headers: _headers).timeout(timeout);
  }

  MediaType _resolveMediaType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return MediaType('image', 'jpeg');
    if (lower.endsWith('.pdf')) return MediaType('application', 'pdf');
    return MediaType('image', 'jpeg');
  }

  Future<http.Response> _sendMultipart(
    String method,
    String endpoint, {
    required File file,
    required String fileFieldName,
    Map<String, String>? fields,
    Duration timeout = const Duration(seconds: 45),
  }) async {
    final uri = _buildUri(endpoint);
    final request = http.MultipartRequest(method, uri);

    if (_token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    if (fields != null) {
      request.fields.addAll(fields);
    }

    String fileName = file.path.split(Platform.isWindows ? '\\' : '/').last;
    if (!fileName.contains('.')) {
      fileName = '$fileName.jpg';
    }

    final multipartFile = await http.MultipartFile.fromPath(
      fileFieldName,
      file.path,
      filename: fileName,
      contentType: _resolveMediaType(fileName),
    );
    request.files.add(multipartFile);

    final streamedResponse = await request.send().timeout(timeout);
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> multipartPost(
    String endpoint, {
    required File file,
    required String fileFieldName,
    Map<String, String>? fields,
    Duration timeout = const Duration(seconds: 45),
  }) async {
    return _sendMultipart(
      'POST',
      endpoint,
      file: file,
      fileFieldName: fileFieldName,
      fields: fields,
      timeout: timeout,
    );
  }

  Future<http.Response> multipartPut(
    String endpoint, {
    required File file,
    required String fileFieldName,
    Map<String, String>? fields,
    Duration timeout = const Duration(seconds: 45),
  }) async {
    return _sendMultipart(
      'PUT',
      endpoint,
      file: file,
      fileFieldName: fileFieldName,
      fields: fields,
      timeout: timeout,
    );
  }
}
