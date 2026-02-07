import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/home_feed.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/observability/app_log.dart';
import 'package:yekermo/shared/state/screen_state.dart';

class HomeController extends Notifier<ScreenState<HomeFeed>> {
  @override
  ScreenState<HomeFeed> build() {
    load();
    return ScreenState.initial();
  }

  Future<void> load() async {
    state = ScreenState.loading();
    final Result<HomeFeed> result = await ref
        .read(mealsRepositoryProvider)
        .fetchHomeFeed();
    final AppLog log = ref.read(logProvider);
    switch (result) {
      case Success<HomeFeed>(:final data):
        final List<Order> orders = await ref
            .read(ordersRepositoryProvider)
            .getOrders();
        final HomeFeed updatedFeed = HomeFeed(
          customer: data.customer,
          primaryAddress: data.primaryAddress,
          pastOrders: orders,
          trustedRestaurants: data.trustedRestaurants,
          allRestaurants: data.allRestaurants,
        );
        if (updatedFeed.trustedRestaurants.isEmpty &&
            updatedFeed.allRestaurants.isEmpty &&
            updatedFeed.pastOrders.isEmpty) {
          state = ScreenState.empty('No recommendations right now.');
        } else {
          state = ScreenState.success(updatedFeed);
        }
      case FailureResult<HomeFeed>(:final failure):
        log.e('Home feed failed', failure);
        state = ScreenState.error(failure);
    }
  }
}
