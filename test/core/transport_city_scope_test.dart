import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/core/transport/transport_client.dart';

class _RecordingTransportClient extends TransportClient {
  _RecordingTransportClient();

  Uri? lastUrl;

  @override
  Future<TransportResponse<T>> send<T>(TransportRequest request) async {
    lastUrl = request.url;
    return TransportResponse<T>(data: 'ok' as T, statusCode: 200);
  }
}

void main() {
  test('adds city param when none exists', () async {
    final _RecordingTransportClient client = _RecordingTransportClient();
    await client.request<String>(
      TransportRequest(
        method: 'GET',
        url: Uri(path: '/orders'),
      ),
    );
    expect(client.lastUrl, isNotNull);
    expect(client.lastUrl?.queryParameters['city'], 'calgary');
  });

  test('preserves existing query params', () async {
    final _RecordingTransportClient client = _RecordingTransportClient();
    await client.request<String>(
      TransportRequest(
        method: 'GET',
        url: Uri(path: '/orders', query: 'foo=bar'),
      ),
    );
    expect(client.lastUrl?.queryParameters['foo'], 'bar');
    expect(client.lastUrl?.queryParameters['city'], 'calgary');
  });

  test('does not duplicate city param', () async {
    final _RecordingTransportClient client = _RecordingTransportClient();
    await client.request<String>(
      TransportRequest(
        method: 'GET',
        url: Uri(path: '/orders', query: 'city=calgary'),
      ),
    );
    final Map<String, List<String>> params = client.lastUrl!.queryParametersAll;
    expect(params['city'], ['calgary']);
  });
}
