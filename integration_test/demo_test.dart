import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pagewell/app.dart';

import 'harness.dart';

/// Paced walkthrough for the demo GIF: sign in, read the EPUB (sepia theme), stream the
/// audiobook, search the reference library, publish tomorrow's daily read from the
/// editor studio and see Today update.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo walkthrough', (t) async {
    await t.pumpWidget(const ProviderScope(child: PagewellApp()));
    await waitFor(t, find.byKey(const Key('welcome')));
    await pumpFor(t, 1000);
    debugPrint('POC_DEMO_START');
    await pumpFor(t, 1200);
    await signIn(t, settleMs: 1000);
    await pumpFor(t, 1800);

    // Read: continue the EPUB, open text settings, switch to sepia.
    await tapKey(t, 'continue-read', settleMs: 1500);
    await scrollBy(t, 'reader-scroll', 260, settleMs: 900);
    await tapKey(t, 'reader-aa', settleMs: 900);
    await tapKey(t, 'theme-sepia', settleMs: 1400);
    await tapKey(t, 'theme-light', settleMs: 300);
    await back(t, settleMs: 900);

    // Listen: open the player from the mini player and stream for a moment.
    await tapKey(t, 'mini-player', settleMs: 1000);
    await tapKey(t, 'play-pause', settleMs: 2200);
    await tapKey(t, 'speed', settleMs: 900);
    await tapKey(t, 'play-pause', settleMs: 300);
    await back(t, settleMs: 900);

    // Search the reference library.
    await tapKey(t, 'tab-search', settleMs: 600);
    await t.enterText(find.byKey(const Key('search-field')), 'tide');
    FocusManager.instance.primaryFocus?.unfocus();
    await pumpFor(t, 1300);
    await tapKey(t, 'res-ref-tide', settleMs: 1800);
    await back(t, settleMs: 800);

    // CMS: publish tomorrow's daily read, then see it on Today.
    await tapKey(t, 'tab-profile', settleMs: 900);
    await tapKey(t, 'editor-studio', settleMs: 1300);
    await tapKey(t, 'publish-now', settleMs: 1600);
    await back(t, settleMs: 700);
    await tapKey(t, 'tab-today', settleMs: 2200);
    debugPrint('POC_DEMO_END');
    // Stay on screen past the cut so the GIF never ends on the launcher.
    await pumpFor(t, 3000);
  });
}
