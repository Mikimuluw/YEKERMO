import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/core/ranking/reorder_personalization.dart';

void main() {
  group('canPersonalizeReorder', () {
    test('count 0 returns false', () {
      expect(canPersonalizeReorder(0), isFalse);
    });
    test('count 1 returns false', () {
      expect(canPersonalizeReorder(1), isFalse);
    });
    test('count 2 returns true', () {
      expect(canPersonalizeReorder(2), isTrue);
    });
    test('count 3 returns true', () {
      expect(canPersonalizeReorder(3), isTrue);
    });
  });

  group('reorderScore', () {
    test('count 0 returns 0', () => expect(reorderScore(0), 0));
    test('count 1 returns 0', () => expect(reorderScore(1), 0));
    test('count 2 returns 1', () => expect(reorderScore(2), 1));
    test('count 3 returns 1', () => expect(reorderScore(3), 1));
  });
}
