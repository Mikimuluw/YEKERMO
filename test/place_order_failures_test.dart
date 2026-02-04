import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/core/time/clock.dart';
import 'package:yekermo/data/repositories/dummy_orders_repository.dart';
import 'package:yekermo/data/seed/yyc_restaurants.dart';
import 'package:yekermo/domain/cart.dart';
import 'package:yekermo/domain/fees.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/domain/order_failures.dart';
import 'package:yekermo/domain/payment_method.dart';
import 'helpers/fixed_clock.dart';

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
  restaurantId: 'rest-1',
  categoryId: 'cat-1',
  name: 'Injera platter',
  description: 'Assorted house favorites.',
  price: 10.0,
  tags: [MenuItemTag.familySize],
);

OrderDraft _draft(FulfillmentMode mode) => OrderDraft(
  items: [CartLineItem(item: _item, quantity: 1)],
  fulfillmentMode: mode,
  address: _address,
  fees: _fees,
);

const Map<int, String> _openHours = {
  1: '11:00-21:30',
  2: '11:00-21:30',
  3: '11:00-21:30',
  4: '11:00-21:30',
  5: '11:00-21:30',
  6: '11:00-21:30',
  7: '11:00-21:30',
};

void main() {
  group('PlaceOrderFailure typed failures', () {
    test('closed restaurant throws PlaceOrderException with restaurantClosed',
        () async {
      final Clock closedClock = FixedClock(DateTime(2026, 2, 2, 22, 0)); // 22:00
      final DummyOrdersRepository repo = DummyOrdersRepository(
        clock: closedClock,
        restaurantLookup: (id) => id == 'rest-1'
            ? const YYCRestaurantSeed(
                id: 'rest-1',
                name: 'Test',
                address: '123 Main',
                serviceModes: [ServiceMode.pickup, ServiceMode.delivery],
                hoursByWeekday: _openHours,
              )
            : null,
      );

      expect(
        () => repo.placeOrder(
          _draft(FulfillmentMode.pickup),
          paymentMethod: const PaymentMethod(brand: 'Card', last4: '4242'),
        ),
        throwsA(
          isA<PlaceOrderException>().having(
            (e) => e.failure.code,
            'code',
            PlaceOrderFailureCode.restaurantClosed,
          ),
        ),
      );
    });

    test('unsupported service mode throws serviceModeUnavailable', () async {
      final Clock openClock = FixedClock(DateTime(2026, 2, 2, 12, 0));
      final DummyOrdersRepository repo = DummyOrdersRepository(
        clock: openClock,
        restaurantLookup: (id) => id == 'rest-1'
            ? const YYCRestaurantSeed(
                id: 'rest-1',
                name: 'Pickup Only',
                address: '123 Main',
                serviceModes: [ServiceMode.pickup],
                hoursByWeekday: _openHours,
              )
            : null,
      );

      expect(
        () => repo.placeOrder(
          _draft(FulfillmentMode.delivery),
          paymentMethod: const PaymentMethod(brand: 'Card', last4: '4242'),
        ),
        throwsA(
          isA<PlaceOrderException>().having(
            (e) => e.failure.code,
            'code',
            PlaceOrderFailureCode.serviceModeUnavailable,
          ),
        ),
      );
    });
  });
}
