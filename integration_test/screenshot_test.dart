import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pagewell/app.dart';

import 'harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture key screens', (t) async {
    await t.pumpWidget(const ProviderScope(child: PagewellApp()));
    await binding.convertFlutterSurfaceToImage();
    await waitFor(t, find.byKey(const Key('welcome')));

    Future<void> shot(String name, [int ms = 1200]) async {
      await pumpFor(t, ms);
      await binding.takeScreenshot(name);
    }

    await shot('01-welcome');
    await tapKey(t, 'have-account');
    await shot('02-sign-in');
    await tapKey(t, 'sign-in-submit');
    await waitFor(t, find.byKey(const Key('today')));
    await shot('03-today', 1500);

    await tapKey(t, 'tab-library');
    await shot('04-library');
    await tapKey(t, 'lib-salt-road');
    await shot('05-book-detail');
    await tapKey(t, 'read');
    await waitFor(t, find.byKey(const Key('reader-scroll')));
    await tapKey(t, 'reader-aa');
    await shot('06-epub-reader');
    await back(t);
    await back(t);

    await tapKey(t, 'tab-today');
    await tapKey(t, 'mini-player');
    await tapKey(t, 'speed', settleMs: 300);
    await tapKey(t, 'play-pause', settleMs: 300);
    await shot('07-audiobook-player', 2000);
    await tapKey(t, 'play-pause', settleMs: 300);
    await back(t);

    await tapKey(t, 'tab-search');
    await t.enterText(find.byKey(const Key('search-field')), 'tide');
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('08-search');
    await tapKey(t, 'res-ref-tide');
    await shot('09-reference');
    await back(t);

    await tapKey(t, 'tab-saved');
    await shot('10-saved');

    await tapKey(t, 'tab-profile');
    await shot('11-profile');
    await tapKey(t, 'upgrade');
    await shot('12-membership');
    await back(t);
    await tapKey(t, 'editor-studio');
    await shot('13-editor-studio');
    await tapKey(t, 'publish-now', settleMs: 1200);
    await back(t);
    await tapKey(t, 'tab-today');
    await shot('14-today-after-publish', 1500);
  });
}
