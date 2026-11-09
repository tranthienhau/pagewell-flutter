import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/providers.dart';

class TabHeader extends ConsumerWidget {
  const TabHeader(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guest = ref.watch(sessionProvider)?.guest ?? false;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: T.display),
            if (subtitle != null) Text(subtitle!, style: T.caption.copyWith(fontSize: 14)),
          ]),
        ),
        GestureDetector(
          onTap: () => ref.read(tabProvider.notifier).go(4),
          child: guest
              ? Container(width: 44, height: 44, decoration: const BoxDecoration(color: C.accentTint, shape: BoxShape.circle), child: const Icon(Icons.person_outline_rounded, color: C.accentFill))
              : const Avatar('assets/images/avatar-ava.jpg', size: 44),
        ),
      ]),
    );
  }
}
