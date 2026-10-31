import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';

class AuthResult {
  final bool isSuccess;
  final String? message;
  final String? token;
  final String? userId;
  final String? name;
  final String? email;
  final String? phone;

  const AuthResult({
    required this.isSuccess,
    this.message,
    this.token,
    this.userId,
    this.name,
    this.email,
    this.phone,
  });
}

class AuthApiService {
  final ApiClient _client = ApiClient();

  Future<AuthResult> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.login,
        body: {
          'identifier': identifier.trim(),
          'password': password.trim(),
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final token = data['token'] as String? ?? '';
        final user = data['user'] as Map<String, dynamic>?;

        if (token.isNotEmpty) {
          _client.setToken(token);
        }

        return AuthResult(
          isSuccess: true,
          message: data['message'] as String? ?? 'Login successful',
          token: token,
          userId: user?['id'] as String?,
          name: user?['name'] as String?,
          email: user?['email'] as String?,
          phone: user?['phone'] as String?,
        );
      } else {
        String errMsg = 'Invalid credentials. Please verify your email/phone and password.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData['message'] != null) {
            errMsg = errorData['message'].toString();
          }
        } catch (_) {}
        return AuthResult(isSuccess: false, message: errMsg);
      }
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        message: 'Network connection error. Please try again ($e).',
      );
    }
  }
}

