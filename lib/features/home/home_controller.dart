import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/home_feed.dart';
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
    final Result<HomeFeed> result =
        await ref.read(mealsRepositoryProvider).fetchHomeFeed();
    final AppLog log = ref.read(logProvider);
    switch (result) {
      case Success<HomeFeed>(:final data):
        if (data.trustedRestaurants.isEmpty &&
            data.allRestaurants.isEmpty &&
            data.pastOrders.isEmpty) {
          state = ScreenState.empty('Nothing to show yet.');
        } else {
          state = ScreenState.success(data);
        }
      case FailureResult<HomeFeed>(:final failure):
        log.e('Home feed failed', failure);
        state = ScreenState.error(failure);
    }
  }
}
