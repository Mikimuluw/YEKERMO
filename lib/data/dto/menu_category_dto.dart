import 'package:yekermo/domain/models.dart';

class MenuCategoryDto {
  const MenuCategoryDto({required this.id, required this.title});

  final String id;
  final String title;

  static MenuCategoryDto fromJson(Map<String, dynamic> json) => MenuCategoryDto(
        id: json['id'] as String,
        title: json['title'] as String,
      );

  MenuCategory toModel() => MenuCategory(id: id, title: title);
}
