import 'package:yekermo/data/dto/preference_dto.dart';
import 'package:yekermo/domain/models.dart';

class CustomerDto {
  const CustomerDto({
    required this.id,
    required this.name,
    required this.primaryAddressId,
    required this.preference,
  });

  final String id;
  final String name;
  final String primaryAddressId;
  final PreferenceDto preference;

  Customer toModel() => Customer(
        id: id,
        name: name,
        primaryAddressId: primaryAddressId,
        preference: preference.toModel(),
      );
}
