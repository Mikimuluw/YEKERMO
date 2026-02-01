import 'package:yekermo/domain/models.dart';

class RestaurantDto {
  const RestaurantDto({
    required this.id,
    required this.name,
    required this.tagline,
    required this.prepTimeBand,
    required this.serviceModes,
    required this.tags,
    required this.trustCopy,
    required this.dishNames,
  });

  final String id;
  final String name;
  final String tagline;
  final PrepTimeBand prepTimeBand;
  final List<ServiceMode> serviceModes;
  final List<RestaurantTag> tags;
  final String trustCopy;
  final List<String> dishNames;

  Restaurant toModel() => Restaurant(
    id: id,
    name: name,
    tagline: tagline,
    prepTimeBand: prepTimeBand,
    serviceModes: serviceModes,
    tags: tags,
    trustCopy: trustCopy,
    dishNames: dishNames,
  );
}
