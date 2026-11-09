import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/nav.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sessionProvider);
    final m = ref.watch(membershipProvider);
    Widget stat(String n, String l) => Expanded(
          child: CardBox(padding: const EdgeInsets.symmetric(vertical: 14), radius: 16, child: Column(children: [Text(n, style: T.headline.copyWith(color: C.accentFill)), Text(l, style: T.caption)])),
        );
    Widget row(String key, IconData icon, String label, VoidCallback onTap, {Color color = C.ink, bool chevron = true}) => InkWell(
          key: Key(key),
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Row(children: [
              const SizedBox(width: 16),
              Icon(icon, color: color == C.ink ? C.text2 : color, size: 22),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: T.body.copyWith(color: color))),
              if (chevron) const Icon(Icons.chevron_right_rounded, color: C.text3),
              const SizedBox(width: 12),
            ]),
          ),
        );

    return ListView(key: const Key('profile'), padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
      Text('Profile', style: T.display),
      const SizedBox(height: 16),
      Row(children: [
        s?.guest ?? true
            ? Container(width: 64, height: 64, decoration: const BoxDecoration(color: C.accentTint, shape: BoxShape.circle), child: const Icon(Icons.person_outline_rounded, color: C.accentFill, size: 32))
            : const Avatar('assets/images/avatar-ava.jpg', size: 64),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s?.name ?? 'Guest reader', style: T.title),
            Text(s?.guest ?? true ? 'Sign in to sync across devices' : s!.email, style: T.caption),
          ]),
        ),
      ]),
      const SizedBox(height: 20),
      Container(
        key: const Key('plan-card'),
        decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(20), boxShadow: shadowCard),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(width: 5, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [C.accent, C.support]))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(m.premium ? 'Premium (${m.plan})' : 'Free plan', style: T.title)),
                    if (!m.premium) PrimaryButton('Upgrade', key: const Key('upgrade'), compact: true, onTap: () => Nav.membership(context)) else const Pill('Active', fg: C.successFg, bg: C.successTint),
                  ]),
                  const SizedBox(height: 6),
                  Text(m.premium ? 'Unlimited books, audio and reference' : '${m.booksUsed} of ${m.freeLimit} books used this month', style: T.caption),
                  const SizedBox(height: 10),
                  Bar(m.premium ? 1 : m.booksUsed / m.freeLimit),
                ]),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Row(children: [stat('14', 'Books read'), const SizedBox(width: 12), stat('36h', 'Listened'), const SizedBox(width: 12), stat('21', 'Day streak')]),
      const SizedBox(height: 16),
      CardBox(
        padding: EdgeInsets.zero,
        child: Column(children: [
          row('downloads', Icons.download_outlined, 'Downloads', () {}),
          const Divider(height: 1, color: C.border),
          row('reading-prefs', Icons.text_fields_rounded, 'Reading preferences', () {}),
          const Divider(height: 1, color: C.border),
          row('notifications', Icons.notifications_none_rounded, 'Notifications', () {}),
          const Divider(height: 1, color: C.border),
          row('editor-studio', Icons.edit_note_rounded, 'Editor studio', () => Nav.studio(context)),
          const Divider(height: 1, color: C.border),
          row('sign-out', Icons.logout_rounded, 'Sign out', () => ref.read(sessionProvider.notifier).signOut(), color: C.dangerFg, chevron: false),
        ]),
      ),
    ]);
  }
}
