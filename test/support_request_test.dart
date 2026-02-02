import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/domain/support.dart';
import 'package:yekermo/domain/support_handoff.dart';
import 'package:yekermo/features/orders/support_request_screen.dart';

class _SpySupportHandoff implements SupportHandoff {
  SupportRequestDraft? lastDraft;
  int calls = 0;

  @override
  Future<void> submit(SupportRequestDraft draft) async {
    calls += 1;
    lastDraft = draft;
  }
}

void main() {
  testWidgets('Support payload includes required fields', (tester) async {
    final _SpySupportHandoff handoff = _SpySupportHandoff();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supportHandoffProvider.overrideWithValue(handoff),
          currentUserEmailProvider.overrideWithValue('mina@example.com'),
        ],
        child: const MaterialApp(
          home: SupportRequestScreen(orderId: 'order-1'),
        ),
      ),
    );

    await tester.tap(find.text('Missing item'));
    await tester.pump();

    await tester.enterText(
      find.byType(TextField),
      'Extra napkins were missing.',
    );
    final Finder submitButton = find.text('Submit');
    await tester.scrollUntilVisible(
      submitButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(handoff.calls, 1);
    expect(handoff.lastDraft, isNotNull);
    final SupportRequestDraft draft = handoff.lastDraft!;
    expect(draft.orderId, 'order-1');
    expect(draft.userEmail, 'mina@example.com');
    expect(draft.category, SupportCategory.missingItem);
    expect(draft.message, 'Extra napkins were missing.');
    expect(draft.createdAt, isNotNull);
  });
}
