import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/data/datasources/dummy_meals_datasource.dart';
import 'package:yekermo/data/datasources/dummy_restaurant_datasource.dart';
import 'package:yekermo/data/datasources/dummy_search_datasource.dart';
import 'package:yekermo/data/repositories/address_repository.dart';
import 'package:yekermo/data/repositories/cart_repository.dart';
import 'package:yekermo/data/repositories/dummy_address_repository.dart';
import 'package:yekermo/data/repositories/dummy_cart_repository.dart';
import 'package:yekermo/data/repositories/dummy_meals_repository.dart';
import 'package:yekermo/data/repositories/dummy_orders_repository.dart';
import 'package:yekermo/data/repositories/dummy_payments_repository.dart';
import 'package:yekermo/data/repositories/dummy_restaurant_repository.dart';
import 'package:yekermo/data/repositories/dummy_search_repository.dart';
import 'package:yekermo/data/repositories/meals_repository.dart';
import 'package:yekermo/data/repositories/orders_repository.dart';
import 'package:yekermo/data/repositories/payments_repository.dart';
import 'package:yekermo/data/repositories/restaurant_repository.dart';
import 'package:yekermo/data/repositories/search_repository.dart';
import 'package:yekermo/observability/analytics.dart';
import 'package:yekermo/observability/app_log.dart';

final dummyMealsDataSourceProvider = Provider<DummyMealsDataSource>(
  (ref) => const DummyMealsDataSource(),
);

final dummySearchDataSourceProvider = Provider<DummySearchDataSource>(
  (ref) => const DummySearchDataSource(),
);

final dummyRestaurantDataSourceProvider = Provider<DummyRestaurantDataSource>(
  (ref) => const DummyRestaurantDataSource(),
);

final mealsRepositoryProvider = Provider<MealsRepository>(
  (ref) => DummyMealsRepository(ref.watch(dummyMealsDataSourceProvider)),
);

final restaurantRepositoryProvider = Provider<RestaurantRepository>(
  (ref) =>
      DummyRestaurantRepository(ref.watch(dummyRestaurantDataSourceProvider)),
);

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => DummySearchRepository(ref.watch(dummySearchDataSourceProvider)),
);

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => DummyCartRepository(),
);

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => DummyAddressRepository(),
);

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => DummyOrdersRepository(),
);

final paymentsRepositoryProvider = Provider<PaymentsRepository>(
  (ref) => DummyPaymentsRepository(),
);

final analyticsProvider = Provider<Analytics>((ref) => const DummyAnalytics());

final logProvider = Provider<AppLog>((ref) => const AppLog());
