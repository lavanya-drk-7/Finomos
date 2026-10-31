import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // Default to Sireesha's live session token, updated upon login/switch
  String _token = 'jwt-token-cmuzhxi5a000asr4p9f6jcndp';

  String get token => _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = '';
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
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    return await http.get(uri, headers: _headers).timeout(timeout);
  }

  Future<Uint8List?> getBytes(
    String endpointOrUrl, {
    Map<String, String>? queryParams,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final Uri uri;
      if (endpointOrUrl.startsWith('http://') || endpointOrUrl.startsWith('https://')) {
        uri = Uri.parse(endpointOrUrl);
      } else {
        uri = _buildUri(endpointOrUrl, queryParams);
      }
      final response = await http.get(uri, headers: {
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
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = _buildUri(endpoint);
    return await http
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
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = _buildUri(endpoint);
    return await http
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
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = _buildUri(endpoint);
    return await http
        .patch(
          uri,
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(timeout);
  }

  Future<http.Response> delete(
    String endpoint, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = _buildUri(endpoint);
    return await http.delete(uri, headers: _headers).timeout(timeout);
  }

  MediaType _resolveMediaType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return MediaType('image', 'jpeg');
    if (lower.endsWith('.pdf')) return MediaType('application', 'pdf');
    return MediaType('image', 'jpeg');
  }

  Future<http.Response> multipartPost(
    String endpoint, {
    required File file,
    required String fileFieldName,
    Map<String, String>? fields,
    Duration timeout = const Duration(seconds: 45),
  }) async {
    final uri = _buildUri(endpoint);
    final request = http.MultipartRequest('POST', uri);

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
}

