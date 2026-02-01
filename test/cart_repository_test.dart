import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/data/repositories/cart_repository.dart';
import 'package:yekermo/data/repositories/dummy_cart_repository.dart';
import 'package:yekermo/domain/models.dart';

void main() {
  test('cart repository updates quantities', () {
    final CartRepository repo = DummyCartRepository();
    const MenuItem item = MenuItem(
      id: 'item-1',
      restaurantId: 'rest-1',
      categoryId: 'cat-1',
      name: 'Misir Comfort Bowl',
      description: 'Red lentils, warm spices.',
      price: 14.25,
      tags: [MenuItemTag.quickFilling],
    );

    repo.addItem(item, 2);
    expect(repo.totalCount, 2);

    repo.updateQuantity(item.id, 1);
    expect(repo.totalCount, 1);

    repo.removeItem(item.id);
    expect(repo.totalCount, 0);
    expect(repo.getItems(), isEmpty);
  });
}
