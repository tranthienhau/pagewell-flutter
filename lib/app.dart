import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/shell/shell.dart';
import 'state/providers.dart';

class PagewellApp extends ConsumerWidget {
  const PagewellApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return MaterialApp(title: 'Pagewell', debugShowCheckedModeBanner: false, theme: buildTheme(), home: session == null ? const WelcomeScreen() : const Shell());
  }
}
