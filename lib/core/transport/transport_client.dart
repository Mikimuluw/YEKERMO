import 'package:yekermo/core/city/city.dart';

enum TransportErrorKind { network, timeout, server, unknown }

class TransportError implements Exception {
  const TransportError(this.kind, this.message, {this.statusCode});

  final TransportErrorKind kind;
  final String message;
  final int? statusCode;

  @override
  String toString() => 'TransportError(kind: $kind, message: $message)';
}

class TransportRequest {
  const TransportRequest({
    required this.method,
    required this.url,
    this.headers = const {},
    this.body,
    this.timeout,
  });

  final String method;
  final Uri url;
  final Map<String, String> headers;
  final Object? body;
  final Duration? timeout;

  TransportRequest copyWith({
    Uri? url,
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) {
    return TransportRequest(
      method: method,
      url: url ?? this.url,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      timeout: timeout ?? this.timeout,
    );
  }
}

class TransportResponse<T> {
  const TransportResponse({
    required this.data,
    required this.statusCode,
    this.headers = const {},
  });

  final T data;
  final int statusCode;
  final Map<String, String> headers;
}

abstract class TransportClient {
  TransportClient({CityContext? cityContext})
    : cityContext = cityContext ?? const CityContext(CityId.calgary);

  final CityContext cityContext;

  Future<TransportResponse<T>> send<T>(TransportRequest request);

  Future<TransportResponse<T>> request<T>(TransportRequest request) {
    final Uri scopedUrl = withCity(request.url, cityContext);
    return send(request.copyWith(url: scopedUrl));
  }
}

Uri withCity(Uri uri, CityContext context) {
  if (uri.queryParameters.containsKey('city')) return uri;
  final Map<String, String> params = Map<String, String>.from(
    uri.queryParameters,
  );
  params['city'] = context.cityId.slug;
  return uri.replace(queryParameters: params);
}
