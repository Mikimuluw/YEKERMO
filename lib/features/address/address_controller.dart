import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/shared/state/screen_state.dart';

class AddressController extends AsyncNotifier<ScreenState<Address?>> {
  @override
  Future<ScreenState<Address?>> build() async {
    final address = await ref.read(addressRepositoryProvider).getDefault();
    return ScreenState.success(address);
  }

  Future<void> save(Address address) async {
    await ref.read(addressRepositoryProvider).save(address);
    state = AsyncData(ScreenState.success(address));
  }
}
