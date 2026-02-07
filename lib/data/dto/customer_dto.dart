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

  static CustomerDto fromJson(Map<String, dynamic> json) => CustomerDto(
        id: json['id'] as String,
        name: json['name'] as String,
        primaryAddressId: json['primaryAddressId'] as String? ?? '',
        preference: json['preference'] != null
            ? PreferenceDto.fromJson(json['preference'] as Map<String, dynamic>)
            : const PreferenceDto(favoriteCuisines: [], dietaryTags: []),
      );

  Customer toModel() => Customer(
    id: id,
    name: name,
    primaryAddressId: primaryAddressId,
    preference: preference.toModel(),
  );
}
