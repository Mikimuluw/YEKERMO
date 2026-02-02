import 'package:yekermo/core/transport/transport_client.dart';

enum FakeTransportScenario {
  success,
  timeout,
  network,
  server,
}

class FakeTransportClient implements TransportClient {
  FakeTransportClient({
    this.scenario = FakeTransportScenario.success,
    this.response,
    this.error,
  });

  final FakeTransportScenario scenario;
  final TransportResponse<dynamic>? response;
  final TransportError? error;

  @override
  Future<TransportResponse<T>> request<T>(TransportRequest request) async {
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
        throw const TransportError(
          TransportErrorKind.timeout,
          'Fake timeout.',
        );
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
