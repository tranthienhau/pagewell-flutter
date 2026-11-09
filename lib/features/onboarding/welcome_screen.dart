import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'sign_in_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget point(IconData i, String t) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: C.accentTint, borderRadius: BorderRadius.circular(10)),
            child: Icon(i, color: C.accentFill, size: 20),
          ),
          const SizedBox(width: 12),
          Text(t, style: T.body),
        ],
      ),
    );
    return Scaffold(
      key: const Key('welcome'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight - 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset('assets/images/hero-reader.jpg', height: c.maxHeight * .42, width: double.infinity, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Image.asset('assets/logo/icon.png', width: 36, height: 36),
                      const SizedBox(width: 10),
                      Text('Pagewell', style: T.display),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Read and listen, all in one place', style: T.body.copyWith(color: C.text2)),
                  const SizedBox(height: 20),
                  point(Icons.menu_book_rounded, 'Ebooks with a calm reader'),
                  point(Icons.headphones_rounded, 'Audiobooks that stream instantly'),
                  point(Icons.wb_sunny_outlined, 'A fresh daily read'),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    'Get started',
                    key: const Key('get-started'),
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SignInScreen())),
                  ),
                  Center(
                    child: TextButton(
                      key: const Key('have-account'),
                      onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SignInScreen())),
                      child: Text(
                        'I already have an account',
                        style: T.label.copyWith(color: C.accentFill, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
