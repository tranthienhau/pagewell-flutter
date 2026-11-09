import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/providers.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});
  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController(text: 'ava.morgan@mail.com');
  final _pass = TextEditingController(text: 'pagewell');
  bool _hide = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint, {Widget? suffix}) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: C.surface,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.borderStrong)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.accentFill, width: 2)),
      );

  void _done() => Navigator.of(context).popUntil((r) => r.isFirst);

  @override
  Widget build(BuildContext context) => Scaffold(
        key: const Key('sign-in'),
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
            Align(alignment: Alignment.centerLeft, child: RoundIcon(Icons.arrow_back_rounded, onTap: () => Navigator.pop(context), semantic: 'Back')),
            const SizedBox(height: 12),
            const Avatar('assets/images/open-book.jpg', size: 72),
            const SizedBox(height: 20),
            Text('Welcome back', style: T.display),
            const SizedBox(height: 6),
            Text('Sign in to sync your library, bookmarks and membership', style: T.body.copyWith(color: C.text2)),
            const SizedBox(height: 24),
            Text('Email', style: T.label.copyWith(color: C.text2)),
            const SizedBox(height: 6),
            TextField(key: const Key('email'), controller: _email, keyboardType: TextInputType.emailAddress, style: T.body, decoration: _dec('you@example.com')),
            const SizedBox(height: 16),
            Text('Password', style: T.label.copyWith(color: C.text2)),
            const SizedBox(height: 6),
            TextField(
              key: const Key('password'),
              controller: _pass,
              obscureText: _hide,
              style: T.body,
              decoration: _dec('Password', suffix: IconButton(icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: C.text2), onPressed: () => setState(() => _hide = !_hide))),
            ),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: T.caption.copyWith(color: C.dangerFg))),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: Text('Forgot password?', style: T.label.copyWith(color: C.accentFill, fontWeight: FontWeight.w600)))),
            const SizedBox(height: 8),
            PrimaryButton('Sign in', key: const Key('sign-in-submit'), onTap: () {
              final err = ref.read(sessionProvider.notifier).signIn(_email.text.trim(), _pass.text);
              if (err != null) return setState(() => _error = err);
              _done();
            }),
            const SizedBox(height: 16),
            Row(children: [const Expanded(child: Divider(color: C.border)), Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: T.caption)), const Expanded(child: Divider(color: C.border))]),
            const SizedBox(height: 16),
            SecondaryButton('Continue as guest', key: const Key('guest'), onTap: () {
              ref.read(sessionProvider.notifier).continueAsGuest();
              _done();
            }),
            const SizedBox(height: 20),
            Center(child: Text.rich(TextSpan(style: T.label.copyWith(color: C.text2, fontWeight: FontWeight.w400), children: [const TextSpan(text: 'New here? '), TextSpan(text: 'Create account', style: T.label.copyWith(color: C.accentFill, fontWeight: FontWeight.w600))]))),
            const SizedBox(height: 24),
          ]),
        ),
      );
}
