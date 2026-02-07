import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:http/http.dart' as http;
import 'package:yekermo/core/transport/transport_client.dart';
import 'package:yekermo/domain/auth_session.dart';

/// Real HTTP transport client using package:http.
/// Injects auth token when session exists; maps HTTP errors to TransportError.
class HttpTransportClient extends TransportClient {
  HttpTransportClient({
    required this.baseUrl,
    required this.getSession,
    super.cityContext,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final Future<AuthSession?> Function() getSession;
  final http.Client _httpClient;

  @override
  Future<TransportResponse<T>> send<T>(TransportRequest request) async {
    try {
      // Build full URL (normalize: no trailing slash on base; path without leading slash for Uri)
      final base = baseUrl.trim().replaceAll(RegExp(r'/$'), '');
      final path = request.url.path.startsWith('/')
          ? request.url.path.substring(1)
          : request.url.path;
      final Uri fullUrl = Uri.parse(base).replace(
        path: path,
        queryParameters: {
          ...request.url.queryParameters,
        },
      );

      // Get auth session and attach token if exists
      final session = await getSession();
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        ...request.headers,
      };
      if (session != null) {
        headers['Authorization'] = 'Bearer ${session.token}';
      }

      // Make request
      final http.Response response;
      switch (request.method.toUpperCase()) {
        case 'GET':
          response = await _httpClient
              .get(fullUrl, headers: headers)
              .timeout(request.timeout ?? const Duration(seconds: 30));
          break;
        case 'POST':
          response = await _httpClient
              .post(
                fullUrl,
                headers: headers,
                body: request.body != null ? jsonEncode(request.body) : null,
              )
              .timeout(request.timeout ?? const Duration(seconds: 30));
          break;
        case 'PUT':
          response = await _httpClient
              .put(
                fullUrl,
                headers: headers,
                body: request.body != null ? jsonEncode(request.body) : null,
              )
              .timeout(request.timeout ?? const Duration(seconds: 30));
          break;
        case 'DELETE':
          response = await _httpClient
              .delete(fullUrl, headers: headers)
              .timeout(request.timeout ?? const Duration(seconds: 30));
          break;
        default:
          throw TransportError(
            TransportErrorKind.unknown,
            'Unsupported HTTP method: ${request.method}',
          );
      }

      // Check status code
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success - parse JSON response
        final dynamic data = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : null;

        return TransportResponse<T>(
          data: data as T,
          statusCode: response.statusCode,
          headers: response.headers,
        );
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // Client error
        throw TransportError(
          TransportErrorKind.server,
          'Client error: ${response.statusCode} ${response.body}',
          statusCode: response.statusCode,
        );
      } else {
        // Server error
        throw TransportError(
          TransportErrorKind.server,
          'Server error: ${response.statusCode} ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw const TransportError(
        TransportErrorKind.timeout,
        'Request timed out',
      );
    } on io.SocketException catch (e) {
      throw TransportError(
        TransportErrorKind.network,
        'Network error: ${e.message}',
      );
    } on TransportError {
      rethrow;
    } catch (e) {
      throw TransportError(
        TransportErrorKind.unknown,
        'Unknown error: $e',
      );
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
