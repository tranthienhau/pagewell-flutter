import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagewell/app.dart';
import 'package:pagewell/features/article/article_screen.dart';
import 'package:pagewell/features/book/book_screen.dart';
import 'package:pagewell/features/membership/membership_screen.dart';
import 'package:pagewell/features/onboarding/sign_in_screen.dart';
import 'package:pagewell/features/onboarding/welcome_screen.dart';
import 'package:pagewell/features/player/player_screen.dart';
import 'package:pagewell/features/reader/reader_screen.dart';
import 'package:pagewell/features/reference/reference_screen.dart';
import 'package:pagewell/features/shell/shell.dart';
import 'package:pagewell/features/studio/studio_screen.dart';
import 'package:pagewell/state/providers.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadFonts);
  void noBook(BuildContext _, String _) {}

  testWidgets('welcome and sign-in render', (t) async {
    await pumpScreen(t, const WelcomeScreen(), signIn: false);
    expect(find.text('Pagewell'), findsOneWidget);
    await pumpScreen(t, const SignInScreen(), signIn: false);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('sign in validates and opens the shell', (t) async {
    t.view.physicalSize = const Size(393 * 3, 852 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.pumpWidget(UncontrolledProviderScope(container: c, child: const PagewellApp()));
    Future<void> frames([int n = 8]) async {
      for (var i = 0; i < n; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
    }

    await frames();
    await t.tap(find.byKey(const Key('have-account')));
    await frames();
    await t.enterText(find.byKey(const Key('password')), '123');
    await t.tap(find.byKey(const Key('sign-in-submit')));
    await frames(2);
    expect(find.text('Password needs 6+ characters'), findsOneWidget);
    await t.enterText(find.byKey(const Key('password')), 'pagewell');
    await t.tap(find.byKey(const Key('sign-in-submit')));
    await frames();
    expect(c.read(sessionProvider)?.name, 'Ava Morgan');
    expect(find.byKey(const Key('today')), findsOneWidget);
  });

  testWidgets('every tab renders without overflow', (t) async {
    final c = await pumpScreen(t, const Shell());
    expect(find.text('Good morning, Ava'), findsOneWidget);
    expect(find.text('Why we still read by the sea'), findsOneWidget);
    for (final tab in ['library', 'search', 'saved', 'profile', 'today']) {
      await t.tap(find.byKey(Key('tab-$tab')));
      await t.pump(const Duration(milliseconds: 400));
      expect(find.byKey(Key(tab)), findsOneWidget);
    }
    c.read(searchQueryProvider.notifier).setText('tide');
    c.read(tabProvider.notifier).go(2);
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('res-ref-tide')), findsOneWidget);
  });

  testWidgets('guest sees the empty library and can add free titles', (t) async {
    final c = await pumpScreen(t, const Shell(), signIn: false);
    c.read(sessionProvider.notifier).continueAsGuest();
    c.read(tabProvider.notifier).go(1);
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Your shelf is empty'), findsOneWidget);
    await t.tap(find.byKey(const Key('browse-free')));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('lib-salt-road')), findsOneWidget);
    expect(find.byKey(const Key('lib-tide-keeper')), findsNothing); // premium not added
  });

  testWidgets('book detail gates premium titles', (t) async {
    final c = await pumpScreen(t, const BookScreen(id: 'tide-keeper'));
    expect(find.text('Unlock'), findsWidgets);
    c.read(membershipProvider.notifier).startTrial('annual');
    await t.pump();
    expect(find.text('Read'), findsOneWidget);
    await pumpScreen(t, const BookScreen(id: 'salt-road'));
    expect(find.text('Ebook + Audio'), findsOneWidget);
  });

  testWidgets('EPUB reader renders the parsed chapter and switches theme', (t) async {
    final c = await pumpScreen(t, const ReaderScreen(bookId: 'salt-road', showSettings: true));
    expect(find.text('Chapter 2 - Salt and Dust'), findsWidgets);
    expect(find.textContaining('The caravan left before dawn'), findsOneWidget);
    await t.tap(find.byKey(const Key('theme-sepia')));
    await t.pump();
    expect(c.read(readerPrefsProvider).theme, ReaderTheme.sepia);
    await t.tap(find.byKey(const Key('reader-bookmark')));
    await t.pump();
    expect(c.read(bookmarksProvider).where((b) => b.label.endsWith('Chapter 2')).length, 0); // seeded bookmark toggled off
  });

  testWidgets('player streams, cycles speed and sets a sleep timer', (t) async {
    final c = await pumpScreen(t, const PlayerScreen());
    expect(find.text('Quiet Hours'), findsOneWidget);
    expect(find.text('18:24'), findsOneWidget);
    await t.tap(find.byKey(const Key('speed')));
    await t.tap(find.byKey(const Key('sleep')));
    await t.pump();
    expect(c.read(playerProvider)!.speed, 1.25);
    expect(c.read(playerProvider)!.sleepLeft, const Duration(minutes: 15));
    await t.tap(find.byKey(const Key('play-pause')));
    await t.pump(const Duration(seconds: 2));
    expect(c.read(playerProvider)!.position, greaterThan(const Duration(minutes: 18, seconds: 24)));
    await t.tap(find.byKey(const Key('play-pause')));
    await t.pump();
  });

  testWidgets('reference, article, paywall and studio render', (t) async {
    await pumpScreen(t, ReferenceScreen(id: 'tide', openBook: noBook));
    expect(find.text('Did you know'), findsOneWidget);
    await pumpScreen(t, ArticleScreen(id: 'read-by-the-sea', openBook: noBook));
    expect(find.textContaining('A book by the water'), findsOneWidget);
    await pumpScreen(t, const MembershipScreen());
    expect(find.text('Start 7-day free trial'), findsOneWidget);
    expect(find.textContaining(r'then $79.99 a year. Renews automatically'), findsOneWidget);
  });

  testWidgets('editor studio publishes the next item to Today', (t) async {
    final c = await pumpScreen(t, const StudioScreen());
    for (var i = 0; i < 20 && c.read(cmsProvider).value == null; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await t.pump();
    }
    expect(find.byKey(const Key('up-next')), findsOneWidget);
    await t.tap(find.byKey(const Key('publish-now')));
    await t.pump(const Duration(milliseconds: 300));
    expect(c.read(todayArticleProvider).id, 'narration');
  });
}
