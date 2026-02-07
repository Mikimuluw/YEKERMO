import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/clock_provider.dart';
import 'package:yekermo/core/city/city.dart';
import 'package:yekermo/core/config/app_config.dart';
import 'package:yekermo/core/storage/welcome_storage.dart';
import 'package:yekermo/core/time/stale_thresholds.dart';
import 'package:yekermo/core/storage/auth_storage.dart';
import 'package:yekermo/core/transport/fake_transport_client.dart';
import 'package:yekermo/core/transport/http_transport_client.dart';
import 'package:yekermo/core/transport/transport_client.dart';
import 'package:yekermo/data/datasources/dummy_meals_datasource.dart';
import 'package:yekermo/data/datasources/dummy_restaurant_datasource.dart';
import 'package:yekermo/data/datasources/dummy_search_datasource.dart';
import 'package:yekermo/data/repositories/address_repository.dart';
import 'package:yekermo/data/repositories/api_address_repository.dart';
import 'package:yekermo/data/repositories/api_auth_repository.dart';
import 'package:yekermo/data/repositories/api_me_repository.dart';
import 'package:yekermo/data/repositories/api_meals_repository.dart';
import 'package:yekermo/data/repositories/api_payments_repository.dart';
import 'package:yekermo/data/repositories/api_restaurant_repository.dart';
import 'package:yekermo/data/repositories/auth_repository.dart';
import 'package:yekermo/data/repositories/dummy_auth_repository.dart';
import 'package:yekermo/data/repositories/cart_repository.dart';
import 'package:yekermo/data/repositories/dummy_address_repository.dart';
import 'package:yekermo/data/repositories/dummy_cart_repository.dart';
import 'package:yekermo/data/repositories/dummy_meals_repository.dart';
import 'package:yekermo/data/repositories/dummy_orders_repository.dart';
import 'package:yekermo/data/repositories/dummy_payments_repository.dart';
import 'package:yekermo/data/repositories/dummy_restaurant_repository.dart';
import 'package:yekermo/data/repositories/dummy_search_repository.dart';
import 'package:yekermo/data/repositories/meals_repository.dart';
import 'package:yekermo/data/repositories/api_orders_repository.dart';
import 'package:yekermo/data/repositories/orders_repository.dart';
import 'package:yekermo/data/repositories/payments_repository.dart';
import 'package:yekermo/data/repositories/me_repository.dart';
import 'package:yekermo/data/repositories/restaurant_repository.dart';
import 'package:yekermo/data/repositories/search_repository.dart';
import 'package:yekermo/app/env.dart';
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

final appConfigProvider = Provider<AppConfig>((ref) {
  const AppConfig base = AppConfig();
  return AppConfig(
    useRealBackend: AppEnv.isRealEnvironment || base.useRealBackend,
    defaultCity: base.defaultCity,
    enablePersonalization: base.enablePersonalization,
    enableReorderPersonalization: base.enableReorderPersonalization,
    enableReorder: base.enableReorder,
    enableReferral: base.enableReferral,
  );
});

final cityContextProvider = Provider<CityContext>(
  (ref) => ref.watch(appConfigProvider).defaultCity,
);

final mealsRepositoryProvider = Provider<MealsRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.useRealBackend
      ? ApiMealsRepository(ref.watch(transportClientProvider))
      : DummyMealsRepository(ref.watch(dummyMealsDataSourceProvider));
});

final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.useRealBackend
      ? ApiRestaurantRepository(ref.watch(transportClientProvider))
      : DummyRestaurantRepository(ref.watch(dummyRestaurantDataSourceProvider));
});

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => DummySearchRepository(ref.watch(dummySearchDataSourceProvider)),
);

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => DummyCartRepository(),
);

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.useRealBackend
      ? ApiAddressRepository(ref.watch(transportClientProvider))
      : DummyAddressRepository();
});

final authStorageProvider = Provider<AuthStorage>(
  (ref) => SecureAuthStorage(),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  return config.useRealBackend
      ? ApiAuthRepository(
          transportClient: ref.watch(transportClientProvider),
          authStorage: ref.watch(authStorageProvider),
        )
      : const DummyAuthRepository();
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  return config.useRealBackend
      ? ApiOrdersRepository(ref.watch(transportClientProvider))
      : DummyOrdersRepository(clock: ref.watch(clockProvider));
});

final transportClientProvider = Provider<TransportClient>((ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  if (config.useRealBackend) {
    return HttpTransportClient(
      baseUrl: AppEnv.apiBaseUrl,
      getSession: () => ref.read(authStorageProvider).getSession(),
      cityContext: ref.watch(cityContextProvider),
    );
  }
  return FakeTransportClient(cityContext: ref.watch(cityContextProvider));
});

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  return config.useRealBackend
      ? ApiPaymentsRepository(ref.watch(transportClientProvider))
      : DummyPaymentsRepository();
});

final staleThresholdProvider = Provider<Duration>(
  (ref) => StaleThresholds.orderStatus,
);

final analyticsProvider = Provider<Analytics>((ref) => const DummyAnalytics());

final logProvider = Provider<AppLog>((ref) => const AppLog());

final currentUserEmailProvider = Provider<String>((_) => 'user@yekermo.app');

/// GET /me profile (name, email). Only used when useRealBackend; otherwise null.
final meProfileProvider = FutureProvider<MeProfile?>((ref) async {
  final config = ref.watch(appConfigProvider);
  if (!config.useRealBackend) return null;
  return ref.read(apiMeRepositoryProvider).fetchMe();
});

final apiMeRepositoryProvider = Provider<ApiMeRepository>(
  (ref) => ApiMeRepository(ref.watch(transportClientProvider)),
);

final welcomeStorageProvider = Provider<WelcomeStorage>(
  (ref) => LocalWelcomeStorage(),
);
