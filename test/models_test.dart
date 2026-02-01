import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/domain/models.dart';

void main() {
  test('Address keeps notes from day one', () {
    const Address address = Address(
      id: 'addr-1',
      label: AddressLabel.home,
      line1: '215 Riverstone Ave',
      city: 'YYC',
      notes: 'Buzz 312',
    );

    expect(address.notes, 'Buzz 312');
  });

  test('Order scheduledTime defaults nullable', () {
    const Order order = Order(
      id: 'order-1',
      restaurantId: 'rest-1',
      items: [OrderItem(menuItemId: 'item-1', quantity: 1)],
      total: 21.75,
      scheduledTime: null,
    );

    expect(order.scheduledTime, isNull);
  });
}
