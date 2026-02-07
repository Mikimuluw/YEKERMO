import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/data/dto/order_event_dto.dart';
import 'package:yekermo/data/repositories/orders_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/fees.dart';
import 'package:yekermo/domain/failure.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/restaurant_menu.dart';
import 'package:yekermo/shared/state/screen_state.dart';


/// Query for order tracking. Override in route with orderId from path.
final orderTrackingQueryProvider = Provider<OrderTrackingQuery>(
  (_) => throw UnimplementedError('OrderTrackingQuery must be overridden.'),
);

final orderTrackingControllerProvider =
    NotifierProvider<
      OrderTrackingController,
      ScreenState<OrderTrackingUiModel>
    >(OrderTrackingController.new);

/// Stuck status threshold: show "We're checking on this" if status unchanged.
const Duration _stuckStatusThreshold = Duration(minutes: 12);

/// Poll interval while order is not in a terminal status.
const Duration _pollInterval = Duration(seconds: 10);

class OrderTrackingController
    extends Notifier<ScreenState<OrderTrackingUiModel>> {
  Timer? _pollTimer;
  OrderStatus? _lastStatus;
  DateTime? _lastStatusAt;
  int _requestId = 0;

  @override
  ScreenState<OrderTrackingUiModel> build() {
    ref.onDispose(_cancelPolling);
    state = ScreenState.loading();
    Future<void>.microtask(_load);
    return state;
  }

  Future<void> refresh() => _load();

  void _startPollingIfNeeded(Order order) {
    _pollTimer?.cancel();
    if (_isTerminal(order.status)) return;
    _pollTimer = Timer.periodic(_pollInterval, (_) => _load());
  }

  bool _isTerminal(OrderStatus status) => status.isTerminal;

  Future<void> _load() async {
    final int requestId = ++_requestId;
    final String orderId = ref.read(orderTrackingQueryProvider).orderId;
    try {
      final Order? order = await ref
          .read(ordersRepositoryProvider)
          .getOrder(orderId);
      if (requestId != _requestId) return;

      if (order == null) {
        state = ScreenState.empty();
        return;
      }

      final OrderEventsResponse eventsResponse = await ref
          .read(ordersRepositoryProvider)
          .getOrderEvents(orderId, limit: 50);
      if (requestId != _requestId) return;

      final Result<RestaurantMenu> menuResult = await ref
          .read(restaurantRepositoryProvider)
          .fetchRestaurantMenu(order.restaurantId);
      final Restaurant? restaurant = switch (menuResult) {
        Success<RestaurantMenu>(:final data) => data.restaurant,
        FailureResult<RestaurantMenu>() => null,
      };
      final Map<String, MenuItem> itemMap = switch (menuResult) {
        Success<RestaurantMenu>(:final data) => {
          for (final item in data.items) item.id: item,
        },
        FailureResult<RestaurantMenu>() => const {},
      };
      final List<OrderSummaryLine> summaryLines = order.items
          .map(
            (line) => OrderSummaryLine(
              name: itemMap[line.menuItemId]?.name ?? 'Item',
              quantity: line.quantity,
            ),
          )
          .toList();

      _lastStatusAt ??= DateTime.now();
      if (_lastStatus != order.status) {
        _lastStatus = order.status;
        _lastStatusAt = DateTime.now();
      }

      final bool isStuck =
          DateTime.now().difference(_lastStatusAt!) > _stuckStatusThreshold &&
          !_isTerminal(order.status);

      final OrderTrackingUiModel ui = OrderTrackingUiModel(
        orderId: order.id,
        orderIdShort: _shortId(order.id),
        statusCard: _statusCard(order, isStuck),
        steps: _steps(order),
        timelineEvents: eventsResponse.events,
        isCanceled: order.status == OrderStatus.cancelled,
        canCancel: order.status == OrderStatus.received,
        cancelResolutionNote: null,
        deliveryCard: _deliveryCard(order, restaurant),
        courierCard: null, // No courier in domain.
        orderSummary: OrderSummarySection(
          restaurantName: restaurant?.name ?? 'Restaurant',
          lines: summaryLines,
          feeBreakdown: order.feeBreakdown,
          paymentLast4: order.paymentMethod?.last4,
        ),
        primaryAction: _primaryAction(order),
        showBackToHome: false, // Set by route/caller if entered from checkout.
      );

      if (requestId != _requestId) return;
      state = ScreenState.success(ui);
      _startPollingIfNeeded(order);
    } catch (e) {
      if (requestId != _requestId) return;
      state = ScreenState.error(Failure(e.toString()));
    }
  }

  static String _shortId(String id) {
    if (id.length <= 8) return id;
    return '#${id.substring(id.length - 4)}';
  }

  StatusCardSection _statusCard(Order order, bool isStuck) {
    final String label = order.status.displayLabel(order.fulfillmentMode);
    final String subtext = _supportiveSubtext(order, isStuck);
    return StatusCardSection(
      statusLabel: label,
      supportiveSubtext: subtext,
      eta: null, // No ETA in domain.
      lastUpdated: order.placedAt ?? order.paidAt,
      isStuck: isStuck,
    );
  }

  String _supportiveSubtext(Order order, bool isStuck) {
    if (isStuck) return "We're checking on this. No action needed right now.";
    switch (order.status) {
      case OrderStatus.received:
        return 'The restaurant has received your order.';
      case OrderStatus.preparing:
        return 'Your order is being prepared.';
      case OrderStatus.ready:
        return order.fulfillmentMode == FulfillmentMode.pickup
            ? 'Ready for pickup.'
            : 'On the way.';
      case OrderStatus.completed:
        return 'Delivery complete.';
      case OrderStatus.cancelled:
        return 'This order was cancelled.';
      case OrderStatus.failed:
        return 'This order could not be completed.';
      case OrderStatus.refunded:
        return 'This order was refunded.';
    }
  }

  List<TrackingStep> _steps(Order order) {
    const List<String> labels = [
      'Order placed',
      'Restaurant confirmed',
      'Preparing',
      'Pickup',
      'On the way',
      'Delivered',
    ];
    int activeIndex = 0;
    switch (order.status) {
      case OrderStatus.received:
        activeIndex = 1;
        break;
      case OrderStatus.preparing:
        activeIndex = 2;
        break;
      case OrderStatus.ready:
        activeIndex = order.fulfillmentMode == FulfillmentMode.pickup ? 3 : 4;
        break;
      case OrderStatus.completed:
        activeIndex = 5;
        break;
      case OrderStatus.cancelled:
      case OrderStatus.failed:
      case OrderStatus.refunded:
        activeIndex = 0;
        break;
    }
    return List.generate(6, (i) {
      TrackingStepState s = TrackingStepState.pending;
      if (i < activeIndex) {
        s = TrackingStepState.completed;
      } else if (i == activeIndex) {
        s = TrackingStepState.active;
      }
      return TrackingStep(label: labels[i], state: s);
    });
  }

  DeliveryCardSection? _deliveryCard(Order order, Restaurant? restaurant) {
    if (order.fulfillmentMode == FulfillmentMode.pickup) {
      return DeliveryCardSection(
        addressLine: restaurant?.address ?? 'Pickup at restaurant',
        dropOffInstructions: null,
        contactless: false,
      );
    }
    final Address? a = order.address;
    if (a == null) {
      return const DeliveryCardSection(
        addressLine: null,
        dropOffInstructions: null,
        contactless: false,
      );
    }
    final String line = '${_addressLabel(a.label)} • ${a.line1}';
    return DeliveryCardSection(
      addressLine: line,
      dropOffInstructions: a.notes?.isNotEmpty == true ? a.notes : null,
      contactless: false,
    );
  }

  String _addressLabel(AddressLabel l) =>
      l == AddressLabel.home ? 'Home' : 'Work';

  TrackingPrimaryAction _primaryAction(Order order) {
    if (order.status == OrderStatus.cancelled) {
      return TrackingPrimaryAction.viewReceipt;
    }
    if (order.status == OrderStatus.received) {
      return TrackingPrimaryAction.cancel;
    }
    if (order.status.isTerminal) {
      return TrackingPrimaryAction.viewReceipt;
    }
    return TrackingPrimaryAction.getHelp;
  }

  Future<void> cancelOrder({String? reason}) async {
    final String orderId = ref.read(orderTrackingQueryProvider).orderId;
    try {
      await ref.read(ordersRepositoryProvider).cancelOrder(orderId, reason: reason);
      await _load();
    } catch (_) {
      await _load();
    }
  }

  void _cancelPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
}

