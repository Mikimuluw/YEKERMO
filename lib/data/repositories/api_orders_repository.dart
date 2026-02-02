import 'package:yekermo/core/transport/transport_client.dart';
import 'package:yekermo/data/repositories/orders_repository.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/domain/payment_method.dart';

class ApiOrdersRepository implements OrdersRepository {
  ApiOrdersRepository(this.transportClient);

  final TransportClient transportClient;

  @override
  Future<List<Order>> getOrders() async {
    try {
      final TransportResponse<List<Order>> response = await transportClient
          .request<List<Order>>(
            TransportRequest(
              method: 'GET',
              url: Uri(path: '/orders'),
              timeout: const Duration(seconds: 12),
            ),
          );
      return response.data;
    } on TransportError {
      return const [];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<Order?> getOrder(String id) async {
    try {
      final TransportResponse<Order?> response = await transportClient
          .request<Order?>(
            TransportRequest(
              method: 'GET',
              url: Uri(path: '/orders/$id'),
              timeout: const Duration(seconds: 12),
            ),
          );
      return response.data;
    } on TransportError {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Order?> getLatestOrder() async {
    try {
      final TransportResponse<Order?> response = await transportClient
          .request<Order?>(
            TransportRequest(
              method: 'GET',
              url: Uri(path: '/orders/latest'),
              timeout: const Duration(seconds: 12),
            ),
          );
      return response.data;
    } on TransportError {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Order> placeOrder(
    OrderDraft draft, {
    required PaymentMethod paymentMethod,
  }) async {
    throw UnimplementedError();
  }
}
