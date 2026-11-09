import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagewell/core/theme.dart';
import 'package:pagewell/state/providers.dart';

/// Loads the real Outfit + Fraunces files so layout tests measure real glyph widths.
Future<void> loadFonts() async {
  Future<void> family(String name, List<String> files) async {
    final l = FontLoader(name);
    for (final f in files) {
      l.addFont(Future.value(ByteData.view(File('assets/fonts/$f').readAsBytesSync().buffer)));
    }
    await l.load();
  }

  await family('Outfit', ['Outfit-Regular.ttf', 'Outfit-Medium.ttf', 'Outfit-SemiBold.ttf', 'Outfit-Bold.ttf']);
  await family('Fraunces', ['Fraunces-Regular.ttf', 'Fraunces-Italic.ttf', 'Fraunces-SemiBold.ttf', 'Fraunces-Bold.ttf']);
}

/// Pumps [child] on a 393x852 phone with a signed-in session.
Future<ProviderContainer> pumpScreen(WidgetTester t, Widget child, {bool signIn = true}) async {
  t.view.physicalSize = const Size(393 * 3, 852 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  final c = ProviderContainer();
  addTearDown(c.dispose);
  if (signIn) c.read(sessionProvider.notifier).signIn('ava.morgan@mail.com', 'pagewell');
  await t.pumpWidget(UncontrolledProviderScope(container: c, child: MaterialApp(theme: buildTheme(), home: child)));
  await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
  await t.pump(const Duration(milliseconds: 300));
  await t.pump(const Duration(milliseconds: 300));
  return c;
}
