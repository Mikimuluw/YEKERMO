import 'package:yekermo/domain/models.dart';

abstract class AddressRepository {
  Address? getDefault();
  void setDefault(Address address);
  void save(Address address);
}
