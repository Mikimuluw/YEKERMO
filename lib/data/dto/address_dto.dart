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

  Address toModel() => Address(
    id: id,
    label: label,
    line1: line1,
    city: city,
    neighborhood: neighborhood,
    notes: notes,
  );
}