// --- UI model (all sections pre-derived) ---

class OrderTrackingQuery {
  const OrderTrackingQuery({required this.orderId});
  final String orderId;
}

class OrderTrackingUiModel {
  const OrderTrackingUiModel({
    required this.orderId,
    required this.orderIdShort,
    required this.statusCard,
    required this.steps,
    this.timelineEvents = const [],
    required this.isCanceled,
    this.canCancel = false,
    this.cancelResolutionNote,
    this.deliveryCard,
    this.courierCard,
    required this.orderSummary,
    required this.primaryAction,
    required this.showBackToHome,
  });

  final String orderId;
  final String orderIdShort;
  final StatusCardSection statusCard;
  final List<TrackingStep> steps;
  final List<OrderEventDto> timelineEvents;
  final bool isCanceled;
  final bool canCancel;
  final String? cancelResolutionNote;
  final DeliveryCardSection? deliveryCard;
  final CourierCardSection? courierCard;
  final OrderSummarySection orderSummary;
  final TrackingPrimaryAction primaryAction;
  final bool showBackToHome;
}

class StatusCardSection {
  const StatusCardSection({
    required this.statusLabel,
    required this.supportiveSubtext,
    this.eta,
    this.lastUpdated,
    this.isStuck = false,
  });

  final String statusLabel;
  final String supportiveSubtext;
  final String? eta;
  final DateTime? lastUpdated;
  final bool isStuck;
}

enum TrackingStepState { completed, active, pending }

class TrackingStep {
  const TrackingStep({required this.label, required this.state});
  final String label;
  final TrackingStepState state;
}

class DeliveryCardSection {
  const DeliveryCardSection({
    this.addressLine,
    this.dropOffInstructions,
    this.contactless = false,
  });

  final String? addressLine;
  final String? dropOffInstructions;
  final bool contactless;
}

class CourierCardSection {
  const CourierCardSection({
    this.courierName,
    this.vehicleDetails,
    this.callNumber,
    this.hasMessage = false,
  });

  final String? courierName;
  final String? vehicleDetails;
  final String? callNumber;
  final bool hasMessage;
}

class OrderSummaryLine {
  const OrderSummaryLine({required this.name, required this.quantity});
  final String name;
  final int quantity;
}

class OrderSummarySection {
  const OrderSummarySection({
    required this.restaurantName,
    required this.lines,
    this.feeBreakdown,
    this.paymentLast4,
  });

  final String restaurantName;
  final List<OrderSummaryLine> lines;
  final FeeBreakdown? feeBreakdown;
  final String? paymentLast4;
}

enum TrackingPrimaryAction { getHelp, viewReceipt, cancel }
