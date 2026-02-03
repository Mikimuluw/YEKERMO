import 'package:yekermo/core/transport/transport_client.dart';

enum FakeTransportScenario { success, timeout, network, server }

class FakeTransportClient extends TransportClient {
  FakeTransportClient({
    super.cityContext,
    this.scenario = FakeTransportScenario.success,
    this.response,
    this.error,
    this.responses = const {},
    this.errors = const {},
  });

  final FakeTransportScenario scenario;
  final TransportResponse<dynamic>? response;
  final TransportError? error;
  final Map<String, TransportResponse<dynamic>> responses;
  final Map<String, TransportError> errors;

  @override
  Future<TransportResponse<T>> send<T>(TransportRequest request) async {
    final String path = request.url.path;
    final TransportResponse<dynamic>? matched = responses[path];
    if (matched != null) {
      return TransportResponse<T>(
        data: matched.data as T,
        statusCode: matched.statusCode,
        headers: matched.headers,
      );
    }
    final TransportError? pathError = errors[path];
    if (pathError != null) {
      throw pathError;
    }
    switch (scenario) {
      case FakeTransportScenario.success:
        final TransportResponse<dynamic>? seeded = response;
        if (seeded == null) {
          throw const TransportError(
            TransportErrorKind.unknown,
            'Fake transport missing response.',
          );
        }
        return TransportResponse<T>(
          data: seeded.data as T,
          statusCode: seeded.statusCode,
          headers: seeded.headers,
        );
      case FakeTransportScenario.timeout:
        throw const TransportError(TransportErrorKind.timeout, 'Fake timeout.');
      case FakeTransportScenario.network:
        throw const TransportError(
          TransportErrorKind.network,
          'Fake network error.',
        );
      case FakeTransportScenario.server:
        throw const TransportError(
          TransportErrorKind.server,
          'Fake server error.',
          statusCode: 500,
        );
    }
  }
}
