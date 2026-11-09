import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/nav.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';
import '../../state/providers.dart';
import '../shell/tab_header.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider);
    final session = ref.watch(sessionProvider);
    final a = ref.watch(todayArticleProvider);
    final lib = ref.watch(libraryProvider);
    final player = ref.watch(playerProvider);
    final first = (session == null || session.guest) ? 'reader' : session.name.split(' ').first;
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    final salt = bookById('salt-road');
    final audio = player == null ? null : bookById(player.bookId);
    final audioLeft = player == null ? 0 : ((bookById(player.bookId).audioMinutes) * (1 - (lib.progress[player.bookId] ?? 0))).round();

    return ListView(
      key: const Key('today'),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        TabHeader('Good morning, $first', subtitle: '${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]}'),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: GestureDetector(
            key: const Key('daily-read'),
            onTap: () => Nav.article(context, a.id),
            child: Container(
              height: 300,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: shadowCard),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(a.image, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [.35, 1], colors: [Color(0x00000000), Color(0xD91C0C1F)]),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0x991C0C1F), borderRadius: BorderRadius.circular(999)),
                      child: Text(
                        "Today's read",
                        style: T.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title,
                          key: const Key('daily-title'),
                          style: T.headline.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text('${a.author}  -  ${a.minutes} min read', style: T.caption.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('Continue'),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _ContinueCard(
                        key: const Key('continue-read'),
                        cover: salt.cover,
                        title: salt.title,
                        author: salt.author,
                        footer: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${((lib.progress[salt.id] ?? 0) * 100).round()}% read', style: T.caption),
                            const SizedBox(height: 6),
                            Bar(lib.progress[salt.id] ?? 0),
                          ],
                        ),
                        onTap: () => Nav.read(context, ref, salt.id),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (audio != null)
                      Expanded(
                        child: _ContinueCard(
                          key: const Key('continue-listen'),
                          cover: audio.cover,
                          title: audio.title,
                          author: audio.author,
                          footer: Row(
                            children: [
                              const Icon(Icons.headphones_rounded, size: 18, color: C.accentFill),
                              const SizedBox(width: 6),
                              Text('${hm(audioLeft)} left', style: T.caption),
                            ],
                          ),
                          onTap: () => Nav.player(context),
                        ),
                      ),
                  ],
                ),
              ),
              SectionTitle('New this week', action: 'See all', onAction: () => ref.read(tabProvider.notifier).go(1)),
            ],
          ),
        ),
        SizedBox(
          height: 236,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              for (final id in const ['tide-keeper', 'lanterns', 'small-rivers', 'north-of-quiet'])
                GestureDetector(
                  key: Key('new-$id'),
                  onTap: () => Nav.book(context, id),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: SizedBox(
                      width: 124,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CoverImage(bookById(id).cover, width: 124, premium: bookById(id).premium),
                          const SizedBox(height: 8),
                          Text(
                            bookById(id).title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: T.label.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(bookById(id).author, maxLines: 1, style: T.caption),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({super.key, required this.cover, required this.title, required this.author, required this.footer, required this.onTap});
  final String cover, title, author;
  final Widget footer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CardBox(
    padding: const EdgeInsets.all(12),
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 1.25,
            child: Image.asset(cover, fit: BoxFit.cover, alignment: const Alignment(0, .3)),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: T.body.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(author, style: T.caption),
        const Spacer(),
        const SizedBox(height: 8),
        footer,
      ],
    ),
  );
}
