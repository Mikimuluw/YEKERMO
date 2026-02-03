import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/data/repositories/dummy_orders_repository.dart';
import 'package:yekermo/data/seed/yyc_restaurants.dart';
import 'package:yekermo/domain/cart.dart';
import 'package:yekermo/domain/fees.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/domain/payment_method.dart';

const FeeBreakdown _fees = FeeBreakdown(
  subtotal: 10,
  serviceFee: 2,
  deliveryFee: 3,
  tax: 1,
);

const Address _address = Address(
  id: 'addr-1',
  label: AddressLabel.home,
  line1: '215 Riverstone Ave',
  city: 'YYC',
);

const MenuItem _item = MenuItem(
  id: 'item-1',
  restaurantId: 'rest-pickup',
  categoryId: 'cat-1',
  name: 'Injera platter',
  description: 'Assorted house favorites served with injera.',
  price: 10.0,
  tags: [MenuItemTag.familySize],
);

const MenuItem _deliveryItem = MenuItem(
  id: 'item-2',
  restaurantId: 'rest-delivery',
  categoryId: 'cat-1',
  name: 'Injera platter',
  description: 'Assorted house favorites served with injera.',
  price: 10.0,
  tags: [MenuItemTag.familySize],
);

OrderDraft _draftFor(MenuItem item, FulfillmentMode mode) {
  return OrderDraft(
    items: [CartLineItem(item: item, quantity: 1)],
    fulfillmentMode: mode,
    address: _address,
    fees: _fees,
  );
}

void main() {
  test('pickup-only restaurants allow pickup but reject delivery', () async {
    final DummyOrdersRepository repo = DummyOrdersRepository(
      restaurantLookup: (id) {
        if (id == 'rest-pickup') {
          return const YYCRestaurantSeed(
            id: 'rest-pickup',
            name: 'Pickup Only',
            address: '123 Main St',
            serviceModes: [ServiceMode.pickup],
            hoursByWeekday: {
              1: '11:00-21:30',
              2: '11:00-21:30',
              3: '11:00-21:30',
              4: '11:00-21:30',
              5: '11:00-21:30',
              6: '11:00-21:30',
              7: '11:00-21:30',
            },
          );
        }
        return null;
      },
    );

    final Order pickupOrder = await repo.placeOrder(
      _draftFor(_item, FulfillmentMode.pickup),
      paymentMethod: const PaymentMethod(brand: 'Card', last4: '4242'),
    );
    expect(pickupOrder.id, isNotEmpty);

    expect(
      repo.placeOrder(
        _draftFor(_item, FulfillmentMode.delivery),
        paymentMethod: const PaymentMethod(brand: 'Card', last4: '4242'),
      ),
      throwsA(isA<Failure>()),
    );
  });

  test('delivery-enabled restaurants allow delivery', () async {
    final DummyOrdersRepository repo = DummyOrdersRepository(
      restaurantLookup: (id) {
        if (id == 'rest-delivery') {
          return const YYCRestaurantSeed(
            id: 'rest-delivery',
            name: 'Delivery',
            address: '789 River Rd',
            serviceModes: [ServiceMode.pickup, ServiceMode.delivery],
            hoursByWeekday: {
              1: '11:00-21:30',
              2: '11:00-21:30',
              3: '11:00-21:30',
              4: '11:00-21:30',
              5: '11:00-21:30',
              6: '11:00-21:30',
              7: '11:00-21:30',
            },
          );
        }
        return null;
      },
    );

    final Order deliveryOrder = await repo.placeOrder(
      _draftFor(_deliveryItem, FulfillmentMode.delivery),
      paymentMethod: const PaymentMethod(brand: 'Card', last4: '4242'),
    );
    expect(deliveryOrder.id, isNotEmpty);
  });
}
