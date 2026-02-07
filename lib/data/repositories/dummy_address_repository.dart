import 'package:yekermo/data/repositories/address_repository.dart';
import 'package:yekermo/domain/models.dart';

class DummyAddressRepository implements AddressRepository {
  Address? _default;

  @override
  Future<Address?> getDefault() async => _default;

  @override
  Future<void> save(Address address) async {
    _default = address;
  }

  @override
  Future<void> setDefault(Address address) async {
    _default = address;
  }
}
