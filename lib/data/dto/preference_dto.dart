import 'package:yekermo/domain/models.dart';

class PreferenceDto {
  const PreferenceDto({
    required this.favoriteCuisines,
    required this.dietaryTags,
  });

  final List<String> favoriteCuisines;
  final List<String> dietaryTags;

  Preference toModel() =>
      Preference(favoriteCuisines: favoriteCuisines, dietaryTags: dietaryTags);
}
