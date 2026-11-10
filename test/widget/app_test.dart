import 'package:client_mobile/core/storage/key_value_store.dart';
import 'package:client_mobile/data/repositories/content_repository.dart';
import 'package:client_mobile/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers/fixtures.dart';

void main() {
  setUpAll(() => initializeDateFormatting());

  testWidgets('home shows the upcoming event and the navigation bar', (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    expect(find.text('Microsoft Tech Day – Oujda'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in ['Home', 'Events', 'Programs', 'Speakers', 'Saved']) {
      expect(find.text(label), findsWidgets);
    }
  });

  testWidgets('events tab: search and time filter', (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Events'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('3 events'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'tanger');
    await tester.pumpAndSettle();
    expect(find.text('1 event'), findsOneWidget);
    expect(find.text('Global AI Bootcamp – Tanger'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upcoming').first);
    await tester.pumpAndSettle();
    expect(find.text('1 event'), findsOneWidget);
  });

  testWidgets('event details: register, sessions and bookmark', (tester) async {
    final store = MemoryStore();
    await pumpApp(tester, route: '/events/ev-oujda', store: store);
    await tester.pumpAndSettle();

    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Hassan Fadili'), findsOneWidget);
    expect(find.text('GitHub Copilot · 45 min'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bookmark_border).first);
    await tester.pump();
    expect(store.getStringList('bookmarks.events'), ['ev-oujda']);
    await tester.pump(const Duration(seconds: 3)); // let the SnackBar go
  });

  testWidgets('past event shows "ended" instead of registration', (tester) async {
    await pumpApp(tester, route: '/events/ev-tanger');
    await tester.pumpAndSettle();
    expect(find.text('This event has ended'), findsOneWidget);
    expect(find.text('Register'), findsNothing);
  });

  testWidgets('speaker details lists their events', (tester) async {
    await pumpApp(tester, route: '/speakers/sp-1');
    await tester.pumpAndSettle();
    expect(find.text('Hassan Fadili'), findsOneWidget);
    expect(find.text('Spoke at (2)'), findsOneWidget);
  });

  testWidgets('unknown routes show a not-found page', (tester) async {
    await pumpApp(tester, route: '/events/does-not-exist');
    await tester.pumpAndSettle();
    expect(find.text('This page no longer exists.'), findsOneWidget);
  });

  testWidgets('error state with working retry', (tester) async {
    final repo = FakeRepository(testBundle(), fail: true);
    await pumpApp(tester, repository: repo);
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);

    repo.fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Microsoft Tech Day – Oujda'), findsWidgets);
  });

  testWidgets('switching to French translates the UI', (tester) async {
    await pumpApp(tester, route: '/settings');
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Français'), 100);
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();
    expect(find.text('Paramètres'), findsOneWidget);
  });

  test('ContentOrigin default for fixtures is snapshot', () {
    expect(testBundle().origin, ContentOrigin.snapshot);
  });
}
