import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/clock_provider.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/core/time/restaurant_hours.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/home_feed.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/restaurant_menu.dart';
import 'package:yekermo/shared/state/screen_state.dart';

final restaurantQueryProvider = Provider<RestaurantQuery>(
  (_) => throw UnimplementedError('RestaurantQuery must be overridden.'),
);

class RestaurantController extends Notifier<ScreenState<RestaurantVm>> {
  int _requestId = 0;

  @override
  ScreenState<RestaurantVm> build() {
    state = ScreenState.loading();
    Future<void>.microtask(_loadLatest);
    return state;
  }

  Future<void> refresh() => _loadLatest();

  Future<void> _loadLatest() async {
    final int requestId = ++_requestId;
    final RestaurantQuery query = ref.read(restaurantQueryProvider);

    final Result<RestaurantMenu> menuResult = await ref
        .read(restaurantRepositoryProvider)
        .fetchRestaurantMenu(query.restaurantId);
    if (requestId != _requestId) return;
    if (menuResult case FailureResult<RestaurantMenu>(:final failure)) {
      state = ScreenState.error(failure);
      return;
    }

    final Result<HomeFeed> homeResult = await ref
        .read(mealsRepositoryProvider)
        .fetchHomeFeed();
    if (requestId != _requestId) return;
    if (homeResult case FailureResult<HomeFeed>(:final failure)) {
      state = ScreenState.error(failure);
      return;
    }

    final RestaurantMenu menu = (menuResult as Success<RestaurantMenu>).data;
    final HomeFeed home = (homeResult as Success<HomeFeed>).data;

    final Map<String, int> pastQuantities = _pastQuantities(
      home.pastOrders,
      query.restaurantId,
    );
    final List<MenuItem> forYouItems = _forYouItems(
      menu.items,
      pastQuantities,
      query.intent,
    );

    final _HeaderCopy header = _headerCopy(
      intent: query.intent,
      hasOrders: home.hasOrders,
      hasRestaurantOrders: pastQuantities.isNotEmpty,
    );

    final String? unavailabilityReason = _unavailabilityReason(
      menu.restaurant,
      ref.read(clockProvider).now(),
    );

    state = ScreenState.success(
      RestaurantVm(
        restaurant: menu.restaurant,
        categories: menu.categories,
        items: menu.items,
        forYouItems: forYouItems,
        headerTitle: header.title,
        headerSubtitle: header.subtitle,
        pastOrderQuantities: pastQuantities,
        intent: query.intent,
        unavailabilityReason: unavailabilityReason,
      ),
    );
  }

  /// Plain-language reason when restaurant is closed or a service mode is unavailable (PRD §4.1).
  String? _unavailabilityReason(Restaurant restaurant, DateTime now) {
    final Map<int, String>? hours = restaurant.hoursByWeekday;
    if (hours != null) {
      final bool open = isOpenNow(hours, now);
      if (!open) {
        return 'This restaurant is closed right now.';
      }
      if (restaurant.serviceModes.length == 1) {
        if (restaurant.serviceModes.contains(ServiceMode.pickup)) {
          return 'Delivery unavailable right now.';
        }
        if (restaurant.serviceModes.contains(ServiceMode.delivery)) {
          return 'Pickup unavailable right now.';
        }
      }
    }
    return null;
  }

  Map<String, int> _pastQuantities(List<Order> orders, String restaurantId) {
    final Map<String, int> quantities = {};
    for (final Order order in orders) {
      if (order.restaurantId != restaurantId) continue;
      for (final OrderItem item in order.items) {
        quantities[item.menuItemId] =
            (quantities[item.menuItemId] ?? 0) + item.quantity;
      }
    }
    return quantities;
  }

  List<MenuItem> _forYouItems(
    List<MenuItem> items,
    Map<String, int> pastQuantities,
    String? intent,
  ) {
    if (pastQuantities.isNotEmpty) {
      return items
          .where((item) => pastQuantities.containsKey(item.id))
          .toList();
    }

    final MenuItemTag? tag = _tagFromIntent(intent);
    if (tag != null) {
      return items.where((item) => item.tags.contains(tag)).toList();
    }

    return const [];
  }

  _HeaderCopy _headerCopy({
    required String? intent,
    required bool hasOrders,
    required bool hasRestaurantOrders,
  }) {
    final String? intentLabel = _intentLabel(intent);
    if (intentLabel != null) {
      return _HeaderCopy(
        title: 'Looking for $intentLabel',
        subtitle: 'Here are a few options from the menu.',
      );
    }
    if (hasRestaurantOrders) {
      return const _HeaderCopy(
        title: 'Welcome back',
        subtitle: 'Your usuals are ready below.',
      );
    }
    if (hasOrders) {
      return const _HeaderCopy(
        title: 'Welcome back',
        subtitle: 'Take another look at this menu.',
      );
    }
    return const _HeaderCopy(
      title: 'Welcome',
      subtitle: 'Take your time with the menu.',
    );
  }

  MenuItemTag? _tagFromIntent(String? intent) {
    switch (intent) {
      case 'quick_filling':
        return MenuItemTag.quickFilling;
      case 'family_size':
        return MenuItemTag.familySize;
      case 'fasting_friendly':
        return MenuItemTag.fastingFriendly;
      default:
        return null;
    }
  }

  String? _intentLabel(String? intent) {
    switch (intent) {
      case 'quick_filling':
        return 'quick & filling';
      case 'family_size':
        return 'family size';
      case 'fasting_friendly':
        return 'fasting friendly';
      default:
        return null;
    }
  }
}

class RestaurantQuery {
  const RestaurantQuery({required this.restaurantId, this.intent});

  final String restaurantId;
  final String? intent;
}

class RestaurantVm {
  const RestaurantVm({
    required this.restaurant,
    required this.categories,
    required this.items,
    required this.forYouItems,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.pastOrderQuantities,
    required this.intent,
    this.unavailabilityReason,
  });

  final Restaurant restaurant;
  final List<MenuCategory> categories;
  final List<MenuItem> items;
  final List<MenuItem> forYouItems;
  final String headerTitle;
  final String headerSubtitle;
  final Map<String, int> pastOrderQuantities;
  final String? intent;
  /// Plain-language reason when closed or a service mode is unavailable (PRD §4.1). Shown on restaurant detail.
  final String? unavailabilityReason;
}

class _HeaderCopy {
  const _HeaderCopy({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}
