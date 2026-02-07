import 'package:yekermo/domain/models.dart';

class AddressDto {
  const AddressDto({
    required this.id,
    required this.label,
    required this.line1,
    required this.city,
    this.neighborhood,
    this.notes,
  });

  final String id;
  final AddressLabel label;
  final String line1;
  final String city;
  final String? neighborhood;
  final String? notes;

  static AddressLabel _labelFromString(String s) {
    switch (s.toLowerCase()) {
      case 'work':
        return AddressLabel.work;
      default:
        return AddressLabel.home;
    }
  }

  static AddressDto fromJson(Map<String, dynamic> json) => AddressDto(
        id: json['id'] as String,
        label: _labelFromString(json['label'] as String? ?? 'home'),
        line1: json['line1'] as String,
        city: json['city'] as String,
        neighborhood: json['neighborhood'] as String?,
        notes: json['notes'] as String?,
      );

  Address toModel() => Address(
    id: id,
    label: label,
    line1: line1,
    city: city,
    neighborhood: neighborhood,
    notes: notes,
  );
}
