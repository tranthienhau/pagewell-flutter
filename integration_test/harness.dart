import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixed-time pumps instead of pumpAndSettle: the player clock and spinners never settle.
Future<void> pumpFor(WidgetTester t, [int ms = 600]) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (DateTime.now().isBefore(end)) {
    await t.pump(const Duration(milliseconds: 50));
  }
}

Future<void> waitFor(WidgetTester t, Finder f, {int timeoutMs = 30000}) async {
  final end = DateTime.now().add(Duration(milliseconds: timeoutMs));
  while (f.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) throw StateError('Timed out waiting for $f');
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tapKey(WidgetTester t, String key, {int settleMs = 900}) async {
  final f = find.byKey(Key(key));
  await waitFor(t, f);
  await t.ensureVisible(f.last);
  await pumpFor(t, 200);
  // Tap near the top of tall targets (grid tiles) so the point is always on screen.
  final r = t.getRect(f.last);
  await t.tapAt(Offset(r.center.dx, r.height > 120 ? r.top + 60 : r.center.dy));
  await pumpFor(t, settleMs);
}

/// Pops the top route (the in-app back arrow).
Future<void> back(WidgetTester t, {int settleMs = 900}) async {
  final nav = t.state<NavigatorState>(find.byType(Navigator).last);
  nav.pop();
  await pumpFor(t, settleMs);
}

Future<void> signIn(WidgetTester t, {int settleMs = 900}) async {
  await tapKey(t, 'have-account', settleMs: settleMs);
  await tapKey(t, 'sign-in-submit', settleMs: settleMs);
  await waitFor(t, find.byKey(const Key('today')));
}

Future<void> scrollBy(WidgetTester t, String key, double dy, {int settleMs = 700}) async {
  await t.drag(find.byKey(Key(key)), Offset(0, -dy));
  await pumpFor(t, settleMs);
}
