enum TransportErrorKind {
  network,
  timeout,
  server,
  unknown,
}

class TransportError implements Exception {
  const TransportError(
    this.kind,
    this.message, {
    this.statusCode,
  });

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
  Future<TransportResponse<T>> request<T>(TransportRequest request);
}
