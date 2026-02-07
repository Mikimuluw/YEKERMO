import 'package:yekermo/domain/models.dart';

class RestaurantDto {
  const RestaurantDto({
    required this.id,
    required this.name,
    required this.address,
    required this.tagline,
    required this.prepTimeBand,
    required this.serviceModes,
    required this.tags,
    required this.trustCopy,
    required this.dishNames,
    this.hoursByWeekday,
    this.rating,
    this.maxMinutes,
  });

  final String id;
  final String name;
  final String address;
  final String tagline;
  final PrepTimeBand prepTimeBand;
  final List<ServiceMode> serviceModes;
  final List<RestaurantTag> tags;
  final String trustCopy;
  final List<String> dishNames;
  final Map<int, String>? hoursByWeekday;
  final double? rating;
  final int? maxMinutes;

  static PrepTimeBand _prepTimeBand(String s) {
    switch (s) {
      case 'fast':
        return PrepTimeBand.fast;
      case 'slow':
        return PrepTimeBand.slow;
      default:
        return PrepTimeBand.standard;
    }
  }

  static List<ServiceMode> _serviceModes(List<dynamic>? list) {
    if (list == null) return [];
    return list.map((e) => e == 'pickup' ? ServiceMode.pickup : ServiceMode.delivery).toList();
  }

  static List<RestaurantTag> _tags(List<dynamic>? list) {
    if (list == null) return [];
    final out = <RestaurantTag>[];
    for (final e in list) {
      final s = e.toString();
      if (s == 'quickFilling') out.add(RestaurantTag.quickFilling);
      if (s == 'familySize') out.add(RestaurantTag.familySize);
      if (s == 'fastingFriendly') out.add(RestaurantTag.fastingFriendly);
      if (s == 'pickupFriendly') out.add(RestaurantTag.pickupFriendly);
    }
    return out;
  }

  static Map<int, String>? _hoursByWeekday(dynamic map) {
    if (map is! Map) return null;
    final result = <int, String>{};
    for (final e in map.entries) {
      final k = int.tryParse(e.key.toString());
      if (k != null && k >= 1 && k <= 7 && e.value != null) {
        result[k] = e.value.toString();
      }
    }
    return result.isEmpty ? null : result;
  }

  static RestaurantDto fromJson(Map<String, dynamic> json) {
    final list = json['serviceModes'] as List<dynamic>?;
    final tagsList = json['tags'] as List<dynamic>?;
    double? rating;
    if (json['rating'] != null) {
      rating = (json['rating'] is int) ? (json['rating'] as int).toDouble() : json['rating'] as double?;
    }
    int? maxMinutes = json['maxMinutes'] is int ? json['maxMinutes'] as int : null;
    return RestaurantDto(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      tagline: json['tagline'] as String,
      prepTimeBand: _prepTimeBand((json['prepTimeBand'] as String?) ?? 'standard'),
      serviceModes: _serviceModes(list),
      tags: _tags(tagsList),
      trustCopy: json['trustCopy'] as String,
      dishNames: (json['dishNames'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      hoursByWeekday: _hoursByWeekday(json['hoursByWeekday']),
      rating: rating,
      maxMinutes: maxMinutes,
    );
  }

  Restaurant toModel() => Restaurant(
    id: id,
    name: name,
    address: address,
    tagline: tagline,
    prepTimeBand: prepTimeBand,
    serviceModes: serviceModes,
    tags: tags,
    trustCopy: trustCopy,
    dishNames: dishNames,
    hoursByWeekday: hoursByWeekday,
    rating: rating,
    maxMinutes: maxMinutes,
  );
}
