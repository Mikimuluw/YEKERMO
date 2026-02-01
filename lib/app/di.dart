import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/domain/home_feed.dart';
import 'package:yekermo/features/cart/cart_controller.dart';
import 'package:yekermo/features/home/home_controller.dart';
import 'package:yekermo/features/restaurant/restaurant_controller.dart';
import 'package:yekermo/features/search/search_controller.dart';
import 'package:yekermo/shared/state/screen_state.dart';

export 'package:yekermo/app/providers.dart';

final homeControllerProvider =
    NotifierProvider<HomeController, ScreenState<HomeFeed>>(
  HomeController.new,
);

final searchControllerProvider =
    NotifierProvider<SearchController, ScreenState<SearchVm>>(
  SearchController.new,
);

final restaurantControllerProvider =
    NotifierProvider<RestaurantController, ScreenState<RestaurantVm>>(
  RestaurantController.new,
);

final cartControllerProvider =
    NotifierProvider<CartController, ScreenState<CartVm>>(
  CartController.new,
);

final cartCountProvider = Provider<int>((ref) {
  final state = ref.watch(cartControllerProvider);
  return switch (state) {
    SuccessState<CartVm>(:final data) => data.totalCount,
    _ => 0,
  };
});
