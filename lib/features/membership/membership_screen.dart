import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/providers.dart';

class MembershipScreen extends ConsumerStatefulWidget {
  const MembershipScreen({super.key});
  @override
  ConsumerState<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends ConsumerState<MembershipScreen> {
  String _plan = 'annual';

  @override
  Widget build(BuildContext context) {
    final m = ref.watch(membershipProvider);
    Widget plan(String id, String name, String price, String per, {String? sub, String? badge}) {
      final sel = _plan == id;
      return GestureDetector(
        key: Key('plan-$id'),
        onTap: () => setState(() => _plan = id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? C.accentFill : C.border, width: sel ? 2 : 1)),
          child: Row(children: [
            Icon(sel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: sel ? C.accentFill : C.borderStrong),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(name, style: T.body.copyWith(fontWeight: FontWeight.w600)),
                  if (badge != null) ...[const SizedBox(width: 8), Pill(badge, fg: C.successFg, bg: C.successTint)],
                ]),
                if (sub != null) Text(sub, style: T.caption),
              ]),
            ),
            Text.rich(TextSpan(children: [TextSpan(text: price, style: T.body.copyWith(fontWeight: FontWeight.w700)), TextSpan(text: ' / $per', style: T.caption)])),
          ]),
        ),
      );
    }

    return Scaffold(
      key: const Key('membership'),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
          Align(alignment: Alignment.centerLeft, child: RoundIcon(Icons.close_rounded, key: const Key('membership-close'), onTap: () => Navigator.pop(context), semantic: 'Close')),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [C.accentFill, C.accentPressed], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Column(children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), shape: BoxShape.circle), child: const Icon(Icons.workspace_premium_rounded, color: Colors.white)),
              const SizedBox(height: 12),
              Text('Pagewell Premium', style: T.display.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text('Every book, every voice, every day', style: T.body.copyWith(color: Colors.white)),
            ]),
          ),
          const SizedBox(height: 20),
          for (final b in const ['Unlimited audiobooks', 'The full reference library', 'Offline downloads', 'Every daily read and archive'])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                Container(width: 24, height: 24, decoration: const BoxDecoration(color: C.accentTint, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, size: 16, color: C.accentFill)),
                const SizedBox(width: 12),
                Text(b, style: T.body),
              ]),
            ),
          const SizedBox(height: 12),
          plan('monthly', 'Monthly', r'$9.99', 'month'),
          plan('annual', 'Annual', r'$79.99', 'year', sub: r'$6.67 / month', badge: 'Save 33%'),
          const SizedBox(height: 8),
          if (m.premium)
            Container(
              key: const Key('premium-active'),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: C.successTint, borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded, color: C.successFg),
                const SizedBox(width: 10),
                Expanded(child: Text('Premium is on (${m.plan}). Trial ends in 7 days.', style: T.label.copyWith(color: C.successFg, fontWeight: FontWeight.w600))),
              ]),
            )
          else
            PrimaryButton('Start 7-day free trial', key: const Key('start-trial'), onTap: () {
              ref.read(membershipProvider.notifier).startTrial(_plan);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome to Premium. Every title is unlocked.')));
            }),
          const SizedBox(height: 12),
          Text('Cancel anytime. The free plan includes 3 books a month.', textAlign: TextAlign.center, style: T.label.copyWith(color: C.text2, fontWeight: FontWeight.w400)),
          const SizedBox(height: 8),
          Center(child: TextButton(onPressed: () {}, child: Text('Restore purchase', style: T.label.copyWith(color: C.accentFill, fontWeight: FontWeight.w600)))),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

/// Opens [page] when the content is free or the reader is Premium, otherwise the paywall.
void openGated(BuildContext context, WidgetRef ref, {required bool premium, required WidgetBuilder page}) {
  final ok = ref.read(canOpenProvider(premium));
  Navigator.push(context, MaterialPageRoute<void>(builder: ok ? page : (_) => const MembershipScreen()));
}
