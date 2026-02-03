import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/data/datasources/dummy_meals_datasource.dart';
import 'package:yekermo/data/repositories/dummy_meals_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/user_preferences.dart';

/// Guardrail: preferences must never filter results, only reorder.
/// Prevents accidental "oops we started hiding restaurants."
void main() {
  test('with prefs OFF and prefs ON discovery returns same list length', () async {
    const DummyMealsRepository repo = DummyMealsRepository(
      DummyMealsDataSource(),
    );

    final Result<List<Restaurant>> resultOff = await repo.fetchDiscovery(
      filters: null,
      query: null,
      preferences: UserPreferences.defaults,
    );
    final Result<List<Restaurant>> resultOn = await repo.fetchDiscovery(
      filters: null,
      query: null,
      preferences: const UserPreferences(
        pickupPreferred: true,
        fastingFriendly: true,
        vegetarianBias: true,
      ),
    );

    expect(resultOff, isA<Success<List<Restaurant>>>());
    expect(resultOn, isA<Success<List<Restaurant>>>());

    final List<Restaurant> listOff = (resultOff as Success<List<Restaurant>>).data;
    final List<Restaurant> listOn = (resultOn as Success<List<Restaurant>>).data;

    final int n = listOff.length;
    expect(listOn.length, n, reason: 'Preferences must not filter; list length must stay $n');

    final Set<String> idsOff = listOff.map((r) => r.id).toSet();
    final Set<String> idsOn = listOn.map((r) => r.id).toSet();
    expect(idsOn, idsOff, reason: 'Same restaurants must appear; only order may differ');
  });
}
