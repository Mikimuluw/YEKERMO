import 'package:yekermo/data/repositories/address_repository.dart';
import 'package:yekermo/domain/models.dart';

class DummyAddressRepository implements AddressRepository {
  Address? _default;

  @override
  Address? getDefault() => _default;

  @override
  void save(Address address) {
    _default = address;
  }

  @override
  void setDefault(Address address) {
    _default = address;
  }
}
