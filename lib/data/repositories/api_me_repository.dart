import 'package:yekermo/core/transport/transport_client.dart';
import 'package:yekermo/data/dto/customer_dto.dart';
import 'package:yekermo/data/repositories/me_repository.dart';

/// Fetches GET /me and returns MeProfile. No abstract interface; used only when useRealBackend.
class ApiMeRepository {
  ApiMeRepository(this.transportClient);

  final TransportClient transportClient;

  Future<MeProfile?> fetchMe() async {
    try {
      final response = await transportClient.request<Map<String, dynamic>>(
        TransportRequest(
          method: 'GET',
          url: Uri(path: '/me'),
          timeout: const Duration(seconds: 12),
        ),
      );
      final data = response.data;
      final customer = CustomerDto.fromJson(data).toModel();
      final email = data['email'] as String? ?? '';
      return MeProfile(customer: customer, email: email);
    } on Exception {
      return null;
    }
  }
}
