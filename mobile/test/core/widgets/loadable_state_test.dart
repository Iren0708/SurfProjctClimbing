import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/widgets/loadable_messages.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/core/widgets/state_container.dart';

void main() {
  group('LoadableState', () {
    test('fromList returns empty for empty collection', () {
      final state = LoadableState.fromList<String>(<String>[]);
      expect(state.status, LoadableStatus.empty);
    });

    test('fromList returns content for non-empty collection', () {
      final state = LoadableState.fromList(['slot']);
      expect(state.status, LoadableStatus.content);
      expect(state.data, ['slot']);
    });
  });

  group('StateContainer', () {
    testWidgets('shows skeleton while loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StateContainer<List<String>>(
            state: LoadableState<List<String>>.loading(),
            onRetry: () {},
            contentBuilder: (_, items) => Text(items.join()),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Не удалось загрузить'), findsNothing);
    });

    testWidgets('shows error with retry action', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StateContainer<List<String>>(
            state: LoadableState<List<String>>.error(),
            onRetry: () => retried = true,
            contentBuilder: (_, _) => const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.textContaining('Не удалось загрузить'), findsOneWidget);
      await tester.tap(find.text(LoadableMessages.retryAction));
      expect(retried, isTrue);
    });

    testWidgets('shows content and refreshing indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StateContainer<List<String>>(
            state: LoadableState<List<String>>.content(
              ['slot-1'],
              isRefreshing: true,
            ),
            onRetry: () {},
            contentBuilder: (_, items) => Text(items.first),
          ),
        ),
      );

      expect(find.text('slot-1'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows custom empty state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StateContainer<List<String>>(
            state: LoadableState<List<String>>.empty(),
            onRetry: () {},
            emptyBuilder: (_) => const Text('Пока нет доступных тренировок'),
            contentBuilder: (_, _) => const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('Пока нет доступных тренировок'), findsOneWidget);
    });

    testWidgets('ActionLoadableButton blocks repeat tap while submitting', (
      tester,
    ) async {
      var taps = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionLoadableButton(
              label: 'Записаться',
              state: const ActionLoadableState.submitting(),
              onPressed: () => taps += 1,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
