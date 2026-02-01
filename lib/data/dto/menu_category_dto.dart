import 'package:yekermo/domain/models.dart';

class MenuCategoryDto {
  const MenuCategoryDto({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  MenuCategory toModel() => MenuCategory(
        id: id,
        title: title,
      );
}
