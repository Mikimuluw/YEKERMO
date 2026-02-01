import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/models.dart';

abstract class SearchRepository {
  Future<Result<List<Restaurant>>> search({
    String? query,
    DiscoveryFilters? filters,
  });
}
