import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static const bool isProduction = true;
  
  // Use localhost (127.0.0.1) since you are running on Chrome (Web).
  static const String localBaseUrl = 'http://127.0.0.1:8000/api';
  static const String prodBaseUrl = 'https://financial-tracking-jade-mu.vercel.app/api';

  final String baseUrl = isProduction ? prodBaseUrl : localBaseUrl;
  static const Duration timeout = Duration(seconds: 30);

  // Toggle this to use mock data for development when API is unavailable
  static const bool useMockData = false;

  final storage = GetStorage();

  // Create custom HTTP client with better error handling
  http.Client _getHttpClient() {
    return http.Client();
  }

  // Get stored auth token
  String? getToken() {
    return storage.read('auth_token');
  }

  // Set auth token
  Future<void> setToken(String token) async {
    await storage.write('auth_token', token);
  }

  // Clear auth token
  Future<void> clearToken() async {
    await storage.remove('auth_token');
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return getToken() != null;
  }

  Map<String, String> _getHeaders({
    bool requireAuth = true,
    String contentType = 'application/json',
  }) {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': contentType,
    };

    if (requireAuth) {
      final token = getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    // Return mock data if enabled
    if (useMockData) {
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate network delay
      return _getMockData(endpoint);
    }

    try {
      final url = Uri.parse("$baseUrl/$endpoint");
      final headers = _getHeaders();

      // Debug logging
      // print('🔵 GET Request: $endpoint');
      // print('📍 URL: $url');
      // print('🔐 Token: ${getToken() != null ? "Present" : "Missing"}');
      // print('📦 Headers: $headers');

      final response = await http
          .get(url, headers: headers)
          .timeout(
            timeout,
            onTimeout: () {
              throw ApiException(message: 'Request timeout');
            },
          );

      // print('✅ Response Status: ${response.statusCode}');
      // print('📄 Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Error: $e');
      _handleError(e);
    }
  }

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = true,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final mockData = Map<String, dynamic>.from(data);
      if (!mockData.containsKey('id')) {
        mockData['id'] = DateTime.now().millisecondsSinceEpoch;
      }
      mockData['created_at'] = DateTime.now().toIso8601String();
      mockData['updated_at'] = DateTime.now().toIso8601String();
      return mockData;
    }
    try {
      final url = Uri.parse("$baseUrl/$endpoint");
      final headers = _getHeaders(requireAuth: requireAuth);
      final body = jsonEncode(data);

      // Debug logging
      print('🔵 POST Request: $endpoint');
      print('📍 URL: $url');
      print('📦 Data: $data');
      print('🔐 Headers: $headers');

      final client = _getHttpClient();
      final request = http.Request('POST', url)
        ..headers.addAll(headers)
        ..body = body;

      final streamedResponse = await client
          .send(request)
          .timeout(
            timeout,
            onTimeout: () {
              throw ApiException(
                message:
                    'Connection timeout. Server took too long to respond. Please check your internet connection and try again.',
              );
            },
          );

      final response = await http.Response.fromStream(streamedResponse);

      print('✅ Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      print('❌ Error: $e');
      _handleError(e);
    }
  }

  /// Sends a POST request with application/x-www-form-urlencoded body.
  /// Required by the Financial Tracking API auth endpoints
  /// (register, login, logout, firebase/login).
  Future<dynamic> postForm(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = false,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/$endpoint");
      final headers = _getHeaders(
        requireAuth: requireAuth,
        contentType: 'application/x-www-form-urlencoded',
      );

      // Encode as form fields (filter out null values)
      final body = data.entries
          .where((e) => e.value != null)
          .map((e) =>
              '${Uri.encodeQueryComponent(e.key)}='
              '${Uri.encodeQueryComponent(e.value.toString())}')
          .join('&');

      print('🔵 POST FORM Request: $endpoint');
      print('📍 URL: $url');
      print('📦 Data: $data');

      final client = _getHttpClient();
      final request = http.Request('POST', url)
        ..headers.addAll(headers)
        ..body = body;

      final streamedResponse = await client.send(request).timeout(
        timeout,
        onTimeout: () {
          throw ApiException(
            message: 'Connection timeout. Server took too long to respond.',
          );
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('✅ Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      print('❌ Form POST Error: $e');
      _handleError(e);
    }
  }

  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = true,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final mockData = Map<String, dynamic>.from(data);
      mockData['updated_at'] = DateTime.now().toIso8601String();
      return mockData;
    }
    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl/$endpoint"),
            headers: _getHeaders(requireAuth: requireAuth),
            body: jsonEncode(data),
          )
          .timeout(
            timeout,
            onTimeout: () {
              throw ApiException(message: 'Request timeout');
            },
          );

      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> delete(String endpoint) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    try {
      final response = await http
          .delete(Uri.parse("$baseUrl/$endpoint"), headers: _getHeaders())
          .timeout(
            timeout,
            onTimeout: () {
              throw ApiException(message: 'Request timeout');
            },
          );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw ApiException(
          message: 'Failed to delete',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      _handleError(e);
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        final message = errorBody['message'] ?? 'Unknown error';
        throw ApiException(message: message, statusCode: response.statusCode);
      } catch (e) {
        throw ApiException(
          message: 'Error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    }
  }

  void _handleError(dynamic error) {
    print('🔴 Handling error: $error');

    if (error is ApiException) {
      throw error;
    }

    String errorMessage = error.toString();
    print('📋 Error message: $errorMessage');

    // Check for network connectivity issues
    if (errorMessage.contains('SocketException') ||
        errorMessage.contains('Failed host lookup') ||
        errorMessage.contains('NetworkImageLoadException')) {
      throw ApiException(
        message:
            'Network error: Unable to reach the server. Please check your internet connection and try again.',
      );
    }

    // Check for SSL/Certificate errors
    if (errorMessage.contains('HandshakeException') ||
        errorMessage.contains('CERTIFICATE_VERIFY_FAILED') ||
        errorMessage.contains('SSLV3_ALERT_HANDSHAKE_FAILURE') ||
        errorMessage.contains('X509')) {
      throw ApiException(
        message:
            'Connection error: SSL certificate issue. Please check your internet connection or contact support.',
      );
    }

    // Check for timeout errors
    if (errorMessage.contains('timeout') ||
        errorMessage.contains('TimeoutException')) {
      throw ApiException(
        message:
            'Server timeout: The server is not responding. Please check your internet connection and try again.',
      );
    }

    // Check for connection refused (server down)
    if (errorMessage.contains('Connection refused') ||
        errorMessage.contains('ECONNREFUSED')) {
      throw ApiException(
        message:
            'Server error: Unable to connect to the server. Please try again later.',
      );
    }

    // Check for DNS resolution errors
    if (errorMessage.contains('getaddrinfo failed') ||
        errorMessage.contains('No address associated')) {
      throw ApiException(
        message:
            'DNS error: Unable to resolve server address. Please check your internet connection.',
      );
    }

    throw ApiException(
      message:
          'Error: ${errorMessage.replaceAll('Exception: ', '').replaceAll('FormatException: ', '')}',
    );
  }

  // Mock data for development/testing when API is unavailable
  dynamic _getMockData(String endpoint) {
    if (endpoint.contains('reports/daily')) {
      return <String, dynamic>{
        'total_income': 150.00,
        'total_expense': 45.50,
        'balance': 104.50,
        'date': DateTime.now().toString().split(' ')[0],
      };
    } else if (endpoint.contains('reports/weekly')) {
      return <String, dynamic>{
        'total_income': 1050.00,
        'total_expense': 320.75,
        'balance': 729.25,
        'week': 'Week of ${DateTime.now().toString().split(' ')[0]}',
      };
    } else if (endpoint.contains('reports/monthly')) {
      return <String, dynamic>{
        'total_income': 5500.50,
        'total_expense': 2300.75,
        'balance': 3199.75,
      };
    } else if (endpoint.contains('categories')) {
      final allCategories = [
        {
          "id": 1,
          "name": "food",
          "type": "expense",
          "created_at": "2026-06-06T14:10:51.000000Z",
          "updated_at": "2026-06-06T14:10:51.000000Z"
        },
        {
          "id": 2,
          "name": "petrol",
          "type": "expense",
          "created_at": "2026-06-06T14:10:52.000000Z",
          "updated_at": "2026-06-06T14:10:52.000000Z"
        },
        {
          "id": 3,
          "name": "study",
          "type": "expense",
          "created_at": "2026-06-06T14:10:53.000000Z",
          "updated_at": "2026-06-06T14:10:53.000000Z"
        },
        {
          "id": 4,
          "name": "dating",
          "type": "expense",
          "created_at": "2026-06-06T14:10:54.000000Z",
          "updated_at": "2026-06-06T14:10:54.000000Z"
        },
        {
          "id": 5,
          "name": "salary",
          "type": "income",
          "created_at": "2026-06-06T14:10:56.000000Z",
          "updated_at": "2026-06-06T14:10:56.000000Z"
        },
        {
          "id": 6,
          "name": "gift",
          "type": "income",
          "created_at": "2026-06-06T14:10:57.000000Z",
          "updated_at": "2026-06-06T14:10:57.000000Z"
        },
        {
          "id": 7,
          "name": "teaching",
          "type": "income",
          "created_at": "2026-06-06T14:10:59.000000Z",
          "updated_at": "2026-06-06T14:10:59.000000Z"
        },
        {
          "id": 8,
          "name": "Medical Saving",
          "type": "saving",
          "saving_goal_amount": 5000,
          "saving_current_amount": 1200,
          "saving_target_date": "2026-12-31",
          "saving_frequency": "monthly",
          "saving_frequency_amount": 625,
          "saving_completion_percentage": 24,
          "saving_icon": "medical",
          "created_at": "2026-06-14T16:32:26.000000Z",
          "updated_at": "2026-06-14T16:36:07.000000Z"
        }
      ];

      if (endpoint.contains('type=income')) {
        return allCategories.where((c) => c['type'] == 'income').toList();
      } else if (endpoint.contains('type=expense')) {
        return allCategories.where((c) => c['type'] == 'expense').toList();
      } else if (endpoint.contains('type=saving')) {
        return allCategories.where((c) => c['type'] == 'saving').toList();
      }
      return allCategories;
    } else if (endpoint == 'incomes') {
      return [
        {
          'id': 1,
          'amount': '2500.00',
          'description': 'Monthly Salary',
          'date': DateTime.now().toString().split(' ')[0],
          'category': {'id': '1', 'name': 'Salary', 'type': 'income'},
        },
        {
          'id': 2,
          'amount': '500.50',
          'description': 'Freelance Project',
          'date': DateTime.now()
              .subtract(Duration(days: 2))
              .toString()
              .split(' ')[0],
          'category': {'id': '2', 'name': 'Freelance', 'type': 'income'},
        },
      ];
    } else if (endpoint == 'expenses') {
      return [
        {
          'id': 1,
          'amount': '150.00',
          'description': 'Groceries',
          'date': DateTime.now().toString().split(' ')[0],
          'category': {'id': '1', 'name': 'Food', 'type': 'expense'},
        },
        {
          'id': 2,
          'amount': '45.75',
          'description': 'Gas',
          'date': DateTime.now()
              .subtract(Duration(days: 1))
              .toString()
              .split(' ')[0],
          'category': {'id': '2', 'name': 'Transportation', 'type': 'expense'},
        },
      ];
    }
    return [];
  }
}
