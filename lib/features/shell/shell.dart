import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../state/providers.dart';
import '../library/library_screen.dart';
import '../player/player_screen.dart';
import '../profile/profile_screen.dart';
import '../saved/saved_screen.dart';
import '../search/search_screen.dart';
import '../today/today_screen.dart';

/// Five-tab shell (Today, Library, Search, Saved, Profile) with the mini player above the bar.
class Shell extends ConsumerWidget {
  const Shell({super.key});

  static const tabs = [
    ('Today', Icons.wb_sunny_outlined),
    ('Library', Icons.local_library_outlined),
    ('Search', Icons.search_rounded),
    ('Saved', Icons.bookmark_border_rounded),
    ('Profile', Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i = ref.watch(tabProvider);
    return Scaffold(
      key: const Key('shell'),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: i, children: const [TodayScreen(), LibraryScreen(), SearchScreen(), SavedScreen(), ProfileScreen()]),
      ),
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
        if (i != 4) const MiniPlayer(),
        Container(
          decoration: const BoxDecoration(color: C.surface, border: Border(top: BorderSide(color: C.border))),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(children: [
                for (var k = 0; k < tabs.length; k++)
                  Expanded(
                    child: Semantics(
                      selected: k == i,
                      button: true,
                      label: tabs[k].$1,
                      child: InkWell(
                        key: Key('tab-${tabs[k].$1.toLowerCase()}'),
                        onTap: () => ref.read(tabProvider.notifier).go(k),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 52,
                            height: 30,
                            decoration: BoxDecoration(color: k == i ? C.accentTint : Colors.transparent, borderRadius: BorderRadius.circular(999)),
                            child: Icon(tabs[k].$2, size: 22, color: k == i ? C.accentFill : C.text2),
                          ),
                          const SizedBox(height: 2),
                          Text(tabs[k].$1, style: T.caption.copyWith(fontSize: 12, color: k == i ? C.accentFill : C.text2, fontWeight: k == i ? FontWeight.w600 : FontWeight.w500)),
                        ]),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
