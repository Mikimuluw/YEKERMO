import 'package:yekermo/domain/models.dart';

class PreferenceDto {
  const PreferenceDto({
    required this.favoriteCuisines,
    required this.dietaryTags,
  });

  final List<String> favoriteCuisines;
  final List<String> dietaryTags;

  static PreferenceDto fromJson(Map<String, dynamic> json) => PreferenceDto(
        favoriteCuisines: (json['favoriteCuisines'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        dietaryTags: (json['dietaryTags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );

  Preference toModel() =>
      Preference(favoriteCuisines: favoriteCuisines, dietaryTags: dietaryTags);
}
