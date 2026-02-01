import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/shared/state/screen_state.dart';

class AddressController extends Notifier<ScreenState<Address?>> {
  @override
  ScreenState<Address?> build() {
    return ScreenState.success(
      ref.read(addressRepositoryProvider).getDefault(),
    );
  }

  void save(Address address) {
    ref.read(addressRepositoryProvider).save(address);
    state = ScreenState.success(address);
  }
}
