import 'package:yekermo/domain/models.dart';

abstract class AddressRepository {
  Future<Address?> getDefault();
  Future<void> save(Address address);
  Future<void> setDefault(Address address);
}
