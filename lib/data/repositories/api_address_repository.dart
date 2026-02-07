import 'package:yekermo/core/transport/transport_client.dart';
import 'package:yekermo/data/dto/address_dto.dart';
import 'package:yekermo/data/repositories/address_repository.dart';
import 'package:yekermo/domain/models.dart';

class ApiAddressRepository implements AddressRepository {
  ApiAddressRepository(this.transportClient);

  final TransportClient transportClient;

  @override
  Future<Address?> getDefault() async {
    try {
      final response = await transportClient.request<Map<String, dynamic>>(
        TransportRequest(
          method: 'GET',
          url: Uri(path: '/me'),
          timeout: const Duration(seconds: 12),
        ),
      );
      final data = response.data;
      final primaryAddressId = data['primaryAddressId'] as String?;
      final addressesList = data['addresses'] as List<dynamic>? ?? [];
      if (addressesList.isEmpty) return null;
      final addresses = addressesList
          .map((e) => AddressDto.fromJson(e as Map<String, dynamic>).toModel())
          .toList();
      if (primaryAddressId != null && primaryAddressId.isNotEmpty) {
        final match = addresses.where((a) => a.id == primaryAddressId);
        if (match.isNotEmpty) return match.first;
      }
      return addresses.first;
    } on TransportError catch (_) {
      return null;
    } on Exception {
      return null;
    }
  }

  @override
  Future<void> save(Address address) async {
    final body = <String, dynamic>{
      'label': address.label.name,
      'line1': address.line1,
      'city': address.city,
    };
    if (address.neighborhood != null) body['neighborhood'] = address.neighborhood;
    if (address.notes != null) body['notes'] = address.notes;
    await transportClient.request<dynamic>(
      TransportRequest(
        method: 'POST',
        url: Uri(path: '/me/addresses'),
        body: body,
        timeout: const Duration(seconds: 12),
      ),
    );
  }

  @override
  Future<void> setDefault(Address address) async {
    // Backend has no PATCH primary; treat as save for compatibility.
    await save(address);
  }
}
